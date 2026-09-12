import 'package:flutter/material.dart';
import 'package:krushibandhu/screens/voice_assistant_screen.dart';
import 'package:provider/provider.dart';

import '../language/app_translations.dart';
import '../language/language_provider.dart';

import 'admin_screen.dart';
import 'ai_assistant_screen.dart';
import 'crop_reminder_screen.dart';
import 'farmer_marketplace_screen.dart';
import 'fertilizer_booking_screen.dart';
import 'labour_hiring_screen.dart';
import 'leftover_fertilizer_selling_screen.dart';
import 'login_screen.dart';
import 'multilanguage_screen.dart';
import 'my_bookings_screen.dart';
import 'my_tractor_bookings_screen.dart';
import 'profile_screen.dart';
import 'my_marketplace_orders_screen.dart';

import 'tractor_rental_screen.dart';
import 'my_labour_requests_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final lang =
        AppTranslations.translations[Provider.of<LanguageProvider>(
          context,
        ).locale.languageCode] ??
        AppTranslations.translations['en']!;

    final String role = user['role']?.toString().toLowerCase() ?? 'farmer';

    final List<Map<String, dynamic>> modules = [
      {
        'title': lang['fertilizer_booking'] ?? 'Fertilizer Booking',
        'icon': Icons.shopping_bag,
        'screen': FertilizerBookingScreen(user: user),
      },
      // {
      //   'title': lang['qr_verification'] ?? 'QR Verification',
      //   'icon': Icons.qr_code_scanner,
      //   'screen': const QRVerificationScreen(),
      // },
      {
        'title': lang['tractor_rental'] ?? 'Tractor Rental',
        'icon': Icons.agriculture,
        'screen': TractorRentalScreen(user: user),
      },
      {
        'title': lang['leftover_fertilizer'] ?? 'Leftover Fertilizer',
        'icon': Icons.inventory_2,
        'screen': LeftoverFertilizerSellingScreen(user: user),
      },
      {
        'title': lang['labour_hiring'] ?? 'Labour Hiring',
        'icon': Icons.engineering,
        'screen': LabourHiringScreen(user: user),
      },
      {
        'title': lang['crop_reminder'] ?? 'Crop Reminder',
        'icon': Icons.notifications_active,
        'screen': const CropReminderScreen(),
      },
      // {
      //   'title': lang['language'] ?? 'Language',
      //   'icon': Icons.language,
      //   'screen': const MultiLanguageScreen(),
      // },
      {
        'title': lang['voice_assistant'] ?? 'Voice Assistant',
        'icon': Icons.mic,
        'screen': VoiceAssistantScreen(user: user),
      },
      {
        'title': lang['marketplace'] ?? 'Marketplace',
        'icon': Icons.store,
        'screen': FarmerMarketplaceScreen(user: user),
      },
      // {
      //   'title': lang['credit_score'] ?? 'Credit Score',
      //   'icon': Icons.credit_score,
      //   'screen': const FarmerCreditScoreScreen(),
      // },
      // {
      //   'title': lang['profile'] ?? 'Profile',
      //   'icon': Icons.person,
      //   'screen': ProfileScreen(
      //     user: user,
      //   ),
      // },
      // {
      //   'title': 'My Bookings',
      //   'icon': Icons.receipt_long,
      //   'screen': MyBookingsScreen(
      //     user: user,
      //   ),
      // },
      // {
      //   'title': 'My Tractor Bookings',
      //   'icon': Icons.agriculture_outlined,
      //   'screen': MyTractorBookingsScreen(
      //     user: user,
      //   ),
      // },
    ];

    if (role == 'admin') {
      modules.add({
        'title': lang['admin'] ?? 'Admin',
        'icon': Icons.admin_panel_settings,
        'screen': const AdminScreen(),
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),

      appBar: AppBar(
        title: Text(
          lang['app_name'] ?? 'KrushiBandhu',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            tooltip: 'Notifications',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NotificationsScreen(user: user),
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.green),
              accountName: Text(
                user['name']?.toString() ?? 'Farmer',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(user['mobile']?.toString() ?? ''),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.green, size: 40),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.home, color: Colors.green),
              title: Text(lang['home'] ?? 'Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.support_agent, color: Colors.green),
              title: Text(lang['ai_assistant'] ?? 'AI Assistant'),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AIAssistantScreen()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.person, color: Colors.green),
              title: Text(lang['profile'] ?? 'Profile'),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProfileScreen(user: user)),
                );
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.receipt_long, color: Colors.green),
              title: const Text(
                'My Fertilizer Bookings',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MyBookingsScreen(user: user),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.agriculture, color: Colors.green),
              title: const Text(
                'My Tractor Bookings',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MyTractorBookingsScreen(user: user),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.engineering, color: Colors.green),
              title: const Text(
                'My Labour Requests',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MyLabourRequestsScreen(user: user),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.shopping_bag, color: Colors.green),
              title: const Text(
                'My Marketplace Orders',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MyMarketplaceOrdersScreen(user: user),
                  ),
                );
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.language, color: Colors.green),
              title: Text(lang['language'] ?? 'Language'),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MultiLanguageScreen(),
                  ),
                );
              },
            ),

            if (role == 'admin')
              ListTile(
                leading: const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.green,
                ),
                title: Text(
                  lang['admin'] ?? 'Admin',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminScreen()),
                  );
                },
              ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(lang['logout'] ?? 'Logout'),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: modules.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final module = modules[index];

            return Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => module['screen'] as Widget,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        module['icon'] as IconData,
                        size: 50,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        module['title'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
