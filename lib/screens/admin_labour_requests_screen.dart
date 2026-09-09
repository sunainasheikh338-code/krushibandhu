import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminLabourRequestsScreen extends StatelessWidget {
  const AdminLabourRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Labour Requests"),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('labour_requests')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
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
                  Icon(
                    Icons.engineering,
                    size: 70,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 15),
                  Text(
                    "No labour requests yet",
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final data =
              requests[index].data()
              as Map<String, dynamic>;

              return _buildRequestCard(data);
            },
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> data) {
    final farmerName =
        data['farmerName']?.toString() ?? 'Unknown';

    final mobile =
        data['farmerMobile']?.toString() ?? '';

    final village =
        data['village']?.toString() ?? '';

    final labourType =
        data['labourType']?.toString() ?? '';

    final numberOfLabourers =
        data['numberOfLabourers'] ?? 0;

    final wage =
        data['wagePerDay'] ?? 0;

    final totalCost =
        data['totalCost'] ?? 0;

    final workDate =
        data['workDate']?.toString() ?? '';

    final status =
        data['status']?.toString() ?? 'Pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(
                    Icons.engineering,
                    color: Colors.white,
                  ),
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

            Text(
              "Farmer: $farmerName",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 6),

            Text("Mobile: $mobile"),

            const SizedBox(height: 6),

            Text("Village: $village"),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: Text(
                    "Labourers: $numberOfLabourers",
                  ),
                ),
                Expanded(
                  child: Text(
                    "Wage: ₹$wage/day",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              "Total Cost: ₹$totalCost/day",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text("Work Date: $workDate"),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;

    switch (status) {
      case 'Confirmed':
        color = Colors.blue;
        break;

      case 'Completed':
        color = Colors.green;
        break;

      case 'Cancelled':
        color = Colors.red;
        break;

      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}