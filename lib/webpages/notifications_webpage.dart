import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NotificationWebPage extends StatelessWidget {
  const NotificationWebPage({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController notificationController = TextEditingController();

    // Example cancellation notification texts
    String exampleNotificationText1 = "Your appointment has been cancelled. Please reschedule at your earliest convenience.";
    String exampleNotificationText2 = "Your appointment has been confirmed. Please arrive 10 minutes early.";
    String exampleNotificationText3 = "You have an appointment tomorrow. Please remember to bring your ID.";

    // List of users or groups (this would typically be fetched from Firebase)
    List<String> users = ['User 1', 'User 2', 'User 3', 'Group A', 'Group B'];
    List<String> selectedUsers = [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Management'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 30), // Space between columns
            // First Column: Notification Creation
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create New Notification',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Multi-select Dropdown for Users or Groups
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Select Users/Groups',
                      border: OutlineInputBorder(),
                    ),
                    items: users.map((user) {
                      return DropdownMenuItem<String>(
                        value: user,
                        child: Text(user),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null && !selectedUsers.contains(value)) {
                        selectedUsers.add(value);
                      }
                    },
                    isExpanded: true,
                  ),
                  const SizedBox(height: 16),

                  // Text Field for Notification Message
                  TextField(
                    controller: notificationController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Notification Message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Send Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        String message = notificationController.text.trim();
                        if (message.isNotEmpty && selectedUsers.isNotEmpty) {
                          // Implement your logic to upload the notification to Firebase here
                          print('Notification Sent to: $selectedUsers');
                          print('Notification Message: $message');

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Notification sent successfully!'),
                            ),
                          );

                          notificationController.clear(); // Clear the input field
                          selectedUsers.clear(); // Clear selected users
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a notification message and select at least one user/group.'),
                            ),
                          );
                        }
                      },
                      child: const Text('Send Notification'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 30), // Space between columns
            

            // Second Column: Provided Texts
            Expanded(
              flex: 1,
              child: Column(
                
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 55), 
                  // Example Notification Text 1 with Copy Icon
                  _buildExampleNotification(context, exampleNotificationText1),
                  const SizedBox(height: 16),

                  // Example Notification Text 2 with Copy Icon
                  _buildExampleNotification(context, exampleNotificationText2),
                  const SizedBox(height: 16),

                  // Example Notification Text 3 with Copy Icon
                  _buildExampleNotification(context, exampleNotificationText3),
                ],
              ),
            ),

            const SizedBox(width: 30), // Space between columns
          ],
        ),
      ),
    );
  }

  Widget _buildExampleNotification(BuildContext context, String notificationText) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              notificationText,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: notificationText));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Copied to clipboard!'),
              ),
            );
          },
        ),
      ],
    );
  }
}
