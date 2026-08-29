import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class AdminFertilizerBookingsScreen extends StatelessWidget {
  const AdminFertilizerBookingsScreen({super.key});

  static const List<String> statusList = [
    'Pending',
    'Confirmed',
    'Ready for Pickup',
    'Out for Delivery',
    'Completed',
    'Cancelled',
  ];

  // ============================================================
  // STATUS COLOR
  // ============================================================

  Color _statusColor(String status) {
    switch (status.trim().toLowerCase()) {
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

      case 'pending':
      default:
        return Colors.grey;
    }
  }

  // ============================================================
  // STATUS ICON
  // ============================================================

  IconData _statusIcon(String status) {
    switch (status.trim().toLowerCase()) {
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

      case 'pending':
      default:
        return Icons.pending;
    }
  }

  // ============================================================
  // SAFE DOUBLE CONVERSION
  // ============================================================

  double _toDouble(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(
            value
                .replaceAll('₹', '')
                .replaceAll(',', '')
                .trim(),
          ) ??
          0;
    }

    return 0;
  }

  // ============================================================
  // SAFE INT CONVERSION
  // ============================================================

  int _toInt(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value.trim()) ?? 0;
    }

    return 0;
  }

  // ============================================================
  // GET TOTAL AMOUNT
  // ============================================================

  double _getTotalAmount(Map<String, dynamic> data) {
    // First: totalPrice
    final totalPrice = _toDouble(data['totalPrice']);

    if (totalPrice > 0) {
      return totalPrice;
    }

    // Second: totalAmount
    final totalAmount = _toDouble(data['totalAmount']);

    if (totalAmount > 0) {
      return totalAmount;
    }

    // Third: pricePerBag × quantity
    final pricePerBag = _toDouble(data['pricePerBag']);
    final quantity = _toInt(data['quantity']);

    if (pricePerBag > 0 && quantity > 0) {
      return pricePerBag * quantity;
    }

    return 0;
  }

  // ============================================================
  // UPDATE STATUS
  // ============================================================

  Future<void> _updateStatus(
    BuildContext context,
    String bookingId,
    String newStatus,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('fertilizer_bookings')
          .doc(bookingId)
          .update({
        'status': newStatus,
        'statusUpdatedAt': FieldValue.serverTimestamp(),
        'statusUpdatedBy': 'Admin',
      });

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Order status updated to $newStatus',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Failed to update status: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // STATUS DIALOG
  // ============================================================

  void _showStatusDialog(
    BuildContext context,
    String bookingId,
    String currentStatus,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        String selectedStatus =
            statusList.contains(currentStatus)
                ? currentStatus
                : 'Pending';

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Update Order Status',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: DropdownButtonFormField<String>(
                value: statusList.contains(selectedStatus)
                    ? selectedStatus
                    : 'Pending',
                decoration: const InputDecoration(
                  labelText: 'Order Status',
                  border: OutlineInputBorder(),
                ),
                items: statusList.map((status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Row(
                      children: [
                        Icon(
                          _statusIcon(status),
                          color: _statusColor(status),
                        ),
                        const SizedBox(width: 10),
                        Text(status),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;

                  setDialogState(() {
                    selectedStatus = value;
                  });
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    Navigator.pop(dialogContext);

                    await _updateStatus(
                      context,
                      bookingId,
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
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    // ==========================================================
    // FIREBASE PROJECT DEBUG
    // ==========================================================

    debugPrint(
      '==============================================',
    );

    debugPrint(
      '🔥 FIREBASE PROJECT: '
      '${Firebase.app().options.projectId}',
    );

    debugPrint(
      '==============================================',
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3F8),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Fertilizer Orders',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // ========================================================
      // FIRESTORE STREAM
      // ========================================================

      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('fertilizer_bookings')
            .snapshots(),

        builder: (context, snapshot) {
          // ====================================================
          // LOADING
          // ====================================================

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            debugPrint(
              '🔥 Firestore: Waiting for data...',
            );

            return const Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            );
          }

          // ====================================================
          // ERROR
          // ====================================================

          if (snapshot.hasError) {
            debugPrint(
              '🔥 FIRESTORE ERROR: ${snapshot.error}',
            );

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Error loading orders:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          }

          // ====================================================
          // NO DATA
          // ====================================================

          if (!snapshot.hasData) {
            debugPrint(
              '🔥 Firestore: snapshot has no data',
            );

            return const Center(
              child: Text(
                'No data received from Firestore.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          // ====================================================
          // DOCUMENTS
          // ====================================================

          final docs = List<
              QueryDocumentSnapshot<
                  Map<String, dynamic>>>.from(
            snapshot.data!.docs,
          );

          // ====================================================
          // DEBUG TOTAL DOCUMENTS
          // ====================================================

          debugPrint(
            '🔥 TOTAL FIRESTORE DOCUMENTS: ${docs.length}',
          );

          // ====================================================
          // DEBUG EVERY DOCUMENT
          // ====================================================

          for (final doc in docs) {
            final data = doc.data();

            final rawStatus = data['status'];

            final normalizedStatus =
                rawStatus?.toString().trim().toLowerCase() ??
                    '';

            debugPrint(
              '🔥 BOOKING: ${doc.id} '
              '| STATUS: "$rawStatus" '
              '| NORMALIZED: "$normalizedStatus"',
            );
          }

          // ====================================================
          // EMPTY COLLECTION
          // ====================================================

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'No fertilizer orders found.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          // ====================================================
          // SORT BY CREATED TIME
          // ====================================================

          docs.sort((a, b) {
            final aData = a.data();
            final bData = b.data();

            final aCreated = aData['createdAt'];
            final bCreated = bData['createdAt'];

            if (aCreated is Timestamp &&
                bCreated is Timestamp) {
              return bCreated.compareTo(aCreated);
            }

            return 0;
          });

          // ====================================================
          // TOTAL ORDERS
          // ====================================================

          final int totalOrders = docs.length;

          // ====================================================
          // PENDING ORDERS
          // ====================================================

          final int pendingOrders = docs.where((doc) {
            final rawStatus = doc.data()['status'];

            final status = rawStatus
                    ?.toString()
                    .trim()
                    .toLowerCase() ??
                '';

            return status == 'pending';
          }).length;

          // ====================================================
          // DEBUG COUNTS
          // ====================================================

          debugPrint(
            '==============================================',
          );

          debugPrint(
            '🔥 TOTAL ORDERS: $totalOrders',
          );

          debugPrint(
            '🔥 PENDING ORDERS: $pendingOrders',
          );

          debugPrint(
            '==============================================',
          );

          // ====================================================
          // MAIN UI
          // ====================================================

          return Column(
            children: [
              // ==================================================
              // SUMMARY
              // ==================================================

              Container(
                margin: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  8,
                ),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset:
                          const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _summaryItem(
                        icon: Icons.receipt_long,
                        title: 'Total Orders',
                        value:
                            totalOrders.toString(),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: Colors.grey.shade300,
                    ),
                    Expanded(
                      child: _summaryItem(
                        icon: Icons.pending_actions,
                        title: 'Pending',
                        value:
                            pendingOrders.toString(),
                      ),
                    ),
                  ],
                ),
              ),

              // ==================================================
              // ORDERS LIST
              // ==================================================

              Expanded(
                child: RefreshIndicator(
                  color: Colors.green,
                  onRefresh: () async {
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
                    itemCount: docs.length,
                    itemBuilder:
                        (context, index) {
                      final doc = docs[index];

                      return _orderCard(
                        context,
                        doc.id,
                        doc.data(),
                      );
                    },
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
  // SUMMARY ITEM
  // ============================================================

  Widget _summaryItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.green,
          size: 30,
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ORDER CARD
  // ============================================================

  Widget _orderCard(
    BuildContext context,
    String documentId,
    Map<String, dynamic> data,
  ) {
    // ==========================================================
    // BOOKING ID
    // ==========================================================

    final String bookingId =
        data['bookingId']?.toString() ??
            documentId;

    // ==========================================================
    // FARMER
    // ==========================================================

    final String farmerName =
        data['farmerName']?.toString() ?? '-';

    // ==========================================================
    // PHONE
    // ==========================================================

    final String phone =
        data['phone']?.toString() ??
            data['farmerMobile']?.toString() ??
            '-';

    // ==========================================================
    // FERTILIZER
    // ==========================================================

    final String fertilizer =
        data['fertilizer']?.toString() ?? '-';

    // ==========================================================
    // QUANTITY
    // ==========================================================

    final int quantity =
        _toInt(data['quantity']);

    // ==========================================================
    // BOOKING TYPE
    // ==========================================================

    final String bookingType =
        data['bookingType']?.toString() ??
            'Pickup';

    // ==========================================================
    // DATE
    // ==========================================================

    final String bookingDate =
        data['bookingDate']?.toString() ?? '-';

    // ==========================================================
    // TIME
    // ==========================================================

    final String bookingTime =
        data['bookingTime']?.toString() ?? '-';

    // ==========================================================
    // TOTAL AMOUNT
    // ==========================================================

    final double totalAmount =
        _getTotalAmount(data);

    // ==========================================================
    // PRICE PER BAG
    // ==========================================================

    final double pricePerBag =
        _toDouble(data['pricePerBag']);

    // ==========================================================
    // STATUS
    // ==========================================================

    final String status =
        data['status']?.toString().trim() ??
            'Pending';

    // ==========================================================
    // PAYMENT STATUS
    // ==========================================================

    final String paymentStatus =
        data['paymentStatus']?.toString() ??
            'Not Available';

    // ==========================================================
    // PAYMENT METHOD
    // ==========================================================

    final String paymentMethod =
        data['paymentMethod']?.toString() ?? '-';

    return Card(
      margin: const EdgeInsets.only(
        bottom: 20,
      ),
      elevation: 5,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // ==================================================
            // BOOKING ID
            // ==================================================

            Row(
              children: [
                const Icon(
                  Icons.receipt_long,
                  color: Colors.green,
                  size: 34,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    bookingId,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            const Divider(),

            // ==================================================
            // FARMER
            // ==================================================

            _infoRow(
              icon: Icons.person,
              label: 'Farmer',
              value: farmerName,
            ),

            // ==================================================
            // PHONE
            // ==================================================

            _infoRow(
              icon: Icons.phone,
              label: 'Phone',
              value: phone,
            ),

            // ==================================================
            // FERTILIZER
            // ==================================================

            _infoRow(
              icon: Icons.eco,
              label: 'Fertilizer',
              value: fertilizer,
            ),

            // ==================================================
            // QUANTITY
            // ==================================================

            _infoRow(
              icon: Icons.shopping_bag,
              label: 'Quantity',
              value: '$quantity Bags',
            ),

            // ==================================================
            // PRICE PER BAG
            // ==================================================

            _infoRow(
              icon: Icons.currency_rupee,
              label: 'Price/Bag',
              value:
                  '₹${pricePerBag.toStringAsFixed(0)}',
            ),

            // ==================================================
            // BOOKING TYPE
            // ==================================================

            _infoRow(
              icon: Icons.local_shipping,
              label: 'Booking Type',
              value: bookingType,
            ),

            // ==================================================
            // DATE
            // ==================================================

            _infoRow(
              icon: Icons.calendar_today,
              label: 'Date',
              value: bookingDate,
            ),

            // ==================================================
            // TIME
            // ==================================================

            _infoRow(
              icon: Icons.access_time,
              label: 'Time',
              value: bookingTime,
            ),

            // ==================================================
            // TOTAL AMOUNT
            // ==================================================

            _infoRow(
              icon: Icons.currency_rupee,
              label: 'Total Amount',
              value:
                  '₹${totalAmount.toStringAsFixed(0)}',
              valueColor: Colors.green,
              valueFontSize: 20,
            ),

            // ==================================================
            // PAYMENT METHOD
            // ==================================================

            _infoRow(
              icon: Icons.payment,
              label: 'Payment',
              value: paymentMethod,
            ),

            // ==================================================
            // PAYMENT STATUS
            // ==================================================

            _infoRow(
              icon: Icons.verified,
              label: 'Payment Status',
              value: paymentStatus,
              valueColor:
                  paymentStatus.toLowerCase() ==
                          'paid'
                      ? Colors.green
                      : Colors.orange,
            ),

            const SizedBox(height: 12),

            // ==================================================
            // CURRENT STATUS
            // ==================================================

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 18,
              ),
              decoration: BoxDecoration(
                color: _statusColor(status)
                    .withOpacity(0.08),
                borderRadius:
                    BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Icon(
                    _statusIcon(status),
                    color: _statusColor(status),
                    size: 30,
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Current Status:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            _statusColor(status),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // UPDATE BUTTON
            // ==================================================

            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton.icon(
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.green,
                  foregroundColor:
                      Colors.white,
                  elevation: 4,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),
                ),
                onPressed: () {
                  _showStatusDialog(
                    context,
                    documentId,
                    status,
                  );
                },
                icon: const Icon(
                  Icons.edit,
                  size: 26,
                ),
                label: const Text(
                  'Update Order Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    double valueFontSize = 18,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Icon(
              icon,
              color: Colors.green,
              size: 28,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: valueFontSize,
                color:
                    valueColor ??
                        Colors.black87,
                fontWeight:
                    valueColor != null
                        ? FontWeight.bold
                        : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}