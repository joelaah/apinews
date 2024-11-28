import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewsListScreen extends StatelessWidget {
  const NewsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('News')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('news')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No news available.'));
          }
          final newsDocs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: newsDocs.length,
            itemBuilder: (ctx, index) {
              // Get the document
              var doc = newsDocs[index];

              // Check if the imageUrl field exists
              String? imageUrl =
                  (doc.data() as Map<String, dynamic>).containsKey('imageUrl')
                      ? doc['imageUrl']
                      : null;

              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display the image if it exists
                      if (imageUrl != null && imageUrl.isNotEmpty)
                        Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          height: 200, // Adjust height as necessary
                          width: double.infinity,
                        ),
                      const SizedBox(height: 10),
                      Text(
                        doc['title'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        doc['author'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton:
          (user != null && user.uid == 'vG5bTRFTeOZohL55O2gm3pZlAgp2')
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/add-news');
                  },
                  child: const Icon(Icons.add),
                )
              : null, // Only show the button for the admin
    );
  }
}
