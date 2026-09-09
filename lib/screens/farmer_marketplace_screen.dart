import 'package:flutter/material.dart';

class FarmerMarketplaceScreen extends StatefulWidget {
  const FarmerMarketplaceScreen({super.key});

  @override
  State<FarmerMarketplaceScreen> createState() =>
      _FarmerMarketplaceScreenState();
}

class _FarmerMarketplaceScreenState extends State<FarmerMarketplaceScreen> {
  final List<String> categories = [
    'All',
    'Grain',
    'Vegetable',
    'Fruit',
    'Pulses',
    'Oilseed',
    'Sugarcane',
    'Spices',
    'Other',
  ];

  String selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Farmer Marketplace'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.shopping_cart), text: 'BUY'),
              Tab(icon: Icon(Icons.sell), text: 'SELL'),
            ],
          ),
        ),
        body: TabBarView(children: [_buildBuyTab(), _buildSellTab()]),
      ),
    );
  }

  // ================= BUY TAB =================

  Widget _buildBuyTab() {
    return Column(
      children: [
        const SizedBox(height: 12),

        // Category filter
        SizedBox(
          height: 45,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = selectedCategory == category;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  selectedColor: Colors.green,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 20),

        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.storefront, size: 70, color: Colors.green),
                SizedBox(height: 12),
                Text(
                  'No products available',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                Text(
                  'Products from other farmers will appear here.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ================= SELL TAB =================

  Widget _buildSellTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 20),

          const Icon(Icons.agriculture, size: 70, color: Colors.green),

          const SizedBox(height: 15),

          const Text(
            'Sell Your Farm Products',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          const Text(
            'List your harvested crops or other farm products '
            'and choose your own selling price.',
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 25),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Step 2: Add selling form
              },
              icon: const Icon(Icons.add),
              label: const Text('List Product for Sale'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
