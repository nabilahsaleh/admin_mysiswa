import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AppointmentsPage extends StatefulWidget {
  @override
  _AppointmentsPageState createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  Future<List<Map<String, dynamic>>> fetchBookingAndUserData() async {
    List<Map<String, dynamic>> combinedData = [];

    QuerySnapshot bookingsSnapshot =
        await FirebaseFirestore.instance.collection('bookings').get();

    for (var doc in bookingsSnapshot.docs) {
      final bookingData = doc.data() as Map<String, dynamic>;
      final userId = bookingData['userId']; // Assuming 'userId' field exists

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      final userData = userDoc.data() as Map<String, dynamic>;

      // Format the date and time slot
      final date = (bookingData['date'] as Timestamp).toDate();
      final formattedDate = date.toLocal().toString().split(' ')[0];
      final timeSlot = bookingData['timeSlot'] ?? 'N/A';

      combinedData.add({
        'name': userData['name'] ?? 'No Name',
        'phone_number': userData['phone_number'] ?? 'No Phone Number',
        'dateTimeSlot': '$formattedDate\n$timeSlot', // Date and time slot on separate lines
        'status': bookingData['status'] ?? 'scheduled',
        'bookingId': doc.id, // Include the booking document ID for actions
      });
    }

    return combinedData;
  }

  void _cancelAppointment(String bookingId) async {
    // Implement the cancel appointment logic here
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({'status': 'canceled'});
    } catch (e) {
      print('Error canceling appointment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Management'),
        centerTitle: true, // Center the title
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4, // Add a shadow to the card
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
                        return const Center(child: Text('No Appointments Found'));
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
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Date & Time',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Phone Number',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Status',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Action',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            // Add rows dynamically
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
                                    child: ElevatedButton(
                                      onPressed: () => _cancelAppointment(booking['bookingId']),
                                      child: const Text('Cancel'),
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
