import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderStatusScreen extends StatelessWidget {
  final String bookingId;

  const OrderStatusScreen({
    super.key,
    required this.bookingId,
  });

  // ============================================================
  // STATUS COLOR
  // ============================================================

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.blue;

      case 'ready for pickup':
        return Colors.orange;

      case 'out for delivery':
        return Colors.deepOrange;

      case 'completed':
        return Colors.green;

      case 'cancelled':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  // ============================================================
  // STATUS ICON
  // ============================================================

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle;

      case 'ready for pickup':
        return Icons.inventory_2;

      case 'out for delivery':
        return Icons.local_shipping;

      case 'completed':
        return Icons.done_all;

      case 'cancelled':
        return Icons.cancel;

      default:
        return Icons.pending;
    }
  }

  // ============================================================
  // STATUS MESSAGE
  // ============================================================

  String _statusMessage(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Your fertilizer booking has been confirmed by the admin.';

      case 'ready for pickup':
        return 'Your fertilizer is ready for pickup.';

      case 'out for delivery':
        return 'Your fertilizer order is currently out for delivery.';

      case 'completed':
        return 'Your fertilizer booking has been completed successfully.';

      case 'cancelled':
        return 'This fertilizer booking has been cancelled.';

      default:
        return 'Your booking is being processed.';
    }
  }

  // ============================================================
  // STATUS INDEX
  // ============================================================

  int _statusIndex(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 0;

      case 'ready for pickup':
        return 1;

      case 'out for delivery':
        return 2;

      case 'completed':
        return 3;

      default:
        return -1;
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: const Text(
          'Order Status',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('fertilizer_bookings')
            .doc(bookingId)
            .snapshots(),

        builder: (context, snapshot) {
          // ======================================================
          // LOADING
          // ======================================================

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            );
          }

          // ======================================================
          // ERROR
          // ======================================================

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Error loading booking:\n\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 15,
                  ),
                ),
              ),
            );
          }

          // ======================================================
          // BOOKING NOT FOUND
          // ======================================================

          if (!snapshot.hasData ||
              !snapshot.data!.exists) {
            return const Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 70,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Booking not found',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }

          // ======================================================
          // FIRESTORE DATA
          // ======================================================

          final data =
              snapshot.data!.data()
                  as Map<String, dynamic>;

          final String status =
              data['status']?.toString() ??
                  'Pending';

          final String farmerName =
              data['farmerName']?.toString() ?? '-';

          final String fertilizer =
              data['fertilizer']?.toString() ?? '-';

          final int quantity =
              (data['quantity'] as num?)?.toInt() ?? 0;

          final String bookingType =
              data['bookingType']?.toString() ?? '-';

          final String bookingDate =
              data['bookingDate']?.toString() ?? '-';

          final String bookingTime =
              data['bookingTime']?.toString() ?? '-';

          final String phone =
              data['phone']?.toString() ?? '-';

          final String village =
              data['village']?.toString() ?? '-';

          final num totalPrice =
              (data['totalPrice'] as num?) ?? 0;

          final int currentIndex =
              _statusIndex(status);

          // ======================================================
          // MAIN CONTENT
          // ======================================================

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                // ==================================================
                // BOOKING ID
                // ==================================================

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius:
                        BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.green.shade200,
                    ),
                  ),

                  child: Column(
                    children: [
                      const Text(
                        'Booking ID',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        bookingId,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ==================================================
                // CURRENT STATUS
                // ==================================================

                Card(
                  elevation: 4,

                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(18),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(22),

                    child: Column(
                      children: [

                        Container(
                          width: 85,
                          height: 85,

                          decoration: BoxDecoration(
                            color: _statusColor(status)
                                .withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),

                          child: Icon(
                            _statusIcon(status),
                            size: 52,
                            color:
                                _statusColor(status),
                          ),
                        ),

                        const SizedBox(height: 14),

                        const Text(
                          'Current Order Status',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          status,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color:
                                _statusColor(status),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          _statusMessage(status),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // ==================================================
                // ORDER PROGRESS
                // ==================================================

                const Text(
                  'Order Progress',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                _progressTimeline(
                  currentIndex,
                  status,
                ),

                const SizedBox(height: 25),

                // ==================================================
                // BOOKING DETAILS
                // ==================================================

                const Text(
                  'Booking Details',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                _detailCard(
                  Icons.person,
                  'Farmer Name',
                  farmerName,
                ),

                _detailCard(
                  Icons.phone,
                  'Phone Number',
                  phone,
                ),

                _detailCard(
                  Icons.location_on,
                  'Village',
                  village,
                ),

                _detailCard(
                  Icons.eco,
                  'Fertilizer',
                  fertilizer,
                ),

                _detailCard(
                  Icons.shopping_bag,
                  'Quantity',
                  '$quantity Bags',
                ),

                _detailCard(
                  Icons.local_shipping,
                  'Booking Type',
                  bookingType,
                ),

                _detailCard(
                  Icons.calendar_today,
                  'Booking Date',
                  bookingDate,
                ),

                _detailCard(
                  Icons.access_time,
                  'Booking Time',
                  bookingTime,
                ),

                _detailCard(
                  Icons.currency_rupee,
                  'Total Amount',
                  '₹${totalPrice.toStringAsFixed(0)}',
                  valueColor: Colors.green,
                ),

                const SizedBox(height: 25),

                // ==================================================
                // LIVE UPDATE MESSAGE
                // ==================================================

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius:
                        BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.blue.shade100,
                    ),
                  ),

                  child: const Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Icon(
                        Icons.sync,
                        color: Colors.blue,
                        size: 24,
                      ),

                      SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          'Order status updates automatically '
                          'when the admin changes your booking status.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // ==================================================
                // CANCELLED MESSAGE
                // ==================================================

                if (status.toLowerCase() ==
                    'cancelled')
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius:
                          BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.red.shade200,
                      ),
                    ),

                    child: const Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        Icon(
                          Icons.cancel,
                          color: Colors.red,
                        ),

                        SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            'This booking has been cancelled.',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // PROGRESS TIMELINE
  // ============================================================

  Widget _progressTimeline(
    int currentIndex,
    String status,
  ) {
    final List<Map<String, dynamic>> steps = [
      {
        'title': 'Confirmed',
        'icon': Icons.check_circle,
      },
      {
        'title': 'Ready for Pickup',
        'icon': Icons.inventory_2,
      },
      {
        'title': 'Out for Delivery',
        'icon': Icons.local_shipping,
      },
      {
        'title': 'Completed',
        'icon': Icons.done_all,
      },
    ];

    if (status.toLowerCase() == 'pending') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius:
              BorderRadius.circular(15),
          border: Border.all(
            color: Colors.orange.shade200,
          ),
        ),

        child: const Row(
          children: [

            Icon(
              Icons.pending_actions,
              color: Colors.orange,
              size: 30,
            ),

            SizedBox(width: 12),

            Expanded(
              child: Text(
                'Waiting for admin confirmation',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: List.generate(
        steps.length,
        (index) {
          final bool completed =
              currentIndex >= index;

          final bool isCurrent =
              currentIndex == index;

          final bool isLast =
              index == steps.length - 1;

          return Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              // ----------------------------------------------
              // ICON + LINE
              // ----------------------------------------------

              SizedBox(
                width: 45,

                child: Column(
                  children: [

                    Container(
                      width: 38,
                      height: 38,

                      decoration: BoxDecoration(
                        color: completed
                            ? Colors.green
                            : Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),

                      child: Icon(
                        steps[index]['icon']
                            as IconData,
                        color: completed
                            ? Colors.white
                            : Colors.grey.shade600,
                        size: 21,
                      ),
                    ),

                    if (!isLast)
                      Container(
                        width: 3,
                        height: 45,
                        color: currentIndex > index
                            ? Colors.green
                            : Colors.grey.shade300,
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // ----------------------------------------------
              // STEP TEXT
              // ----------------------------------------------

              Expanded(
                child: Container(
                  margin:
                      const EdgeInsets.only(bottom: 15),

                  padding:
                      const EdgeInsets.all(13),

                  decoration: BoxDecoration(
                    color: isCurrent
                        ? Colors.green.shade50
                        : Colors.white,

                    borderRadius:
                        BorderRadius.circular(12),

                    border: Border.all(
                      color: isCurrent
                          ? Colors.green.shade200
                          : Colors.grey.shade200,
                    ),
                  ),

                  child: Row(
                    children: [

                      Expanded(
                        child: Text(
                          steps[index]['title']
                              as String,

                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                                completed
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                            color: completed
                                ? Colors.green.shade800
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),

                      if (completed)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // DETAIL CARD
  // ============================================================

  Widget _detailCard(
    IconData icon,
    String title,
    String value, {
    Color valueColor = Colors.black87,
  }) {
    return Card(
      margin:
          const EdgeInsets.only(bottom: 10),
      elevation: 1,

      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(12),
      ),

      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.green,
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),

        subtitle: Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ),
    );
  }
}