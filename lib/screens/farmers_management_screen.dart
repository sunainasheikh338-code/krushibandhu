import 'package:flutter/material.dart';

// import '../services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FarmersManagementScreen extends StatefulWidget {
  const FarmersManagementScreen({super.key});

  @override
  State<FarmersManagementScreen> createState() =>
      _FarmersManagementScreenState();
}

class _FarmersManagementScreenState extends State<FarmersManagementScreen> {
  List<Map<String, dynamic>> farmers = [];
  List<Map<String, dynamic>> filteredFarmers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFarmers();
  }

  Future<void> _loadFarmers() async {
    setState(() {
      isLoading = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'farmer')
          .get();

      final farmerList = snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();

      if (!mounted) return;

      setState(() {
        farmers = farmerList;
        filteredFarmers = farmerList;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load farmers: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // SEARCH FARMERS
  // ============================================================

  void _searchFarmers(String query) {
    final search = query.toLowerCase().trim();

    setState(() {
      filteredFarmers = farmers.where((farmer) {
        final name = farmer['name']?.toString().toLowerCase() ?? '';

        final mobile = farmer['mobile']?.toString().toLowerCase() ?? '';

        final village = farmer['village']?.toString().toLowerCase() ?? '';

        return name.contains(search) ||
            mobile.contains(search) ||
            village.contains(search);
      }).toList();
    });
  }

  // ============================================================
  // DELETE FARMER
  // ============================================================

  Future<void> _deleteFarmer(Map<String, dynamic> farmer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Farmer'),
          content: Text('Are you sure you want to delete ${farmer['name']}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(farmer['id'].toString())
          .delete();

      await _loadFarmers();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Farmer deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete farmer: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // VIEW FARMER DETAILS
  // ============================================================

  void _showFarmerDetails(Map<String, dynamic> farmer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person, size: 55, color: Colors.green),

                const SizedBox(height: 10),

                Text(
                  farmer['name']?.toString() ?? 'Unknown Farmer',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                _detailRow(Icons.phone, 'Mobile', farmer['mobile']),

                _detailRow(Icons.location_on, 'Village', farmer['village']),

                _detailRow(Icons.landscape, 'Land', farmer['land']),

                _detailRow(Icons.grass, 'Crop', farmer['crop']),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // DETAIL ROW
  // ============================================================

  Widget _detailRow(IconData icon, String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Icon(icon, color: Colors.green),

          const SizedBox(width: 12),

          SizedBox(
            width: 80,
            child: Text(
              '$title:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(
            child: Text(
              value?.toString().isNotEmpty == true
                  ? value.toString()
                  : 'Not available',
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD SCREEN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),

      appBar: AppBar(
        title: const Text('Farmers Management'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      body: Column(
        children: [
          // TOTAL FARMERS
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade700,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                const Icon(Icons.people, color: Colors.white, size: 40),

                const SizedBox(width: 15),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Farmers',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),

                    Text(
                      '${farmers.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // SEARCH
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              onChanged: _searchFarmers,
              decoration: InputDecoration(
                hintText: 'Search by name, mobile or village',
                prefixIcon: const Icon(Icons.search, color: Colors.green),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.green, width: 2),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // FARMERS LIST
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  )
                : filteredFarmers.isEmpty
                ? const Center(
                    child: Text(
                      'No farmers found',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : RefreshIndicator(
                    color: Colors.green,
                    onRefresh: _loadFarmers,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: filteredFarmers.length,
                      itemBuilder: (context, index) {
                        final farmer = filteredFarmers[index];

                        final name =
                            farmer['name']?.toString() ?? 'Unknown Farmer';

                        final mobile =
                            farmer['mobile']?.toString() ?? 'No mobile';

                        final village =
                            farmer['village']?.toString() ?? 'No village';

                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),

                            leading: CircleAvatar(
                              backgroundColor: Colors.green.shade100,
                              child: const Icon(
                                Icons.person,
                                color: Colors.green,
                              ),
                            ),

                            title: Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 5),

                                Text('📱 $mobile'),

                                const SizedBox(height: 3),

                                Text('📍 $village'),
                              ],
                            ),

                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'view') {
                                  _showFarmerDetails(farmer);
                                } else if (value == 'delete') {
                                  _deleteFarmer(farmer);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'view',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.visibility,
                                        color: Colors.green,
                                      ),
                                      SizedBox(width: 10),
                                      Text('View Details'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red),
                                      SizedBox(width: 10),
                                      Text('Delete'),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            onTap: () {
                              _showFarmerDetails(farmer);
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
