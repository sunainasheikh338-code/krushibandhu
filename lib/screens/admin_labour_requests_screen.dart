import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminLabourRequestsScreen extends StatelessWidget {
  const AdminLabourRequestsScreen({super.key});

  Future<void> _updateStatus(
    BuildContext context,
    String requestId,
    String newStatus,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('labour_requests')
          .doc(requestId)
          .update({
            'status': newStatus,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Request $newStatus"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _completeRequest(BuildContext context, String requestId) async {
    try {
      final firestore = FirebaseFirestore.instance;

      await firestore.runTransaction((transaction) async {
        final requestRef = firestore
            .collection('labour_requests')
            .doc(requestId);

        final requestSnapshot = await transaction.get(requestRef);

        if (!requestSnapshot.exists) {
          throw Exception("Labour request not found.");
        }

        final requestData = requestSnapshot.data() as Map<String, dynamic>;

        final currentStatus = requestData['status']?.toString() ?? 'Pending';

        if (currentStatus == 'Completed' || currentStatus == 'Cancelled') {
          throw Exception("This request is already $currentStatus.");
        }

        final labourTypeId = requestData['labourTypeId']?.toString() ?? '';

        final numberOfLabourers =
            (requestData['numberOfLabourers'] as num?)?.toInt() ?? 0;

        if (labourTypeId.isEmpty) {
          throw Exception("Labour type information missing.");
        }

        final labourRef = firestore
            .collection('labour_types')
            .doc(labourTypeId);

        final labourSnapshot = await transaction.get(labourRef);

        if (!labourSnapshot.exists) {
          throw Exception("Labour type not found.");
        }

        final labourData = labourSnapshot.data() as Map<String, dynamic>;

        final currentAvailable =
            (labourData['availableLabourers'] as num?)?.toInt() ?? 0;

        // Make the labourers available again.
        transaction.update(labourRef, {
          'availableLabourers': currentAvailable + numberOfLabourers,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Mark request as completed.
        transaction.update(requestRef, {
          'status': 'Completed',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Request completed and labourers are available again.",
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _cancelRequest(BuildContext context, String requestId) async {
    try {
      final firestore = FirebaseFirestore.instance;

      await firestore.runTransaction((transaction) async {
        final requestRef = firestore
            .collection('labour_requests')
            .doc(requestId);

        final requestSnapshot = await transaction.get(requestRef);

        if (!requestSnapshot.exists) {
          throw Exception("Labour request not found.");
        }

        final requestData = requestSnapshot.data() as Map<String, dynamic>;

        final currentStatus = requestData['status']?.toString() ?? 'Pending';

        // Prevent cancelling an already completed/cancelled request.
        if (currentStatus == 'Cancelled' || currentStatus == 'Completed') {
          throw Exception("This request is already $currentStatus.");
        }

        final labourTypeId = requestData['labourTypeId']?.toString() ?? '';

        final numberOfLabourers =
            (requestData['numberOfLabourers'] as num?)?.toInt() ?? 0;

        if (labourTypeId.isEmpty) {
          throw Exception("Labour type information missing.");
        }

        final labourRef = firestore
            .collection('labour_types')
            .doc(labourTypeId);

        final labourSnapshot = await transaction.get(labourRef);

        if (!labourSnapshot.exists) {
          throw Exception("Labour type not found.");
        }

        final labourData = labourSnapshot.data() as Map<String, dynamic>;

        final currentAvailable =
            (labourData['availableLabourers'] as num?)?.toInt() ?? 0;

        // Restore the reserved labourers.
        transaction.update(labourRef, {
          'availableLabourers': currentAvailable + numberOfLabourers,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Mark request as cancelled.
        transaction.update(requestRef, {
          'status': 'Cancelled',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Request cancelled and labourers restored."),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _showCancelConfirmation(
    BuildContext context,
    String requestId,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Cancel Request?"),
          content: const Text(
            "Are you sure you want to cancel this labour request?\n\n"
            "The reserved labourers will become available again.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text("No"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text("Yes, Cancel"),
            ),
          ],
        );
      },
    );

    if (confirm == true && context.mounted) {
      await _cancelRequest(context, requestId);
    }
  }

  List<Widget> _buildActions(
    BuildContext context,
    String requestId,
    String status,
  ) {
    switch (status) {
      case 'Pending':
        return [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                _updateStatus(context, requestId, 'Confirmed');
              },
              icon: const Icon(Icons.check),
              label: const Text("Confirm"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                _showCancelConfirmation(context, requestId);
              },
              icon: const Icon(Icons.close),
              label: const Text("Cancel"),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            ),
          ),
        ];

      case 'Confirmed':
        return [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                _completeRequest(context, requestId);
              },
              icon: const Icon(Icons.done_all),
              label: const Text("Complete"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                _showCancelConfirmation(context, requestId);
              },
              icon: const Icon(Icons.close),
              label: const Text("Cancel"),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            ),
          ),
        ];

      default:
        return [];
    }
  }

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

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final doc = requests[index];

              final data = doc.data() as Map<String, dynamic>;

              return _buildRequestCard(context, doc.id, data);
            },
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(
    BuildContext context,
    String requestId,
    Map<String, dynamic> data,
  ) {
    final farmerName = data['farmerName']?.toString() ?? 'Unknown';

    final mobile = data['farmerMobile']?.toString() ?? '';

    final village = data['village']?.toString() ?? '';

    final labourType = data['labourType']?.toString() ?? '';

    final numberOfLabourers = data['numberOfLabourers'] ?? 0;

    final wage = data['wagePerDay'] ?? 0;

    final totalCost = data['totalCost'] ?? 0;

    final workDate = data['workDate']?.toString() ?? '';

    final status = data['status']?.toString() ?? 'Pending';

    final actions = _buildActions(context, requestId, status);

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

            Text(
              "Farmer: $farmerName",
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 6),

            Text("Mobile: $mobile"),

            const SizedBox(height: 6),

            Text("Village: $village"),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(child: Text("Labourers: $numberOfLabourers")),
                Expanded(child: Text("Wage: ₹$wage/day")),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              "Total Cost: ₹$totalCost/day",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text("Work Date: $workDate"),

            if (actions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(children: actions),
            ],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
