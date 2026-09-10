import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyLabourRequestsScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  const MyLabourRequestsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final farmerId = user['id']?.toString() ?? user['userId']?.toString() ?? '';

    if (farmerId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("My Labour Requests"),
          backgroundColor: Colors.green,
        ),
        body: const Center(child: Text("Farmer information not found.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Labour Requests"),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('labour_requests')
            .where('farmerId', isEqualTo: farmerId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading requests:\n${snapshot.error}",
                textAlign: TextAlign.center,
              ),
            );
          }

          final requests = snapshot.data?.docs ?? [];

          if (requests.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.engineering, size: 70, color: Colors.grey),
                  SizedBox(height: 15),
                  Text(
                    "No labour requests yet",
                    style: TextStyle(fontSize: 17, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final sortedRequests = [...requests];

          sortedRequests.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;

            final aTime = aData['createdAt'] as Timestamp?;
            final bTime = bData['createdAt'] as Timestamp?;

            if (aTime == null && bTime == null) {
              return 0;
            }

            if (aTime == null) {
              return 1;
            }

            if (bTime == null) {
              return -1;
            }

            return bTime.compareTo(aTime);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedRequests.length,
            itemBuilder: (context, index) {
              final data = sortedRequests[index].data() as Map<String, dynamic>;

              return _buildRequestCard(data);
            },
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> data) {
    final labourType = data['labourType']?.toString() ?? '';

    final numberOfLabourers = data['numberOfLabourers'] ?? 0;

    final wage = data['wagePerDay'] ?? 0;

    final totalCost = data['totalCost'] ?? 0;

    final village = data['village']?.toString() ?? '';

    final workDate = data['workDate']?.toString() ?? '';

    final status = data['status']?.toString() ?? 'Pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.engineering, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    labourType,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _statusBadge(status),
              ],
            ),

            const Divider(height: 25),

            Row(
              children: [
                Expanded(child: Text("Labourers: $numberOfLabourers")),
                Expanded(child: Text("Wage: ₹$wage/day")),
              ],
            ),

            const SizedBox(height: 10),

            Text("Village: $village"),

            const SizedBox(height: 8),

            Text("Work Date: $workDate"),

            const SizedBox(height: 10),

            Text(
              "Total Cost: ₹$totalCost",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    IconData icon;

    switch (status) {
      case 'Confirmed':
        color = Colors.blue;
        icon = Icons.check_circle;
        break;

      case 'Completed':
        color = Colors.green;
        icon = Icons.done_all;
        break;

      case 'Cancelled':
        color = Colors.red;
        icon = Icons.cancel;
        break;

      default:
        color = Colors.orange;
        icon = Icons.pending;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
