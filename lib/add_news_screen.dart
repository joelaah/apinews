import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AddNewsScreen extends StatefulWidget {
  const AddNewsScreen({super.key});

  @override
  AddNewsScreenState createState() => AddNewsScreenState();
}

class AddNewsScreenState extends State<AddNewsScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  String selectedCategory = 'News'; // Default category
  final List<String> categories = [
    'News',
    'Football',
    'Technology',
    'Tualchung'
  ];

  File? _pickedImage;
  final picker = ImagePicker();

  bool isLoading = false; // Track loading state

  Future<void> pickImage() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _pickedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<String> uploadImage(File image) async {
    return retryOperation(() async {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('news_images/$selectedCategory')
          .child(fileName);

      UploadTask uploadTask = storageReference.putFile(image);
      TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
      return await snapshot.ref.getDownloadURL();
    });
  }

  Future<void> addNews() async {
    if (titleController.text.isEmpty ||
        contentController.text.isEmpty ||
        authorController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields must be filled.')),
      );
      return;
    }

    setState(() {
      isLoading = true; // Start loading
    });

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        String imageUrl = '';
        if (_pickedImage != null) {
          imageUrl = await uploadImage(_pickedImage!);
        }

        await retryOperation(() async {
          await FirebaseFirestore.instance.collection('news').add({
            'title': titleController.text,
            'content': contentController.text,
            'author': authorController.text,
            'category': selectedCategory, // Add category to Firestore
            'imageUrl': imageUrl,
            'timestamp': FieldValue.serverTimestamp(),
          });
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('News added successfully!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding news: $e')),
        );
      } finally {
        setState(() {
          isLoading = false; // Stop loading
        });
      }
    } else {
      setState(() {
        isLoading = false; // Stop loading
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only authorized users can add news.')),
      );
    }
  }

  Future<T> retryOperation<T>(
    Future<T> Function() operation, {
    int retries = 3,
    Duration initialDelay = const Duration(seconds: 1),
  }) async {
    Duration delay = initialDelay;
    for (int attempt = 0; attempt < retries; attempt++) {
      try {
        return await operation();
      } catch (e) {
        if (attempt == retries - 1) {
          rethrow; // Throw the error after the last retry
        }
        await Future.delayed(delay);
        delay *= 2; // Double the delay for exponential backoff
      }
    }
    throw Exception('Operation failed after $retries retries.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add News')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Field
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),

            // Content Field
            TextField(
              controller: contentController,
              decoration: InputDecoration(
                labelText: 'Content',
                labelStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 20),

            // Author Field
            TextField(
              controller: authorController,
              decoration: InputDecoration(
                labelText: 'Author',
                labelStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),

            // Category Dropdown
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                labelStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 20),

            // Image Picker
            _pickedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _pickedImage!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                : OutlinedButton.icon(
                    onPressed: pickImage,
                    icon: const Icon(Icons.image),
                    label: Center(child: const Text('Pick an Image')),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      side: const BorderSide(color: Colors.blue),
                    ),
                  ),
            const SizedBox(height: 20),

            // Submit Button
            ElevatedButton(
              onPressed: isLoading ? null : addNews,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Center(
                child: isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      )
                    : const Text(
                        'Submit News',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

