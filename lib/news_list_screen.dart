import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:news_ownapi/about_us.dart';
import 'package:news_ownapi/add_news_screen.dart';
import 'package:news_ownapi/article.dart';
import 'package:news_ownapi/login_screen.dart';

class NewsListScreen extends StatelessWidget {
  const NewsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current user
    final User? currentUser = FirebaseAuth.instance.currentUser;

    // Define the user allowed to access the FAB (e.g., by email or UID)
    const allowedUserEmail = "joela@gmail.com";

    return DefaultTabController(
      length: 4, // Number of categories
      child: Scaffold(
        drawer: Drawer(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Aligns content
            children: [
              Column(
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.blue, // Blue background color
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'News',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text('Home'),
                    onTap: () {
                      Navigator.pop(context); // Close the drawer
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.article),
                    title: const Text('My Articles'),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              const Article())); // Close the drawer
                    },
                  ),
                  ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('About Us'),
                      onTap: () async {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const AboutUsPage()),
                        );
                      })
                ],
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () async {
                  await FirebaseAuth.instance.signOut(); // Sign out the user
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.newspaper, color: Colors.blueGrey),
              const SizedBox(width: 8),
              Text(
                'News',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..shader = const LinearGradient(
                            colors: <Color>[Colors.blue, Colors.indigo])
                        .createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                ),
              ),
            ],
          ),
          centerTitle: true,
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'News'),
              Tab(text: 'Football'),
              Tab(text: 'Technology'),
              Tab(text: 'Tualchung'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            NewsCategoryScreen(category: 'News'),
            NewsCategoryScreen(category: 'Football'),
            NewsCategoryScreen(category: 'Technology'),
            NewsCategoryScreen(category: 'Tualchung'), //
          ],
        ),
        floatingActionButton:
            currentUser != null && currentUser.email == allowedUserEmail
                ? FloatingActionButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AddNewsScreen(),
                        ),
                      );
                    },
                    child: const Icon(Icons.add),
                  )
                : null,
      ),
    );
  }
}

class NewsCategoryScreen extends StatelessWidget {
  final String category;

  const NewsCategoryScreen({super.key, required this.category});

  Stream<QuerySnapshot> fetchNews(String category) {
    return FirebaseFirestore.instance
        .collection('news')
        .where('category', isEqualTo: category)
        .orderBy('timestamp', descending: true)
        .snapshots(); // Real-time updates
  }

  Future<void> deleteNews(BuildContext context, String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('news')
          .doc(documentId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("News deleted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleteing News $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: fetchNews(category),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No $category news available.'));
        }

        final newsDocs = snapshot.data!.docs;

        return PageView.builder(
          itemCount: newsDocs.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            var doc = newsDocs[index];
            String? imageUrl = doc['imageUrl'];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imageUrl != null && imageUrl.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    FullScreenImage(imageUrl: imageUrl),
                              ),
                            );
                          },
                          child: Hero(
                            tag: imageUrl,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                imageUrl,
                                height: 250,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 10),
                      Text(
                        doc['title'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'By ${doc['author']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            doc['content'],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      if (currentUser?.uid ==
                          'gFRQaEicZHRg5lVFYYWA5Pux42E3') // Show delete only for authenticated users
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirm Delete'),
                                content: const Text(
                                    'Are you sure you want to delete this news item?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      await deleteNews(context, doc.id);
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Hero(
          tag: imageUrl,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
