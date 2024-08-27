import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AppointmentsWebPage extends StatefulWidget {
  @override
  _AppointmentsWebPageState createState() => _AppointmentsWebPageState();
}

class _AppointmentsWebPageState extends State<AppointmentsWebPage> {
  Future<List<Map<String, dynamic>>> fetchBookingAndUserData() async {
    List<Map<String, dynamic>> combinedData = [];

    QuerySnapshot bookingsSnapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .where('status', whereIn: ['scheduled', 'in-progress']).get();

    for (var doc in bookingsSnapshot.docs) {
      final bookingData = doc.data() as Map<String, dynamic>;
      final userId = bookingData['userId'];

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      final userData = userDoc.data() as Map<String, dynamic>;

      final date = (bookingData['date'] as Timestamp).toDate();
      final formattedDate = date.toLocal().toString().split(' ')[0];
      final timeSlot = bookingData['timeSlot'] ?? 'N/A';

      combinedData.add({
        'name': userData['name'] ?? 'No Name',
        'phone_number': userData['phone_number'] ?? 'No Phone Number',
        'dateTimeSlot': '$formattedDate\n$timeSlot',
        'status': bookingData['status'] ?? 'scheduled',
        'bookingId': doc.id,
      });
    }

    return combinedData;
  }

  void _showConfirmationDialog({
    required BuildContext context,
    required String action,
    required Function() onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm $action'),
          content: Text('Are you sure you want to $action this appointment?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                onConfirm(); // Execute the action
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _cancelAppointment(String bookingId) async {
    _showConfirmationDialog(
      context: context,
      action: 'cancel',
      onConfirm: () async {
        try {
          await FirebaseFirestore.instance
              .collection('bookings')
              .doc(bookingId)
              .update({'status': 'canceled'});

          // Refresh the page after canceling
          setState(() {});
        } catch (e) {
          print('Error canceling appointment: $e');
        }
      },
    );
  }

  void _completeAppointment(String bookingId) async {
    _showConfirmationDialog(
      context: context,
      action: 'complete',
      onConfirm: () async {
        try {
          await FirebaseFirestore.instance
              .collection('bookings')
              .doc(bookingId)
              .update({'status': 'completed'});

          // Refresh the page after marking as completed
          setState(() {});
        } catch (e) {
          print('Error completing appointment: $e');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Management'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Appointments',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: fetchBookingAndUserData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child: Text('No Appointments Found'));
                      }

                      List<Map<String, dynamic>> bookingsData = snapshot.data!;

                      return SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Table(
                          columnWidths: const {
                            0: FlexColumnWidth(2),
                            1: FlexColumnWidth(2),
                            2: FlexColumnWidth(2),
                            3: FlexColumnWidth(2),
                            4: FlexColumnWidth(1),
                          },
                          border: TableBorder.all(color: Colors.grey, width: 1),
                          children: [
                            const TableRow(
                              decoration: BoxDecoration(
                                color: Colors.grey,
                              ),
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Student Name',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Date & Time',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Phone Number',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Status',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Action',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            for (var booking in bookingsData)
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(booking['name']),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(booking['dateTimeSlot']),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(booking['phone_number']),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(booking['status']),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () => _cancelAppointment(
                                              booking['bookingId']),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red),
                                          child: const Text('Cancel'),
                                        ),
                                        const SizedBox(
                                            height: 8), // Space between buttons
                                        ElevatedButton(
                                          onPressed: () => _completeAppointment(
                                              booking['bookingId']),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green),
                                          child: const Text('Completed'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
