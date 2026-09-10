import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'tractor_booking_screen.dart';

class MyTractorsScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const MyTractorsScreen({super.key, required this.user});

  @override
  State<MyTractorsScreen> createState() => _MyTractorsScreenState();
}

class _MyTractorsScreenState extends State<MyTractorsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get userId {
    return widget.user['id']?.toString() ?? '';
  }

  String get userName {
    return widget.user['name']?.toString() ??
        widget.user['fullName']?.toString() ??
        'User';
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  Future<void> _deleteTractor(String documentId, String tractorName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Tractor'),
          content: Text('Are you sure you want to delete "$tractorName"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await _firestore.collection('tractor_listings').doc(documentId).delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tractor deleted successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete tractor: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        title: const Text('My Tractors'),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: userId.isEmpty
          ? const Center(child: Text('User information not available.'))
          : StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('tractor_listings')
                  .where('ownerId', isEqualTo: userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Unable to load tractors.\n${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  );
                }

                final tractors = snapshot.data?.docs ?? [];

                if (tractors.isEmpty) {
                  return _emptyView();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tractors.length,
                  itemBuilder: (context, index) {
                    final document = tractors[index];

                    final data = document.data() as Map<String, dynamic>;

                    return _tractorCard(document.id, data);
                  },
                );
              },
            ),
    );
  }

  Widget _tractorCard(String documentId, Map<String, dynamic> tractor) {
    final tractorName = tractor['tractorName']?.toString() ?? 'Tractor';

    final tractorType = tractor['tractorType']?.toString() ?? 'Not specified';

    final village = tractor['village']?.toString() ?? 'Location not available';

    final mobile =
        tractor['mobile']?.toString() ??
        tractor['ownerPhone']?.toString() ??
        '';

    final pricePerHour = _toDouble(tractor['pricePerHour']);

    final pricePerDay = _toDouble(tractor['pricePerDay']);

    final imageUrl = tractor['imageUrl']?.toString() ?? '';

    final labourAvailable = tractor['labourAvailable'] == true;

    final labourCharge = _toDouble(tractor['labourCharge']);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 90,
                    height: 90,
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _imagePlaceholder(),
                          )
                        : _imagePlaceholder(),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tractorName,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        tractorType,
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 7),

                      _infoRow(Icons.location_on_outlined, village),

                      if (mobile.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        _infoRow(Icons.phone_outlined, mobile),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 28),

            Row(
              children: [
                Expanded(
                  child: _priceBox(
                    'Per Hour',
                    '₹${pricePerHour.toStringAsFixed(0)}',
                    Icons.access_time,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: _priceBox(
                    'Per Day',
                    '₹${pricePerDay.toStringAsFixed(0)}',
                    Icons.calendar_today,
                  ),
                ),
              ],
            ),

            if (labourAvailable) ...[
              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.groups, color: Colors.orange),

                    const SizedBox(width: 10),

                    Text(
                      'Labour Available • ₹${labourCharge.toStringAsFixed(0)} / day',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final tractorData = Map<String, dynamic>.from(tractor);

                      tractorData['documentId'] = documentId;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TractorBookingScreen(
                            tractor: tractorData,
                            user: widget.user,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.calendar_month),
                    label: const Text('Book'),
                  ),
                ),

                const SizedBox(width: 10),

                IconButton(
                  tooltip: 'Delete Tractor',
                  onPressed: () {
                    _deleteTractor(documentId, tractorName);
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: Colors.green.shade50,
      child: const Icon(Icons.agriculture, color: Colors.green, size: 45),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
      ],
    );
  }

  Widget _priceBox(String title, String price, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(height: 5),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 3),
          Text(
            price,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _emptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.agriculture_outlined,
              size: 85,
              color: Colors.green.shade300,
            ),
            const SizedBox(height: 18),
            const Text(
              'No Tractors Found',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'The tractors you add for rental will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
