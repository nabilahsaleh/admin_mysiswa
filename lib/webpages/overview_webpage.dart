import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OverviewPage extends StatefulWidget {
  @override
  _OverviewPageState createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  late Future<Map<String, dynamic>> _appointmentDataFuture;

  @override
  void initState() {
    super.initState();
    _appointmentDataFuture = fetchAppointmentData();
  }

  Future<Map<String, dynamic>> fetchAppointmentData() async {
    int canceledCount = 0;
    int completedCount = 0;
    int scheduledCount = 0;
    int inProgressCount = 0;

    QuerySnapshot bookingsSnapshot =
        await FirebaseFirestore.instance.collection('bookings').get();

    for (var doc in bookingsSnapshot.docs) {
      final bookingData = doc.data() as Map<String, dynamic>;
      final status = bookingData['status'];

      if (status == 'canceled') {
        canceledCount++;
      } else if (status == 'completed') {
        completedCount++;
      } else if (status == 'scheduled') {
        scheduledCount++;
      } else if (status == 'in-progress') {
        inProgressCount++;
      }
    }

    int totalCount =
        canceledCount + completedCount + scheduledCount + inProgressCount;

    return {
      'canceled': canceledCount,
      'completed': completedCount,
      'scheduled': scheduledCount,
      'in-progress': inProgressCount,
      'total': totalCount,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Overview'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _appointmentDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData) {
              return const Center(child: Text('No data available'));
            }

            final data = snapshot.data!;
            final canceledCount = data['canceled'];
            final completedCount = data['completed'];
            final scheduledCount = data['scheduled'];
            final inProgressCount = data['in-progress'];
            final totalCount = data['total'];

            double canceledPercentage =
                totalCount > 0 ? (canceledCount / totalCount) * 100 : 0;
            double completedPercentage =
                totalCount > 0 ? (completedCount / totalCount) * 100 : 0;
            double scheduledPercentage =
                totalCount > 0 ? (scheduledCount / totalCount) * 100 : 0;
            double inProgressPercentage =
                totalCount > 0 ? (inProgressCount / totalCount) * 100 : 0;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Big Card View with Pie Chart
                Expanded(
                  flex: 2,
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
                            'Analysis',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Enlarged Pie Chart
                          Expanded(
                            child: PieChart(
                              PieChartData(
                                sections: [
                                  PieChartSectionData(
                                    color: Colors.blue,
                                    value: canceledPercentage,
                                    title:
                                        'Canceled\n${canceledPercentage.toStringAsFixed(1)}%',
                                    radius: 210, // Adjust the radius if needed
                                    titleStyle: const TextStyle(
                                      fontSize:
                                          14, // Adjust font size as needed
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    color: Colors.red,
                                    value: completedPercentage,
                                    title:
                                        'Completed\n${completedPercentage.toStringAsFixed(1)}%',
                                    radius: 210,
                                    titleStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    color: Colors.green,
                                    value: scheduledPercentage,
                                    title:
                                        'Scheduled\n${scheduledPercentage.toStringAsFixed(1)}%',
                                    radius: 210,
                                    titleStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    color: Colors.yellow,
                                    value: inProgressPercentage,
                                    title:
                                        'In-Progress\n${inProgressPercentage.toStringAsFixed(1)}%',
                                    radius: 210,
                                    titleStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                                borderData: FlBorderData(
                                  show: false,
                                ),
                                sectionsSpace: 2,
                                centerSpaceRadius: 0,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                    width: 16), // Spacing between the big card and small cards

                // Column for Small Card Views
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      // Small Card 1: Total Appointments
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Appointments',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text('$totalCount'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16), // Spacing between cards

                      // Small Card 2: Scheduled
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Scheduled',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text('$scheduledCount'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Small Card 3: Completed
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Completed',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text('$completedCount'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16), // Spacing between cards

                      // Small Card 4: Canceled
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Canceled',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text('$canceledCount'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16), // Spacing between cards

                      // Small Card 5: In-Progress
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'In-Progress',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text('$inProgressCount'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
