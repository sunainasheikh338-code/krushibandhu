import 'package:flutter/material.dart';
import 'admin_fertilizer_management_screen.dart';
import 'admin_tractor_management_screen.dart';
import 'admin_labour_management_screen.dart';

class ManagementScreen extends StatelessWidget {
  const ManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Management"),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          centerTitle: true,
          bottom: const TabBar(
            labelColor: Colors.white,
            dividerColor: Colors.white,
            tabs: [
              Tab(
                icon: Icon(Icons.eco),
                text: "Fertilizer",
              ),
              Tab(
                icon: Icon(Icons.agriculture),
                text: "Tractor",
              ),
              Tab(
                icon: Icon(Icons.engineering),
                text: "Labour",
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AdminFertilizerManagementScreen(),
            AdminTractorManagementScreen(),
            AdminLabourManagementScreen(),
          ],
        ),
      ),
    );
  }
}