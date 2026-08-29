import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyBookingsScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const MyBookingsScreen({
    super.key,
    required this.user,
  });

  @override
  State<MyBookingsScreen> createState() =>
      _MyBookingsScreenState();
}

class _MyBookingsScreenState
    extends State<MyBookingsScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  String selectedFilter = 'All';

  final List<String> filters = [
    'All',
    'Pending',
    'Confirmed',
    'Ready for Pickup',
    'Out for Delivery',
    'Completed',
    'Cancelled',
  ];

  String get userId {
    return widget.user['uid']?.toString() ??
        widget.user['userId']?.toString() ??
        '';
  }

  String get userMobile {
    return widget.user['mobile']?.toString() ??
        widget.user['phone']?.toString() ??
        '';
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  String _getValue(
    Map<String, dynamic> data,
    List<String> keys, {
    String defaultValue = '',
  }) {
    for (final key in keys) {
      final value = data[key];

      if (value != null &&
          value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return defaultValue;
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.blue;

      case 'ready for pickup':
        return Colors.deepPurple;

      case 'out for delivery':
        return Colors.orange;

      case 'completed':
        return Colors.green;

      case 'cancelled':
        return Colors.red;

      case 'pending':
      default:
        return Colors.amber.shade800;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle_outline;

      case 'ready for pickup':
        return Icons.inventory_2_outlined;

      case 'out for delivery':
        return Icons.local_shipping_outlined;

      case 'completed':
        return Icons.task_alt;

      case 'cancelled':
        return Icons.cancel_outlined;

      case 'pending':
      default:
        return Icons.hourglass_top;
    }
  }

  Future<void> _cancelBooking(
    String documentId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Cancel Booking',
          ),
          content: const Text(
            'Are you sure you want to cancel this fertilizer booking?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('No'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'Yes, Cancel',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _firestore
          .collection('fertilizer_bookings')
          .doc(documentId)
          .update({
        'status': 'Cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      _showMessage(
        'Booking cancelled successfully.',
        Colors.green,
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to cancel booking: $e',
        Colors.red,
      );
    }
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
          'My Bookings',
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
                  .collection('fertilizer_bookings')
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

                final myBookings =
                    documents.where((document) {
                  final data = document.data()
                      as Map<String, dynamic>;

                  final bookingUserId =
                      _getValue(
                    data,
                    [
                      'farmerId',
                      'userId',
                      'uid',
                    ],
                  );

                  final bookingMobile =
                      _getValue(
                    data,
                    [
                      'farmerMobile',
                      'mobile',
                      'phone',
                    ],
                  );

                  final belongsToUser =
                      bookingUserId == userId ||
                          (bookingUserId.isEmpty &&
                              userMobile.isNotEmpty &&
                              bookingMobile ==
                                  userMobile);

                  if (!belongsToUser) {
                    return false;
                  }

                  if (selectedFilter == 'All') {
                    return true;
                  }

                  final status = _getValue(
                    data,
                    ['status'],
                    defaultValue: 'Pending',
                  );

                  return status.toLowerCase() ==
                      selectedFilter.toLowerCase();
                }).toList();

                myBookings.sort((a, b) {
                  final aData =
                      a.data() as Map<String, dynamic>;

                  final bData =
                      b.data() as Map<String, dynamic>;

                  final aTime = aData['createdAt'];
                  final bTime = bData['createdAt'];

                  if (aTime is Timestamp &&
                      bTime is Timestamp) {
                    return bTime.compareTo(aTime);
                  }

                  return 0;
                });

                if (myBookings.isEmpty) {
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
                    itemCount:
                        myBookings.length,
                    itemBuilder:
                        (context, index) {
                      final document =
                          myBookings[index];

                      final data =
                          document.data()
                              as Map<String, dynamic>;

                      return _bookingCard(
                        document.id,
                        data,
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
    final bookingId = _getValue(
      booking,
      [
        'bookingId',
        'orderId',
      ],
      defaultValue: documentId,
    );

    final status = _getValue(
      booking,
      ['status'],
      defaultValue: 'Pending',
    );

    final fertilizerName = _getValue(
      booking,
      [
        'fertilizerName',
        'productName',
        'name',
      ],
      defaultValue: 'Fertilizer',
    );

    final fertilizerType = _getValue(
      booking,
      [
        'fertilizerType',
        'type',
      ],
    );

    final quantity = _getValue(
      booking,
      [
        'quantity',
        'bags',
      ],
      defaultValue: 'Not specified',
    );

    final paymentMethod = _getValue(
      booking,
      ['paymentMethod'],
      defaultValue: 'Not selected',
    );

    final paymentStatus = _getValue(
      booking,
      ['paymentStatus'],
      defaultValue: '',
    );

    final bookingDate = _getValue(
      booking,
      ['bookingDate'],
    );

    final slotTime = _getValue(
      booking,
      [
        'slotTime',
        'bookingTime',
      ],
    );

    final totalAmount = _toDouble(
      booking['totalAmount'] ??
          booking['totalPrice'] ??
          booking['paidAmount'] ??
          booking['amount'],
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
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color:
                        Colors.green.shade50,
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),
                  child: const Icon(
                    Icons.shopping_bag,
                    color: Colors.green,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        fertilizerName,
                        style:
                            const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      if (fertilizerType
                          .isNotEmpty)
                        Padding(
                          padding:
                              const EdgeInsets
                                  .only(
                            top: 4,
                          ),
                          child: Text(
                            fertilizerType,
                            style: TextStyle(
                              color: Colors
                                  .green.shade700,
                              fontWeight:
                                  FontWeight.w500,
                            ),
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

            _infoRow(
              Icons.shopping_cart_outlined,
              'Quantity: $quantity',
            ),

            const SizedBox(height: 9),

            if (bookingDate.isNotEmpty)
              _infoRow(
                Icons.calendar_today,
                slotTime.isNotEmpty
                    ? '$bookingDate • $slotTime'
                    : bookingDate,
              ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _detailBox(
                    'Payment',
                    paymentStatus.isNotEmpty
                        ? paymentStatus
                        : paymentMethod,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _detailBox(
                    'Total Amount',
                    totalAmount > 0
                        ? '₹${totalAmount.toStringAsFixed(2)}'
                        : 'Not available',
                    isAmount: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(10),
              decoration: BoxDecoration(
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

            if (status.toLowerCase() ==
                'pending') ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style:
                      OutlinedButton.styleFrom(
                    foregroundColor:
                        Colors.red,
                    side:
                        const BorderSide(
                      color: Colors.red,
                    ),
                  ),
                  onPressed: () {
                    _cancelBooking(
                      documentId,
                    );
                  },
                  icon:
                      const Icon(
                    Icons.cancel_outlined,
                  ),
                  label: const Text(
                    'Cancel Booking',
                  ),
                ),
              ),
            ],
          ],
        ),
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
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
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
          size: 18,
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

  Widget _detailBox(
    String title,
    String value, {
    bool isAmount = false,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius:
            BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontWeight:
                  FontWeight.bold,
              fontSize:
                  isAmount ? 16 : 13,
              color: isAmount
                  ? Colors.green
                  : Colors.black87,
            ),
          ),
        ],
      ),
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
              Icons.receipt_long,
              size: 80,
              color:
                  Colors.green.shade300,
            ),
            const SizedBox(height: 15),
            Text(
              isFiltered
                  ? 'No ${selectedFilter.toLowerCase()} bookings'
                  : 'No Fertilizer Bookings',
              style: const TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your fertilizer bookings will appear here.',
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
              child: const Text(
                'Retry',
              ),
            ),
          ],
        ),
      ),
    );
  }
}