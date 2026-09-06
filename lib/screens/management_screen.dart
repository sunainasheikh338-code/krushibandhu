import 'package:flutter/material.dart';
import 'admin_fertilizer_management_screen.dart';
import 'admin_tractor_management_screen.dart';

class ManagementScreen extends StatelessWidget {
  const ManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Management"),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.eco),
                text: "Fertilizer",
              ),
              Tab(
                icon: Icon(Icons.agriculture),
                text: "Tractor",
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AdminFertilizerManagementScreen(),
            AdminTractorManagementScreen(),
          ],
        ),
      ),
    );
  }
}