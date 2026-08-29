import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminTractorBookingsScreen extends StatefulWidget {
  const AdminTractorBookingsScreen({super.key});

  @override
  State<AdminTractorBookingsScreen> createState() =>
      _AdminTractorBookingsScreenState();
}

class _AdminTractorBookingsScreenState
    extends State<AdminTractorBookingsScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  String selectedFilter = 'All';

  final List<String> filters = [
    'All',
    'Pending',
    'Confirmed',
    'Completed',
    'Cancelled',
  ];

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  String _value(
    Map<String, dynamic> data,
    String key, [
    String defaultValue = 'Not available',
  ]) {
    final value =
        data[key]?.toString().trim() ?? '';

    return value.isEmpty ? defaultValue : value;
  }

  Color _statusColor(String status) {
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

  IconData _statusIcon(String status) {
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

  Future<void> _updateBookingStatus(
    String documentId,
    String status,
  ) async {
    try {
      final updateData = <String, dynamic>{
        'status': status,
        'updatedAt':
            FieldValue.serverTimestamp(),
      };

      if (status == 'Confirmed') {
        updateData['confirmedAt'] =
            FieldValue.serverTimestamp();
      }

      if (status == 'Completed') {
        updateData['completedAt'] =
            FieldValue.serverTimestamp();
      }

      if (status == 'Cancelled') {
        updateData['cancelledAt'] =
            FieldValue.serverTimestamp();
      }

      await _firestore
          .collection('tractor_bookings')
          .doc(documentId)
          .update(updateData);

      if (!mounted) return;

      _showMessage(
        'Booking status updated to $status.',
        Colors.green,
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to update booking: $e',
        Colors.red,
      );
    }
  }

  Future<void> _showStatusDialog(
    String documentId,
    String currentStatus,
  ) async {
    String selectedStatus = currentStatus;

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: const Text(
                'Update Booking Status',
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...[
                    'Pending',
                    'Confirmed',
                    'Completed',
                    'Cancelled',
                  ].map(
                    (status) {
                      return RadioListTile<String>(
                        value: status,
                        groupValue: selectedStatus,
                        activeColor: Colors.green,
                        title: Text(status),
                        onChanged: (value) {
                          if (value == null) return;

                          setDialogState(() {
                            selectedStatus = value;
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.green,
                    foregroundColor:
                        Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                      selectedStatus,
                    );
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null ||
        result == currentStatus) {
      return;
    }

    await _updateBookingStatus(
      documentId,
      result,
    );
  }

  void _showMessage(
    String message,
    Color color,
  ) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7F5),
      appBar: AppBar(
        title: const Text(
          'Tractor Bookings',
        ),
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
                  .snapshots(),
              builder: (
                context,
                snapshot,
              ) {
                if (snapshot.hasError) {
                  return _errorView(
                    snapshot.error.toString(),
                  );
                }

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child:
                        CircularProgressIndicator(
                      color: Colors.green,
                    ),
                  );
                }

                final documents =
                    snapshot.data?.docs ?? [];

                final bookings =
                    documents.where((document) {
                  final data =
                      document.data()
                          as Map<String, dynamic>;

                  if (selectedFilter == 'All') {
                    return true;
                  }

                  return data['status']
                          ?.toString()
                          .toLowerCase() ==
                      selectedFilter.toLowerCase();
                }).toList();

                bookings.sort((a, b) {
                  final aData =
                      a.data()
                          as Map<String, dynamic>;

                  final bData =
                      b.data()
                          as Map<String, dynamic>;

                  final aTime =
                      aData['createdAt'];

                  final bTime =
                      bData['createdAt'];

                  if (aTime is Timestamp &&
                      bTime is Timestamp) {
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
                    await Future.delayed(
                      const Duration(
                        milliseconds: 500,
                      ),
                    );
                  },
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(
                      16,
                      8,
                      16,
                      30,
                    ),
                    itemCount: bookings.length,
                    itemBuilder: (
                      context,
                      index,
                    ) {
                      final document =
                          bookings[index];

                      final booking =
                          document.data()
                              as Map<String, dynamic>;

                      return _bookingCard(
                        document.id,
                        booking,
                      );
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

  Widget _buildFilters() {
    return Container(
      height: 60,
      padding:
          const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: ListView.separated(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        scrollDirection:
            Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder:
            (_, __) =>
                const SizedBox(width: 8),
        itemBuilder:
            (context, index) {
          final filter = filters[index];

          final selected =
              selectedFilter == filter;

          return ChoiceChip(
            label: Text(filter),
            selected: selected,
            selectedColor:
                Colors.green.shade100,
            backgroundColor:
                Colors.white,
            labelStyle: TextStyle(
              color: selected
                  ? Colors.green.shade800
                  : Colors.black87,
              fontWeight: selected
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
            onSelected: (_) {
              setState(() {
                selectedFilter = filter;
              });
            },
          );
        },
      ),
    );
  }

  Widget _bookingCard(
    String documentId,
    Map<String, dynamic> booking,
  ) {
    final bookingId = _value(
      booking,
      'bookingId',
      documentId,
    );

    final farmerName = _value(
      booking,
      'farmerName',
      'Farmer',
    );

    final farmerPhone = _value(
      booking,
      'farmerPhone',
      '',
    );

    final tractorName = _value(
      booking,
      'tractorName',
      'Tractor',
    );

    final tractorType = _value(
      booking,
      'tractorType',
      '',
    );

    final ownerName = _value(
      booking,
      'ownerName',
      'Owner',
    );

    final bookingDate = _value(
      booking,
      'bookingDate',
      '',
    );

    final bookingTime = _value(
      booking,
      'bookingTime',
      '',
    );

    final workLocation = _value(
      booking,
      'workLocation',
      'Location not available',
    );

    final status = _value(
      booking,
      'status',
      'Pending',
    );

    final duration = _toDouble(
      booking['duration'],
    );

    final durationType = _value(
      booking,
      'durationType',
      '',
    );

    final rentalOption = _value(
      booking,
      'rentalOption',
      'Tractor Only',
    );

    final paymentMethod = _value(
      booking,
      'paymentMethod',
      '',
    );

    final paymentStatus = _value(
      booking,
      'paymentStatus',
      '',
    );

    final totalAmount = _toDouble(
      booking['totalAmount'],
    );

    final imageUrl = _value(
      booking,
      'tractorImageUrl',
      '',
    );

    final statusColor =
        _statusColor(status);

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 16,
      ),
      elevation: 2,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _tractorImage(imageUrl),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        tractorName,
                        style:
                            const TextStyle(
                          fontSize: 19,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      if (tractorType.isNotEmpty)
                        Padding(
                          padding:
                              const EdgeInsets.only(
                            top: 4,
                          ),
                          child: Text(
                            tractorType,
                            style:
                                TextStyle(
                              color: Colors.green
                                  .shade700,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ),

                      const SizedBox(height: 5),

                      Text(
                        'Owner: $ownerName',
                        style:
                            const TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                _statusChip(
                  status,
                  statusColor,
                ),
              ],
            ),

            const Divider(
              height: 28,
            ),

            const Text(
              'Farmer Details',
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            _infoRow(
              Icons.person_outline,
              farmerName,
            ),

            if (farmerPhone.isNotEmpty) ...[
              const SizedBox(height: 7),

              _infoRow(
                Icons.phone_outlined,
                farmerPhone,
              ),
            ],

            const Divider(
              height: 28,
            ),

            _infoRow(
              Icons.calendar_today_outlined,
              bookingDate.isNotEmpty
                  ? '$bookingDate${bookingTime.isNotEmpty ? ' • $bookingTime' : ''}'
                  : 'Schedule not available',
            ),

            const SizedBox(height: 8),

            _infoRow(
              Icons.access_time,
              duration > 0
                  ? '$duration ${durationType == 'Per Day' ? 'Day(s)' : 'Hour(s)'}'
                  : 'Duration not available',
            ),

            const SizedBox(height: 8),

            _infoRow(
              Icons.location_on_outlined,
              workLocation,
            ),

            const SizedBox(height: 8),

            _infoRow(
              rentalOption
                      .toLowerCase()
                      .contains('labour')
                  ? Icons.groups
                  : Icons.agriculture,
              rentalOption,
            ),

            const Divider(
              height: 28,
            ),

            Row(
              children: [
                Expanded(
                  child: _summaryItem(
                    'Payment',
                    paymentStatus.isNotEmpty
                        ? paymentStatus
                        : paymentMethod,
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
              padding:
                  const EdgeInsets.all(10),
              decoration:
                  BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius:
                    BorderRadius.circular(10),
              ),
              child: Text(
                'Booking ID: $bookingId',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      statusColor,
                  foregroundColor:
                      Colors.white,
                ),
                onPressed: () {
                  _showStatusDialog(
                    documentId,
                    status,
                  );
                },
                icon:
                    const Icon(Icons.edit),
                label: const Text(
                  'Update Status',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tractorImage(
    String imageUrl,
  ) {
    return ClipRRect(
      borderRadius:
          BorderRadius.circular(12),
      child: SizedBox(
        width: 72,
        height: 72,
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) =>
                        _imagePlaceholder(),
              )
            : _imagePlaceholder(),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color:
          Colors.green.shade50,
      child: const Icon(
        Icons.agriculture,
        size: 38,
        color: Colors.green,
      ),
    );
  }

  Widget _statusChip(
    String status,
    Color color,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration:
          BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            _statusIcon(status),
            size: 13,
            color: color,
          ),

          const SizedBox(width: 4),

          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String text,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 17,
          color: Colors.grey,
        ),

        const SizedBox(width: 9),

        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryItem(
    String title,
    String value, {
    bool amount = false,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          value,
          style: TextStyle(
            fontSize: amount ? 17 : 14,
            fontWeight:
                FontWeight.bold,
            color: amount
                ? Colors.green
                : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _emptyView() {
    final isFiltered =
        selectedFilter != 'All';

    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              Icons.agriculture_outlined,
              size: 80,
              color:
                  Colors.green.shade300,
            ),

            const SizedBox(height: 15),

            Text(
              isFiltered
                  ? 'No ${selectedFilter.toLowerCase()} bookings'
                  : 'No Tractor Bookings',
              style: const TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Tractor bookings from farmers will appear here.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorView(
    String error,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(25),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off,
              color: Colors.red,
              size: 65,
            ),

            const SizedBox(height: 15),

            const Text(
              'Unable to load bookings',
              style: TextStyle(
                fontSize: 19,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              error,
              textAlign:
                  TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
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