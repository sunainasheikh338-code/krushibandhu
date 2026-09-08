import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TractorRentalHistoryScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const TractorRentalHistoryScreen({super.key, required this.user});

  @override
  State<TractorRentalHistoryScreen> createState() =>
      _TractorRentalHistoryScreenState();
}

class _TractorRentalHistoryScreenState
    extends State<TractorRentalHistoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Completed', 'Cancelled'];

  String get farmerId {
    return widget.user['id']?.toString() ?? '';
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _value(
    Map<String, dynamic> data,
    String key, [
    String defaultValue = 'Not available',
  ]) {
    final value = data[key]?.toString().trim() ?? '';

    return value.isEmpty ? defaultValue : value;
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.task_alt;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.history;
    }
  }

  String _formatTimestamp(dynamic value) {
    if (value is Timestamp) {
      final date = value.toDate();

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    if (farmerId.isEmpty) {
      return Scaffold(
        appBar: _appBar(),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(25),
            child: Text(
              'User information is not available. Please login again.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: _appBar(),
      body: Column(
        children: [
          _buildFilters(),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('tractor_bookings')
                  .where('farmerId', isEqualTo: farmerId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _errorView(snapshot.error.toString());
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  );
                }

                final documents = snapshot.data?.docs ?? [];

                final bookings = documents.where((document) {
                  final data = document.data() as Map<String, dynamic>;

                  final status = data['status']?.toString().toLowerCase() ?? '';

                  // History only contains completed
                  // and cancelled bookings.
                  if (status != 'completed' && status != 'cancelled') {
                    return false;
                  }

                  if (_selectedFilter == 'All') {
                    return true;
                  }

                  return status == _selectedFilter.toLowerCase();
                }).toList();

                bookings.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;

                  final bData = b.data() as Map<String, dynamic>;

                  final aTime = aData['updatedAt'] ?? aData['createdAt'];

                  final bTime = bData['updatedAt'] ?? bData['createdAt'];

                  if (aTime is Timestamp && bTime is Timestamp) {
                    return bTime.compareTo(aTime);
                  }

                  return 0;
                });

                if (bookings.isEmpty) {
                  return _emptyView();
                }

                return RefreshIndicator(
                  color: Colors.green,
                  onRefresh: () async {
                    setState(() {});
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final document = bookings[index];

                      final data = document.data() as Map<String, dynamic>;

                      return _historyCard(document.id, data);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      title: const Text('Tractor Rental History'),
      centerTitle: true,
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
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
            labelStyle: TextStyle(
              color: selected ? Colors.green.shade800 : Colors.black87,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
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

  Widget _historyCard(String documentId, Map<String, dynamic> booking) {
    final bookingId = _value(booking, 'bookingId', documentId);

    final tractorName = _value(booking, 'tractorName', 'Tractor');

    final tractorType = _value(booking, 'tractorType', '');

    final ownerName = _value(booking, 'ownerName', 'Owner');

    final status = _value(booking, 'status', 'Completed');

    final bookingDate = _value(booking, 'bookingDate', '');

    final bookingTime = _value(booking, 'bookingTime', '');

    final workLocation = _value(
      booking,
      'workLocation',
      'Location not available',
    );

    final duration = _toDouble(booking['duration']);

    final durationType = _value(booking, 'durationType', '');

    final totalAmount = _toDouble(booking['totalAmount']);

    final rentalOption = _value(booking, 'rentalOption', 'Tractor Only');

    final paymentStatus = _value(booking, 'paymentStatus', '');

    final imageUrl = _value(booking, 'tractorImageUrl', '');

    final statusColor = _statusColor(status);

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _tractorImage(imageUrl),

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

                      if (tractorType.isNotEmpty) ...[
                        const SizedBox(height: 4),

                        Text(
                          tractorType,
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],

                      const SizedBox(height: 6),

                      Text(
                        'Owner: $ownerName',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),

                _statusChip(status, statusColor),
              ],
            ),

            const Divider(height: 28),

            _infoRow(
              Icons.calendar_today_outlined,
              bookingDate.isNotEmpty
                  ? '$bookingDate${bookingTime.isNotEmpty ? ' • $bookingTime' : ''}'
                  : _formatTimestamp(booking['bookingDateTime']),
            ),

            const SizedBox(height: 9),

            _infoRow(
              Icons.access_time,
              duration > 0
                  ? '$duration ${durationType == 'Per Day' ? 'Day(s)' : 'Hour(s)'}'
                  : 'Duration not available',
            ),

            const SizedBox(height: 9),

            _infoRow(Icons.location_on_outlined, workLocation),

            const SizedBox(height: 9),

            _infoRow(
              rentalOption.toLowerCase().contains('labour')
                  ? Icons.groups
                  : Icons.agriculture,
              rentalOption,
            ),

            const Divider(height: 28),

            Row(
              children: [
                Expanded(
                  child: _summaryItem(
                    'Payment Status',
                    paymentStatus.isEmpty ? 'Not available' : paymentStatus,
                  ),
                ),

                Expanded(
                  child: _summaryItem(
                    'Total Amount',
                    '₹${totalAmount.toStringAsFixed(2)}',
                    amount: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Booking ID: $bookingId',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tractorImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 72,
        height: 72,
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _imagePlaceholder(),
              )
            : _imagePlaceholder(),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: Colors.green.shade50,
      child: const Icon(Icons.agriculture, color: Colors.green, size: 38),
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
          Icon(_statusIcon(status), size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 10,
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
        const SizedBox(width: 9),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
      ],
    );
  }

  Widget _summaryItem(String title, String value, {bool amount = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: amount ? 17 : 14,
            fontWeight: FontWeight.bold,
            color: amount ? Colors.green : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _emptyView() {
    final isFiltered = _selectedFilter != 'All';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 80, color: Colors.green.shade300),
            const SizedBox(height: 15),
            Text(
              isFiltered
                  ? 'No ${_selectedFilter.toLowerCase()} bookings'
                  : 'No Rental History',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Completed and cancelled tractor bookings will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, color: Colors.red, size: 65),
            const SizedBox(height: 15),
            const Text(
              'Unable to load rental history',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                setState(() {});
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
