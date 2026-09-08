import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyMarketplaceOrdersScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  const MyMarketplaceOrdersScreen({super.key, required this.user});

  String get buyerId {
    return (user["uid"] ??
            user["userId"] ??
            user["id"] ??
            user["mobile"] ??
            user["phone"] ??
            "")
        .toString()
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        title: const Text(
          "My Marketplace Orders",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: buyerId.isEmpty
          ? const Center(
              child: Text(
                "Farmer details not found.",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
              ),
            )
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection("leftover_orders")
                  .where("buyerId", isEqualTo: buyerId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        "Unable to load your marketplace orders.\n\n"
                        "${snapshot.error}",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                  );
                }

                final orders = snapshot.data?.docs ?? [];

                if (orders.isEmpty) {
                  return _emptyState();
                }

                // Sort newest orders first.
                final sortedOrders = [...orders];

                sortedOrders.sort((a, b) {
                  final aTime = a.data()["createdAt"];
                  final bTime = b.data()["createdAt"];

                  if (aTime is Timestamp && bTime is Timestamp) {
                    return bTime.compareTo(aTime);
                  }

                  return 0;
                });

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedOrders.length,
                  itemBuilder: (context, index) {
                    return _buildOrderCard(context, sortedOrders[index]);
                  },
                );
              },
            ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 90,
              color: Colors.green.shade300,
            ),
            const SizedBox(height: 20),
            const Text(
              "No Marketplace Orders",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Your leftover fertilizer purchases will appear here.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    final orderId = (data["orderId"] ?? doc.id).toString();

    final fertilizerName = (data["fertilizerName"] ?? "Unknown Fertilizer")
        .toString();

    final sellerName = (data["sellerName"] ?? "Farmer").toString();

    final quantity = (data["quantity"] as num?)?.toInt() ?? 0;

    final pricePerBag = (data["pricePerBag"] as num?)?.toDouble() ?? 0;

    final totalAmount = (data["totalAmount"] as num?)?.toDouble() ?? 0;

    final status = (data["status"] ?? "Pending").toString();

    final createdAt = data["createdAt"];

    String orderDate = "Date not available";

    if (createdAt is Timestamp) {
      final date = createdAt.toDate();

      orderDate =
          "${date.day.toString().padLeft(2, '0')}/"
          "${date.month.toString().padLeft(2, '0')}/"
          "${date.year}";
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------------------------------------------------
            // ORDER HEADER
            // ------------------------------------------------------

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.receipt_long, color: Colors.green),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Marketplace Order",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        orderId,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                _statusChip(status),
              ],
            ),

            const Divider(height: 28),

            _detailRow(Icons.eco, "Fertilizer", fertilizerName),

            _detailRow(Icons.person_outline, "Seller", sellerName),

            _detailRow(
              Icons.shopping_bag_outlined,
              "Quantity",
              "$quantity Bags",
            ),

            _detailRow(
              Icons.currency_rupee,
              "Price / Bag",
              "₹${pricePerBag.toStringAsFixed(2)}",
            ),

            _detailRow(
              Icons.payments_outlined,
              "Total Amount",
              "₹${totalAmount.toStringAsFixed(2)}",
            ),

            _detailRow(Icons.calendar_today_outlined, "Order Date", orderDate),

            const SizedBox(height: 12),

            _buildStatusMessage(status),

            _buildBuyerOrderAction(context, orderId, status),
          ],
        ),
      ),
    );
  }

  Widget _buildBuyerOrderAction(
    BuildContext context,
    String orderId,
    String status,
  ) {
    if (status == "Ready for Pickup") {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              _showCompleteConfirmation(
                context,
                orderId,
                "Picked Up & Received",
              );
            },
            icon: const Icon(Icons.inventory_2_outlined),
            label: const Text("Picked Up & Received"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
            ),
          ),
        ),
      );
    }

    if (status == "Out for Delivery") {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              _showCompleteConfirmation(
                context,
                orderId,
                "Received & Accepted",
              );
            },
            icon: const Icon(Icons.check_circle_outline),
            label: const Text("Received & Accepted"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _showCompleteConfirmation(
    BuildContext context,
    String orderId,
    String actionText,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Confirm Receipt"),
          content: Text(
            "Have you received the fertilizer and checked the quantity?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Not Yet"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                try {
                  await FirebaseFirestore.instance
                      .collection("leftover_orders")
                      .doc(orderId)
                      .update({
                        "status": "Completed",
                        "completedAt": FieldValue.serverTimestamp(),
                      });

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Order completed successfully."),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Failed to complete order: $e"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text(actionText),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.green),

          const SizedBox(width: 10),

          SizedBox(
            width: 105,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),

          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey.shade700)),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    final normalized = status.toLowerCase().trim();

    Color color;
    IconData icon;

    switch (normalized) {
      case "confirmed":
        color = Colors.blue;
        icon = Icons.check_circle_outline;
        break;

      case "ready for pickup":
        color = Colors.orange;
        icon = Icons.inventory_2_outlined;
        break;

      case "out for delivery":
        color = Colors.deepOrange;
        icon = Icons.local_shipping_outlined;
        break;

      case "completed":
        color = Colors.green;
        icon = Icons.task_alt;
        break;

      case "cancelled":
        color = Colors.red;
        icon = Icons.cancel_outlined;
        break;

      default:
        color = Colors.grey;
        icon = Icons.pending_actions;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusMessage(String status) {
    final normalized = status.toLowerCase().trim();

    String message;
    IconData icon;

    switch (normalized) {
      case "confirmed":
        message = "Your order has been confirmed.";
        icon = Icons.check_circle_outline;
        break;

      case "ready for pickup":
        message = "Your fertilizer is ready for pickup.";
        icon = Icons.inventory_2_outlined;
        break;

      case "out for delivery":
        message = "Your fertilizer is on the way.";
        icon = Icons.local_shipping_outlined;
        break;

      case "completed":
        message = "Your order has been completed.";
        icon = Icons.task_alt;
        break;

      case "cancelled":
        message = "This order has been cancelled.";
        icon = Icons.cancel_outlined;
        break;

      default:
        message = "Your order is waiting for confirmation.";
        icon = Icons.hourglass_top;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
