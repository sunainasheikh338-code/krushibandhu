import 'package:flutter/material.dart';

import 'my_tractor_bookings_screen.dart';
import 'tractor_rental_history_screen.dart';

class TractorRentalDashboardScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  const TractorRentalDashboardScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        title: const Text(
          'Tractor Rental',
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _welcomeCard(),

            const SizedBox(height: 24),

            const Text(
              'Manage Your Rentals',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            _menuCard(
              context: context,
              title: 'My Tractor Bookings',
              subtitle:
                  'View and manage your current tractor bookings',
              icon: Icons.calendar_month,
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        MyTractorBookingsScreen(
                      user: user,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 14),

            _menuCard(
              context: context,
              title: 'Rental History',
              subtitle:
                  'View completed and cancelled bookings',
              icon: Icons.history,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        TractorRentalHistoryScreen(
                      user: user,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            const Text(
              'Booking Information',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            _infoCard(
              icon: Icons.hourglass_top,
              title: 'Pending',
              description:
                  'Your booking is waiting for owner confirmation.',
              color: Colors.orange,
            ),

            const SizedBox(height: 10),

            _infoCard(
              icon: Icons.check_circle_outline,
              title: 'Confirmed',
              description:
                  'The tractor owner has accepted your booking.',
              color: Colors.blue,
            ),

            const SizedBox(height: 10),

            _infoCard(
              icon: Icons.task_alt,
              title: 'Completed',
              description:
                  'The tractor rental service has been completed.',
              color: Colors.green,
            ),

            const SizedBox(height: 10),

            _infoCard(
              icon: Icons.cancel_outlined,
              title: 'Cancelled',
              description:
                  'The booking was cancelled.',
              color: Colors.red,
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _welcomeCard() {
    final name = user['name']?.toString().trim().isNotEmpty == true
        ? user['name'].toString()
        : user['fullName']?.toString().trim().isNotEmpty == true
            ? user['fullName'].toString()
            : 'Farmer';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            child: Icon(
              Icons.agriculture,
              size: 32,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $name',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Manage your tractor rentals and bookings easily.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 27,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                    color: color,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}