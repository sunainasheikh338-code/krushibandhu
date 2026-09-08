import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TractorOwnerBookingsScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const TractorOwnerBookingsScreen({super.key, required this.user});

  @override
  State<TractorOwnerBookingsScreen> createState() =>
      _TractorOwnerBookingsScreenState();
}

class _TractorOwnerBookingsScreenState
    extends State<TractorOwnerBookingsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'Pending',
    'Confirmed',
    'Completed',
    'Cancelled',
  ];

  String get ownerId {
    return widget.user['id']?.toString() ?? '';
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _getValue(
    Map<String, dynamic> data,
    String key, [
    String defaultValue = 'Not available',
  ]) {
    final value = data[key]?.toString().trim() ?? '';
    return value.isEmpty ? defaultValue : value;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'completed':
        return Icons.task_alt;
      case 'cancelled':
        return Icons.cancel_outlined;
      case 'pending':
      default:
        return Icons.hourglass_top;
    }
  }

  Future<void> _updateBookingStatus(String documentId, String status) async {
    try {
      await _firestore.collection('tractor_bookings').doc(documentId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking $status successfully.'),
          backgroundColor: status == 'Cancelled' ? Colors.red : Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update booking: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmStatusChange(String documentId, String newStatus) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('$newStatus Booking'),
          content: Text(
            'Are you sure you want to mark this booking as $newStatus?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('No'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: newStatus == 'Cancelled'
                    ? Colors.red
                    : Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _updateBookingStatus(documentId, newStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (ownerId.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7F5),
        appBar: AppBar(
          title: const Text('Tractor Booking Requests'),
          centerTitle: true,
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('User information is not available.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        title: const Text('Booking Requests'),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildFilters(),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('tractor_bookings')
                  .where('ownerId', isEqualTo: ownerId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Unable to load booking requests.\n${snapshot.error}',
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

                final documents = snapshot.data?.docs ?? [];

                final bookings = documents.where((document) {
                  final data = document.data() as Map<String, dynamic>;

                  if (_selectedFilter == 'All') {
                    return true;
                  }

                  return data['status']?.toString().toLowerCase() ==
                      _selectedFilter.toLowerCase();
                }).toList();

                bookings.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;

                  final bData = b.data() as Map<String, dynamic>;

                  final aTime = aData['bookingDateTime'];

                  final bTime = bData['bookingDateTime'];

                  if (aTime is Timestamp && bTime is Timestamp) {
                    return bTime.compareTo(aTime);
                  }

                  return 0;
                });

                if (bookings.isEmpty) {
                  return _emptyView();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final document = bookings[index];

                    final data = document.data() as Map<String, dynamic>;

                    return _bookingCard(document.id, data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final selected = _selectedFilter == filter;

          return ChoiceChip(
            label: Text(filter),
            selected: selected,
            selectedColor: Colors.green.shade100,
            backgroundColor: Colors.white,
            onSelected: (_) {
              setState(() {
                _selectedFilter = filter;
              });
            },
          );
        },
      ),
    );
  }

  Widget _bookingCard(String documentId, Map<String, dynamic> booking) {
    final bookingId = _getValue(booking, 'bookingId', documentId);

    final tractorName = _getValue(booking, 'tractorName', 'Tractor');

    final farmerName = _getValue(booking, 'farmerName', 'Farmer');

    final farmerPhone = _getValue(booking, 'farmerPhone', '');

    final workLocation = _getValue(
      booking,
      'workLocation',
      'Location not available',
    );

    final status = _getValue(booking, 'status', 'Pending');

    final bookingDate = _getValue(booking, 'bookingDate', '');

    final bookingTime = _getValue(booking, 'bookingTime', '');

    final duration = _toDouble(booking['duration']);

    final durationType = _getValue(booking, 'durationType', '');

    final rentalOption = _getValue(booking, 'rentalOption', 'Tractor Only');

    final totalAmount = _toDouble(booking['totalAmount']);

    final paymentStatus = _getValue(booking, 'paymentStatus', 'Not available');

    final statusColor = _getStatusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 25,
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Icon(Icons.agriculture, color: Colors.green, size: 28),
                ),

                const SizedBox(width: 12),

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

                      const SizedBox(height: 4),

                      Text(
                        'Booking ID: $bookingId',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                _statusChip(status, statusColor),
              ],
            ),

            const Divider(height: 28),

            _infoRow(Icons.person_outline, 'Farmer: $farmerName'),

            if (farmerPhone.isNotEmpty) ...[
              const SizedBox(height: 8),
              _infoRow(Icons.phone_outlined, farmerPhone),
            ],

            const SizedBox(height: 8),

            _infoRow(
              Icons.calendar_today,
              bookingDate.isNotEmpty
                  ? '$bookingDate${bookingTime.isNotEmpty ? ' • $bookingTime' : ''}'
                  : 'Date not available',
            ),

            const SizedBox(height: 8),

            _infoRow(
              Icons.access_time,
              duration > 0
                  ? '${duration.toStringAsFixed(duration % 1 == 0 ? 0 : 1)} $durationType'
                  : 'Duration not available',
            ),

            const SizedBox(height: 8),

            _infoRow(Icons.location_on_outlined, workLocation),

            const SizedBox(height: 8),

            _infoRow(
              rentalOption.toLowerCase().contains('labour')
                  ? Icons.groups
                  : Icons.agriculture,
              rentalOption,
            ),

            const Divider(height: 28),

            Row(
              children: [
                Expanded(child: _summaryItem('Payment', paymentStatus)),
                Expanded(
                  child: _summaryItem(
                    'Amount',
                    '₹${totalAmount.toStringAsFixed(2)}',
                    highlight: true,
                  ),
                ),
              ],
            ),

            if (status.toLowerCase() == 'pending') ...[
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _confirmStatusChange(documentId, 'Cancelled');
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _confirmStatusChange(documentId, 'Confirmed');
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Accept'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            if (status.toLowerCase() == 'confirmed') ...[
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _confirmStatusChange(documentId, 'Completed');
                  },
                  icon: const Icon(Icons.task_alt),
                  label: const Text('Mark as Completed'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getStatusIcon(status), size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 17, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
      ],
    );
  }

  Widget _summaryItem(String title, String value, {bool highlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: highlight ? 17 : 14,
            fontWeight: FontWeight.bold,
            color: highlight ? Colors.green : Colors.black87,
          ),
        ),
      ],
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
              Icons.event_note_outlined,
              size: 85,
              color: Colors.green.shade300,
            ),
            const SizedBox(height: 18),
            Text(
              _selectedFilter == 'All'
                  ? 'No Booking Requests'
                  : 'No ${_selectedFilter} Bookings',
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Booking requests for your tractors will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
