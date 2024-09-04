import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class AnnouncementWebPage extends StatelessWidget {
  const AnnouncementWebPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Controllers for title and announcement text fields
    TextEditingController titleController = TextEditingController();
    TextEditingController announcementController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('A N N O U N C E M E N T'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(35.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Send Announcement to All Students',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Text Field for Announcement Title
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Announcement Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Text Field for Announcement Message
            TextField(
              controller: announcementController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Announcement Message',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Send Button with black color and reduced width
            Align(
              alignment: Alignment.centerLeft, // Align the button to the left
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // Set button color to black
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Add padding for better appearance
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rounded corners for the button
                  ),
                ),
                onPressed: () async {
                  String title = titleController.text.trim();
                  String message = announcementController.text.trim();
                  
                  if (title.isNotEmpty && message.isNotEmpty) {
                    try {
                      // Upload the announcement to Firestore
                      await FirebaseFirestore.instance.collection('announcements').add({
                        'title': title,
                        'message': message,
                        'timestamp': FieldValue.serverTimestamp(), // Store the timestamp
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Announcement sent successfully to all students!'),
                        ),
                      );

                      // Clear input fields
                      titleController.clear();
                      announcementController.clear();
                    } catch (e) {
                      print('Error sending announcement: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to send announcement. Please try again.'),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter both a title and a message for the announcement.'),
                      ),
                    );
                  }
                },
                child: const Text('Send Announcement', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
