import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewsListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text('News')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('news')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No news available.'));
          }
          final newsDocs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: newsDocs.length,
            itemBuilder: (ctx, index) => ListTile(
              title: Text(newsDocs[index]['title']),
              subtitle: Text(newsDocs[index]['author']),
            ),
          );
        },
      ),
      floatingActionButton:
          (user != null && user.uid == 'vG5bTRFTeOZohL55O2gm3pZlAgp2')
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/add-news');
                  },
                  child: Icon(Icons.add),
                )
              : null, // Only show the button for the admin
    );
  }
}
