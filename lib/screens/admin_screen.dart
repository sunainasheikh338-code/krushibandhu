import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'farmers_management_screen.dart';
import 'admin_fertilizer_management_screen.dart';
import 'login_screen.dart';
import 'management_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,

        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (dialogContext) {
                  return AlertDialog(
                    title: const Text("Logout"),
                    content: const Text(
                      "Are you sure you want to logout?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(
                            dialogContext,
                            false,
                          );
                        },
                        child: const Text("Cancel"),
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
                        child: const Text("Logout"),
                      ),
                    ],
                  );
                },
              );

              if (shouldLogout != true) {
                return;
              }

              if (!context.mounted) {
                return;
              }

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
                    (route) => false,
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('fertilizer_bookings')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading dashboard:\n${snapshot.error}",
                textAlign: TextAlign.center,
              ),
            );
          }

          final orders = snapshot.data?.docs ?? [];

          int pendingCount = 0;
          int confirmedCount = 0;
          int readyCount = 0;
          int deliveryCount = 0;
          int completedCount = 0;

          for (final doc in orders) {
            final data = doc.data() as Map<String, dynamic>;

            final status =
                data['status']?.toString().toLowerCase().trim() ??
                    'pending';

            switch (status) {
              case 'pending':
                pendingCount++;
                break;

              case 'confirmed':
                confirmedCount++;
                break;

              case 'ready for pickup':
                readyCount++;
                break;

              case 'out for delivery':
                deliveryCount++;
                break;

              case 'completed':
                completedCount++;
                break;
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Welcome, Admin 👋",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  "Manage Krushi Bandhu activities",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  "Fertilizer Order Summary",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 14),

                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.20,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _statusCard(
                      icon: Icons.pending_actions,
                      title: "Pending",
                      count: pendingCount,
                      color: Colors.grey,
                    ),
                    _statusCard(
                      icon: Icons.check_circle_outline,
                      title: "Confirmed",
                      count: confirmedCount,
                      color: Colors.blue,
                    ),
                    _statusCard(
                      icon: Icons.inventory_2_outlined,
                      title: "Ready for Pickup",
                      count: readyCount,
                      color: Colors.orange,
                    ),
                    _statusCard(
                      icon: Icons.local_shipping_outlined,
                      title: "Out for Delivery",
                      count: deliveryCount,
                      color: Colors.deepOrange,
                    ),
                    _statusCard(
                      icon: Icons.task_alt,
                      title: "Completed",
                      count: completedCount,
                      color: Colors.green,
                    ),
                    _statusCard(
                      icon: Icons.shopping_bag_outlined,
                      title: "Total Orders",
                      count: orders.length,
                      color: Colors.teal,
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                const Text(
                  "Admin Modules",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 14),

                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.05,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // FARMERS
                    _buildCard(
                      context,
                      Icons.people,
                      "Farmers",
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const FarmersManagementScreen(),
                          ),
                        );
                      },
                    ),

                    // TRACTOR BOOKINGS
                    _buildCard(
                      context,
                      Icons.agriculture,
                      "Tractor Bookings",
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const TractorBookingsAdminScreen(),
                          ),
                        );
                      },
                    ),

                    // FERTILIZER ORDERS
                    _buildCard(
                      context,
                      Icons.shopping_bag,
                      "Fertilizer Orders",
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const FertilizerOrdersAdminScreen(),
                          ),
                        );
                      },
                    ),

                    // FERTILIZER MANAGEMENT
                    // _buildCard(
                    //   context,
                    //   Icons.eco,
                    //   "Fertilizer Management",
                    //       () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) =>
                    //         const AdminFertilizerManagementScreen(),
                    //       ),
                    //     );
                    //   },
                    // ),
                    _buildCard(
                      context,
                      Icons.settings,
                      "Management",
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ManagementScreen(),
                          ),
                        );
                      },
                    ),

                    // LABOUR
                    _buildCard(
                      context,
                      Icons.engineering,
                      "Labour Requests",
                      () {},
                    ),

                    // MARKETPLACE
                    // _buildCard(
                    //   context,
                    //   Icons.store,
                    //   "Marketplace",
                    //   () {},
                    // ),

                    // REPORTS
                    _buildCard(
                      context,
                      Icons.analytics,
                      "Reports",
                      () {},
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statusCard({
    required IconData icon,
    required String title,
    required int count,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 12,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),

            const SizedBox(height: 5),

            Text(
              "$count",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: Colors.green,
            ),

            const SizedBox(height: 12),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// TRACTOR BOOKINGS ADMIN SCREEN
// ================================================================

class TractorBookingsAdminScreen extends StatelessWidget {
  const TractorBookingsAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        title: const Text("Tractor Bookings"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tractor_bookings')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Error loading tractor bookings:\n${snapshot.error}",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No tractor bookings found.",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          final bookings = snapshot.data!.docs.toList();

          bookings.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;

            final aTime = aData['createdAt'] as Timestamp?;
            final bTime = bData['createdAt'] as Timestamp?;

            if (aTime == null && bTime == null) {
              return 0;
            }

            if (aTime == null) {
              return 1;
            }

            if (bTime == null) {
              return -1;
            }

            return bTime.compareTo(aTime);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final doc = bookings[index];

              final data = doc.data() as Map<String, dynamic>;

              final bookingId =
                  data['bookingId']?.toString() ?? doc.id;

              final farmerName =
                  data['farmerName']?.toString() ?? "Unknown Farmer";

              final farmerPhone =
                  data['farmerPhone']?.toString() ?? "Not available";

              final tractorName =
                  data['tractorName']?.toString() ?? "Tractor";

              final tractorType =
                  data['tractorType']?.toString() ?? "Not specified";

              final ownerName =
                  data['ownerName']?.toString() ?? "Unknown Owner";

              final duration =
                  data['duration']?.toString() ?? "0";

              final durationType =
                  data['durationType']?.toString() ?? "";

              final rentalOption =
                  data['rentalOption']?.toString() ?? "Tractor Only";

              final equipmentName =
                  data['equipmentName']?.toString() ?? "No Equipment";

              final equipmentPrice = _toDouble(data['equipmentPrice']);

              final labourIncluded = data['labourIncluded'] == true;

              final labourAmount = _toDouble(data['labourAmount']);

              final bookingDate =
                  data['bookingDate']?.toString() ?? "Not specified";

              final bookingTime =
                  data['bookingTime']?.toString() ?? "Not specified";

              final workLocation =
                  data['workLocation']?.toString() ?? "Not specified";

              final totalAmount =
                  _toDouble(data['totalAmount']);

              final paymentMethod =
                  data['paymentMethod']?.toString() ?? "Not specified";

              final paymentStatus =
                  data['paymentStatus']?.toString() ?? "Not specified";

              final status =
                  data['status']?.toString() ?? "Pending";

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Color(0xFFE8F5E9),
                            child: Icon(
                              Icons.agriculture,
                              color: Colors.green,
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bookingId,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 3),

                                Text(
                                  status,
                                  style: TextStyle(
                                    color: _statusColor(status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 25),

                      // _detailRow(
                      //   Icons.confirmation_number,
                      //   "Booking ID",
                      //   bookingId,
                      // ),

                      _detailRow(
                        Icons.person,
                        "Farmer",
                        farmerName,
                      ),

                      _detailRow(
                        Icons.phone,
                        "Phone",
                        farmerPhone,
                      ),

                      _detailRow(
                        Icons.agriculture,
                        "Tractor",
                        "$tractorName ($tractorType)",
                      ),

                      _detailRow(
                        Icons.person_outline,
                        "Owner",
                        ownerName,
                      ),

                      _detailRow(
                        Icons.timer_outlined,
                        "Duration",
                        "$duration $durationType",
                      ),

                      _detailRow(
                        Icons.groups,
                        "Rental",
                        rentalOption,
                      ),

                      if (equipmentName != "No Equipment") ...[
                        _detailRow(
                          Icons.construction,
                          "Equipment",
                          equipmentName,
                        ),

                        _detailRow(
                          Icons.currency_rupee,
                          "Equipment Amount",
                          "₹${equipmentPrice.toStringAsFixed(2)}",
                        ),
                      ],

                      if (labourIncluded) ...[
                        _detailRow(
                          Icons.engineering,
                          "Labour",
                          "Yes",
                        ),

                        _detailRow(
                          Icons.currency_rupee,
                          "Labour Amount",
                          "₹${labourAmount.toStringAsFixed(2)}",
                        ),
                      ] else
                        _detailRow(
                          Icons.engineering,
                          "Labour",
                          "No",
                        ),

                      _detailRow(
                        Icons.calendar_today,
                        "Booking Date",
                        bookingDate,
                      ),

                      _detailRow(
                        Icons.access_time,
                        "Booking Time",
                        bookingTime,
                      ),

                      _detailRow(
                        Icons.location_on,
                        "Work Location",
                        workLocation,
                      ),

                      _detailRow(
                        Icons.currency_rupee,
                        "Total Amount",
                        "₹${totalAmount.toStringAsFixed(2)}",
                      ),

                      _detailRow(
                        Icons.payment,
                        "Payment",
                        paymentMethod,
                      ),

                      _detailRow(
                        Icons.check_circle_outline,
                        "Payment Status",
                        paymentStatus,
                      ),

                      const SizedBox(height: 15),

                      Row(
                        children: [
                          const Icon(
                            Icons.info,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Booking Status:",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor(status).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: _statusColor(status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Container(
                      //   width: double.infinity,
                      //   padding: const EdgeInsets.symmetric(
                      //     horizontal: 14,
                      //     vertical: 12,
                      //   ),
                      //   decoration: BoxDecoration(
                      //     color:
                      //         _statusColor(status).withOpacity(0.12),
                      //     borderRadius: BorderRadius.circular(12),
                      //   ),
                      //   child: Row(
                      //     children: [
                      //       Icon(
                      //         Icons.info_outline,
                      //         color: _statusColor(status),
                      //       ),
                      //
                      //       const SizedBox(width: 10),
                      //
                      //       // const Text(
                      //       //   "Booking Status: ",
                      //       //   style: TextStyle(
                      //       //     fontWeight: FontWeight.w600,
                      //       //   ),
                      //       // ),
                      //
                      //
                      //
                      //       Expanded(
                      //         child: Text(
                      //           status,
                      //           style: TextStyle(
                      //             color: _statusColor(status),
                      //             fontWeight: FontWeight.bold,
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),

                      const SizedBox(height: 15),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 13,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.edit),
                          label: const Text(
                            "Update Booking Status",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            _showTractorStatusDialog(
                              context,
                              doc.id,
                              status,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  static Widget _detailRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.green,
          ),

          const SizedBox(width: 10),

          SizedBox(
            width: 105,
            child: Text(
              "$title:",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  static void _showTractorStatusDialog(
    BuildContext context,
    String documentId,
    String currentStatus,
  ) {
    final statuses = [
      "Pending",
      "Confirmed",
      "In Progress",
      "Completed",
      "Cancelled",
    ];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            "Update Booking Status",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: statuses.map((status) {
              final isSelected =
                  currentStatus.toLowerCase() ==
                      status.toLowerCase();

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  tileColor: isSelected
                      ? _statusColor(status).withOpacity(0.12)
                      : Colors.grey.shade100,
                  leading: Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: _statusColor(status),
                  ),
                  title: Text(
                    status,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: _statusColor(status),
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(dialogContext);

                    try {
                      final bookingRef = FirebaseFirestore
                          .instance
                          .collection('tractor_bookings')
                          .doc(documentId);

                      final bookingDoc =
                      await bookingRef.get();

                      if (!bookingDoc.exists) {
                        throw Exception(
                          'Booking not found.',
                        );
                      }

                      final bookingData =
                      bookingDoc.data();

                      if (bookingData == null) {
                        throw Exception(
                          'Booking data is empty.',
                        );
                      }

                      final tractorId =
                          bookingData['tractorId']
                              ?.toString() ??
                              '';

                      if (tractorId.isEmpty) {
                        throw Exception(
                          'Tractor ID not found in booking.',
                        );
                      }

                      final tractorRef = FirebaseFirestore
                          .instance
                          .collection('tractor_listings')
                          .doc(tractorId);

                      final bookingUpdate =
                      <String, dynamic>{
                        'status': status,
                        'updatedAt':
                        FieldValue.serverTimestamp(),
                      };

                      if (status == 'Confirmed') {
                        bookingUpdate['confirmedAt'] =
                            FieldValue.serverTimestamp();
                      }

                      if (status == 'In Progress') {
                        bookingUpdate['startedAt'] =
                            FieldValue.serverTimestamp();
                      }

                      if (status == 'Completed') {
                        bookingUpdate['completedAt'] =
                            FieldValue.serverTimestamp();
                      }

                      if (status == 'Cancelled') {
                        bookingUpdate['cancelledAt'] =
                            FieldValue.serverTimestamp();
                      }

                      await bookingRef.update(
                        bookingUpdate,
                      );

                      if (status == 'Cancelled' ||
                          status == 'Completed') {

                        await tractorRef.set(
                          {
                            'isAvailable': true,
                            'currentBookingId':
                            FieldValue.delete(),
                            'updatedAt':
                            FieldValue.serverTimestamp(),
                          },
                          SetOptions(merge: true),
                        );
                      } else {
                        await tractorRef.set(
                          {
                            'isAvailable': false,
                            'currentBookingId': documentId,
                            'updatedAt':
                            FieldValue.serverTimestamp(),
                          },
                          SetOptions(merge: true),
                        );
                      }

                      if (context.mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          SnackBar(
                            content: Text(
                              status == 'Cancelled' ||
                                  status == 'Completed'
                                  ? 'Booking status updated to $status. Tractor is now available.'
                                  : 'Booking status updated to $status. Tractor remains unavailable.',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          SnackBar(
                            content: Text(
                              "Failed to update status: $e",
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  static Color _statusColor(String status) {
    switch (status.toLowerCase().trim()) {
      case "confirmed":
        return Colors.blue;

      case "in progress":
        return Colors.orange;

      case "completed":
        return Colors.green;

      case "cancelled":
        return Colors.red;

      case "pending":
      default:
        return Colors.grey;
    }
  }
}

// ====================================================================
// FERTILIZER ORDERS ADMIN SCREEN
// ====================================================================

class FertilizerOrdersAdminScreen extends StatelessWidget {
  const FertilizerOrdersAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fertilizer Orders"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('fertilizer_bookings')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Error loading orders:\n${snapshot.error}",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No fertilizer orders found.",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final doc = orders[index];

              final data =
                  doc.data() as Map<String, dynamic>;

              final bookingId =
                  data['bookingId']?.toString() ?? doc.id;

              final farmerName =
                  data['farmerName']?.toString() ??
                      "Unknown Farmer";

              final fertilizer =
                  data['fertilizer']?.toString() ??
                      "Not specified";

              final quantity =
                  data['quantity']?.toString() ?? "0";

              final bookingType =
                  data['bookingType']?.toString() ??
                      "Not specified";

              final bookingDate =
                  data['bookingDate']?.toString() ??
                      "Not specified";

              final bookingTime =
                  data['bookingTime']?.toString() ??
                      "Not specified";

              final phone =
                  data['phone']?.toString() ??
                      data['farmerPhone']?.toString() ??
                      "Not available";

              final totalAmount =
                  data['totalAmount']?.toString() ?? "0";

              final status =
                  data['status']?.toString() ?? "Pending";

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(
                  bottom: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.receipt_long,
                            color: Colors.green,
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: Text(
                              bookingId,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 25),

                      TractorBookingsAdminScreen._detailRow(
                        Icons.person,
                        "Farmer",
                        farmerName,
                      ),

                      TractorBookingsAdminScreen._detailRow(
                        Icons.phone,
                        "Phone",
                        phone,
                      ),

                      TractorBookingsAdminScreen._detailRow(
                        Icons.eco,
                        "Fertilizer",
                        fertilizer,
                      ),

                      TractorBookingsAdminScreen._detailRow(
                        Icons.shopping_bag,
                        "Quantity",
                        "$quantity Bags",
                      ),

                      TractorBookingsAdminScreen._detailRow(
                        Icons.local_shipping,
                        "Booking Type",
                        bookingType,
                      ),

                      TractorBookingsAdminScreen._detailRow(
                        Icons.calendar_today,
                        "Date",
                        bookingDate,
                      ),

                      TractorBookingsAdminScreen._detailRow(
                        Icons.access_time,
                        "Time",
                        bookingTime,
                      ),

                      TractorBookingsAdminScreen._detailRow(
                        Icons.currency_rupee,
                        "Total Amount",
                        "₹$totalAmount",
                      ),

                      const SizedBox(height: 15),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: _fertilizerStatusColor(status)
                              .withOpacity(0.12),
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color:
                                  _fertilizerStatusColor(status),
                            ),

                            const SizedBox(width: 10),

                            const Text(
                              "Order Status: ",
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),

                            Expanded(
                              child: Text(
                                status,
                                style: TextStyle(
                                  color:
                                      _fertilizerStatusColor(
                                          status),
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.green,
                            foregroundColor:
                                Colors.white,
                          ),
                          icon: const Icon(Icons.edit),
                          label: const Text(
                            "Update Order Status",
                          ),
                          onPressed: () {
                            _showFertilizerStatusDialog(
                              context,
                              doc.id,
                              status,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  static void _showFertilizerStatusDialog(
    BuildContext context,
    String documentId,
    String currentStatus,
  ) {
    final statuses = [
      "Pending",
      "Confirmed",
      "Ready for Pickup",
      "Out for Delivery",
      "Completed",
    ];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            "Update Order Status",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: statuses.map((status) {
              final isSelected =
                  currentStatus.toLowerCase() ==
                      status.toLowerCase();

              return ListTile(
                leading: Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: _fertilizerStatusColor(status),
                ),
                title: Text(
                  status,
                  style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color:
                        _fertilizerStatusColor(status),
                  ),
                ),
                onTap: () async {
                  Navigator.pop(dialogContext);

                  try {
                    await FirebaseFirestore.instance
                        .collection('fertilizer_bookings')
                        .doc(documentId)
                        .update({
                      'status': status,
                      'updatedAt':
                          FieldValue.serverTimestamp(),
                    });

                    if (context.mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            "Order updated to $status",
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            "Failed to update: $e",
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  static Color _fertilizerStatusColor(String status) {
    switch (status.toLowerCase().trim()) {
      case "confirmed":
        return Colors.blue;

      case "ready for pickup":
        return Colors.orange;

      case "out for delivery":
        return Colors.deepOrange;

      case "completed":
        return Colors.green;

      case "pending":
      default:
        return Colors.grey;
    }
  }
}