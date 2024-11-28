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
  File? _pickedImage;
  final String adminUid =
      'vG5bTRFTeOZohL55O2gm3pZlAgp2'; // Replace with your UID

  final picker = ImagePicker(); // Image picker to select images

  // Function to pick image from gallery
  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  Future<String> uploadImage(File image) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageReference =
        FirebaseStorage.instance.ref().child('news_images').child(fileName);

    try {
      // Upload the image file to Firebase Storage
      UploadTask uploadTask = storageReference.putFile(image);

      // Check if upload completes successfully
      TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
      if (snapshot.state == TaskState.success) {
        // If upload is successful, get the download URL
        String downloadURL = await snapshot.ref.getDownloadURL();
        print('Upload successful. Image URL: $downloadURL');
        return downloadURL;
      } else {
        throw FirebaseException(
            plugin: 'firebase_storage',
            message: 'Image upload failed. Please try again.');
      }
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  // Function to add news to Firestore
  void addNews() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && user.uid == adminUid) {
      String imageUrl = '';
      if (_pickedImage != null) {
        // Upload image and get URL
        imageUrl = await uploadImage(_pickedImage!);
      }

      await FirebaseFirestore.instance.collection('news').add({
        'title': titleController.text,
        'content': contentController.text,
        'author': authorController.text,
        'imageUrl': imageUrl, // Store image URL in Firestore
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context); // Close the form after submission
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only admins can add news.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add News')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(labelText: 'Content'),
              maxLines: 5,
            ),
            TextField(
              controller: authorController,
              decoration: const InputDecoration(labelText: 'Author'),
            ),
            const SizedBox(height: 10),
            _pickedImage != null
                ? Image.file(
                    _pickedImage!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : TextButton.icon(
                    onPressed: pickImage, // Pick image from gallery
                    icon: const Icon(Icons.image),
                    label: const Text('Pick an image'),
                  ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: addNews,
              child: const Text('Submit News'),
            ),
          ],
        ),
      ),
    );
  }
}

