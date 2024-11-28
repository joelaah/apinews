import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(
                      'https://images.unsplash.com/photo-1622964318124-d87cb88d24e2?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'), // Replace with your image path
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Our Company',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Innovating for a Better Future',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Who We Are',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'We are a technology-driven company committed to creating cutting-edge solutions for businesses and individuals alike. With a team of dedicated professionals, we strive to bring innovation and excellence to every project we undertake.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                'Our Mission',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Our mission is to empower people and organizations by providing high-quality products and services that drive success and growth. We believe in sustainability, inclusivity, and continuous improvement.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                'Contact Us',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: const [
                  Icon(Icons.email, color: Colors.blue),
                  SizedBox(width: 10),
                  Text('joelapachuau64@gmail.com'),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: const [
                  Icon(Icons.phone, color: Colors.blue),
                  SizedBox(width: 10),
                  Text('+91 (936) 679-7268'),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: const [
                  Icon(Icons.location_on, color: Colors.blue),
                  SizedBox(width: 10),
                  Text('Aizawl, Mizoram'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
