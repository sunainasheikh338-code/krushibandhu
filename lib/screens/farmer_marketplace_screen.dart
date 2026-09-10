import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FarmerMarketplaceScreen extends StatefulWidget {
  final Map<String, dynamic>? user;

  const FarmerMarketplaceScreen({super.key, this.user});

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

  final List<String> units = ['Kg', 'Quintal', 'Ton', 'Bag', 'Piece'];

  final List<String> conditions = ['Fresh', 'Other'];

  final TextEditingController productController = TextEditingController();

  final TextEditingController quantityController = TextEditingController();

  final TextEditingController priceController = TextEditingController();

  final TextEditingController descriptionController = TextEditingController();

  String selectedUnit = 'Kg';
  String selectedCondition = 'Fresh';

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

        const SizedBox(height: 12),

        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('farmer_marketplace_listings')
                .where('status', isEqualTo: 'Available')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.green),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Something went wrong.\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyMarketplace();
              }

              final currentFarmerId =
                  widget.user?['id']?.toString() ??
                  widget.user?['userId']?.toString() ??
                  '';

              final listings = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;

                final sellerId = data['sellerId']?.toString() ?? '';

                final category = data['category']?.toString() ?? '';

                // Don't show own products
                if (sellerId == currentFarmerId) {
                  return false;
                }

                // Category filter
                if (selectedCategory != 'All' && category != selectedCategory) {
                  return false;
                }

                return true;
              }).toList();

              // Sort newest first
              listings.sort((a, b) {
                final aData = a.data() as Map<String, dynamic>;

                final bData = b.data() as Map<String, dynamic>;

                final aTime = aData['createdAt'];
                final bTime = bData['createdAt'];

                if (aTime is Timestamp && bTime is Timestamp) {
                  return bTime.compareTo(aTime);
                }

                return 0;
              });

              if (listings.isEmpty) {
                return _buildEmptyMarketplace(
                  message: selectedCategory == 'All'
                      ? 'No products available.'
                      : 'No $selectedCategory products available.',
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
                itemCount: listings.length,
                itemBuilder: (context, index) {
                  final doc = listings[index];

                  final data = doc.data() as Map<String, dynamic>;

                  return _buildMarketplaceProductCard(data);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyMarketplace({String message = 'No products available.'}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.storefront, size: 70, color: Colors.green),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'Products from other farmers will appear here.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMarketplaceProductCard(Map<String, dynamic> data) {
    final productName = data['productName']?.toString() ?? 'Product';

    final category = data['category']?.toString() ?? 'Other';

    final sellerName = data['sellerName']?.toString() ?? 'Farmer';

    final village = data['village']?.toString() ?? 'Not specified';

    final condition = data['condition']?.toString() ?? 'Fresh';

    final unit = data['unit']?.toString() ?? 'Kg';

    final availableQuantity =
        (data['availableQuantity'] as num?)?.toDouble() ?? 0;

    final pricePerUnit = (data['pricePerUnit'] as num?)?.toDouble() ?? 0;

    final totalPrice = (data['totalPrice'] as num?)?.toDouble() ?? 0;

    final description = data['description']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product name + category
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.agriculture,
                    color: Colors.green,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Quantity
            _marketplaceInfoRow(
              Icons.inventory_2_outlined,
              'Available',
              '${_formatNumber(availableQuantity)} $unit',
            ),

            const SizedBox(height: 8),

            // Price
            _marketplaceInfoRow(
              Icons.currency_rupee,
              'Price',
              '₹${_formatNumber(pricePerUnit)} / $unit',
            ),

            const SizedBox(height: 8),

            // Total value
            _marketplaceInfoRow(
              Icons.calculate_outlined,
              'Total Value',
              '₹${_formatNumber(totalPrice)}',
            ),

            const SizedBox(height: 8),

            // Village
            _marketplaceInfoRow(
              Icons.location_on_outlined,
              'Pickup Village',
              village,
            ),

            const SizedBox(height: 8),

            // Seller
            _marketplaceInfoRow(Icons.person_outline, 'Seller', sellerName),

            const SizedBox(height: 8),

            // Condition
            _marketplaceInfoRow(Icons.eco_outlined, 'Condition', condition),

            if (description.isNotEmpty) ...[
              const SizedBox(height: 10),

              Text(
                description,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
            ],

            const SizedBox(height: 14),

            // Buy button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showBuyDialog(data);
                },
                icon: const Icon(Icons.shopping_cart),
                label: const Text('BUY NOW'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBuyDialog(Map<String, dynamic> data) {
    final quantityController = TextEditingController();

    final productName = data['productName']?.toString() ?? 'Product';

    final unit = data['unit']?.toString() ?? 'Kg';

    final availableQuantity =
        (data['availableQuantity'] as num?)?.toDouble() ?? 0;

    final pricePerUnit = (data['pricePerUnit'] as num?)?.toDouble() ?? 0;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final quantity =
                double.tryParse(quantityController.text.trim()) ?? 0;

            final totalAmount = quantity * pricePerUnit;

            final isValidQuantity =
                quantity > 0 && quantity <= availableQuantity;

            return AlertDialog(
              title: Text('Buy $productName'),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available: '
                      '${_formatNumber(availableQuantity)} '
                      '$unit',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Price: ₹${_formatNumber(pricePerUnit)} '
                      '/ $unit',
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: quantityController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) {
                        setDialogState(() {});
                      },
                      decoration: InputDecoration(
                        labelText: 'Quantity to buy ($unit)',
                        prefixIcon: const Icon(Icons.scale),
                        border: const OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 15),

                    if (quantity > 0)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Amount',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              '₹${_formatNumber(totalAmount)}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),

                            const SizedBox(height: 3),

                            Text(
                              '${_formatNumber(quantity)} '
                              '$unit × '
                              '₹${_formatNumber(pricePerUnit)}',
                            ),
                          ],
                        ),
                      ),

                    if (quantity > availableQuantity)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          'Only '
                          '${_formatNumber(availableQuantity)} '
                          '$unit available.',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),

                ElevatedButton(
                  onPressed: isValidQuantity
                      ? () {
                          Navigator.pop(dialogContext);
                          _purchaseMarketplaceProduct(data, quantity);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Confirm Purchase'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _purchaseMarketplaceProduct(
    Map<String, dynamic> data,
    double quantity,
  ) async {
    final listingId = data['listingId']?.toString() ?? '';

    final buyerId =
        widget.user?['id']?.toString() ??
        widget.user?['userId']?.toString() ??
        '';

    final buyerName = widget.user?['name']?.toString() ?? '';

    final buyerMobile = widget.user?['mobile']?.toString() ?? '';

    if (listingId.isEmpty || buyerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to process purchase.')),
      );
      return;
    }

    try {
      final firestore = FirebaseFirestore.instance;

      final listingRef = firestore
          .collection('farmer_marketplace_listings')
          .doc(listingId);

      final orderRef = firestore.collection('farmer_marketplace_orders').doc();

      await firestore.runTransaction((transaction) async {
        final listingSnapshot = await transaction.get(listingRef);

        if (!listingSnapshot.exists) {
          throw Exception('This product is no longer available.');
        }

        final listing = listingSnapshot.data() as Map<String, dynamic>;

        final sellerId = listing['sellerId']?.toString() ?? '';

        if (sellerId == buyerId) {
          throw Exception('You cannot buy your own product.');
        }

        final status = listing['status']?.toString() ?? '';

        if (status != 'Available') {
          throw Exception('This product is no longer available.');
        }

        final available =
            (listing['availableQuantity'] as num?)?.toDouble() ?? 0;

        final pricePerUnit = (listing['pricePerUnit'] as num?)?.toDouble() ?? 0;

        if (quantity <= 0 || quantity > available) {
          throw Exception('Requested quantity is not available.');
        }

        final remaining = available - quantity;

        final newStatus = remaining <= 0 ? 'Sold' : 'Available';

        final totalAmount = quantity * pricePerUnit;

        transaction.update(listingRef, {
          'availableQuantity': remaining,
          'status': newStatus,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        transaction.set(orderRef, {
          'orderId': orderRef.id,
          'listingId': listingId,
          'buyerId': buyerId,
          'buyerName': buyerName,
          'buyerMobile': buyerMobile,
          'sellerId': sellerId,
          'sellerName': listing['sellerName'] ?? '',
          'sellerMobile': listing['sellerMobile'] ?? '',
          'productName': listing['productName'] ?? '',
          'quantity': quantity,
          'unit': listing['unit'] ?? 'Kg',
          'pricePerUnit': pricePerUnit,
          'totalAmount': totalAmount,
          'status': 'Pending',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Purchase request placed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Widget _marketplaceInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 19, color: Colors.green),

        const SizedBox(width: 8),

        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),

        Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

  Widget _buildSellTab() {
    final sellerId =
        widget.user?['id']?.toString() ??
        widget.user?['userId']?.toString() ??
        '';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Column(
            children: [
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
                    _showSellForm();
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

              const SizedBox(height: 25),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Orders for My Listings',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),

        Expanded(
          child: sellerId.isEmpty
              ? const Center(
                  child: Text(
                    'Farmer information not found.',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                )
              : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('farmer_marketplace_orders')
                      .where('sellerId', isEqualTo: sellerId)
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
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            'Unable to load orders.\n\n'
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ),
                      );
                    }

                    final orders = snapshot.data?.docs ?? [];

                    if (orders.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 70,
                                color: Colors.green.shade300,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'No Orders Yet',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Orders for your listed products '
                                'will appear here.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final sortedOrders = [...orders];

                    sortedOrders.sort((a, b) {
                      final aTime = a.data()['createdAt'];
                      final bTime = b.data()['createdAt'];

                      if (aTime is Timestamp && bTime is Timestamp) {
                        return bTime.compareTo(aTime);
                      }

                      return 0;
                    });

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      itemCount: sortedOrders.length,
                      itemBuilder: (context, index) {
                        return _buildSellerOrderCard(sortedOrders[index]);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSellerOrderCard(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    final orderId = (data['orderId'] ?? doc.id).toString();

    final productName = (data['productName'] ?? 'Product').toString();

    final buyerName = (data['buyerName'] ?? 'Farmer').toString();

    final buyerMobile = (data['buyerMobile'] ?? '').toString();

    final quantity = (data['quantity'] as num?)?.toDouble() ?? 0;

    final unit = (data['unit'] ?? 'Kg').toString();

    final pricePerUnit = (data['pricePerUnit'] as num?)?.toDouble() ?? 0;

    final totalAmount = (data['totalAmount'] as num?)?.toDouble() ?? 0;

    final status = (data['status'] ?? 'Pending').toString();

    final buyerVillage = (data['buyerVillage'] ?? '').toString();

    final createdAt = data['createdAt'];

    String orderDate = 'Date not available';

    if (createdAt is Timestamp) {
      final date = createdAt.toDate();

      orderDate =
          '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.receipt_long, color: Colors.green),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Marketplace Order',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        orderId,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                _marketplaceOrderStatusChip(status),
              ],
            ),

            const Divider(height: 25),

            _marketplaceOrderInfoRow(Icons.agriculture, 'Product', productName),

            _marketplaceOrderInfoRow(Icons.person_outline, 'Buyer', buyerName),

            if (buyerMobile.isNotEmpty)
              if ((status.toLowerCase().trim() == "completed" ||
                      status.toLowerCase().trim() == "ready for pickup") &&
                  buyerMobile.isNotEmpty)
                _marketplaceOrderInfoRow(Icons.phone, "Mobile", buyerMobile),

            if (buyerVillage.isNotEmpty)
              _marketplaceOrderInfoRow(
                Icons.location_on_outlined,
                'Village',
                buyerVillage,
              ),

            _marketplaceOrderInfoRow(
              Icons.scale_outlined,
              'Quantity',
              '${_formatNumber(quantity)} $unit',
            ),

            _marketplaceOrderInfoRow(
              Icons.currency_rupee,
              'Price / $unit',
              '₹${_formatNumber(pricePerUnit)}',
            ),

            _marketplaceOrderInfoRow(
              Icons.payments_outlined,
              'Total Amount',
              '₹${_formatNumber(totalAmount)}',
            ),

            _marketplaceOrderInfoRow(
              Icons.calendar_today_outlined,
              'Order Date',
              orderDate,
            ),

            const SizedBox(height: 12),

            _buildSellerOrderAction(doc.id, data, status),
          ],
        ),
      ),
    );
  }

  Widget _marketplaceOrderInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.green),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildSellerOrderAction(
    String orderId,
    Map<String, dynamic> data,
    String status,
  ) {
    if (status == 'Pending') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                _confirmMarketplaceOrder(orderId);
              },
              icon: const Icon(Icons.check),
              label: const Text('Confirm'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                _cancelMarketplaceOrder(orderId, data);
              },
              icon: const Icon(Icons.close),
              label: const Text('Cancel'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
        ],
      );
    }

    if (status == 'Confirmed') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            _markMarketplaceOrderReady(orderId);
          },
          icon: const Icon(Icons.inventory_2_outlined),
          label: const Text('Ready for Pickup'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Future<void> _confirmMarketplaceOrder(String orderId) async {
    try {
      await FirebaseFirestore.instance
          .collection('farmer_marketplace_orders')
          .doc(orderId)
          .update({
            'status': 'Confirmed',
            'updatedAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order confirmed successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to confirm order: $e')));
    }
  }

  Future<void> _markMarketplaceOrderReady(String orderId) async {
    try {
      await FirebaseFirestore.instance
          .collection('farmer_marketplace_orders')
          .doc(orderId)
          .update({
            'status': 'Ready for Pickup',
            'updatedAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order marked as Ready for Pickup.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update order: $e')));
    }
  }

  Future<void> _cancelMarketplaceOrder(
    String orderId,
    Map<String, dynamic> data,
  ) async {
    try {
      final firestore = FirebaseFirestore.instance;

      final orderRef = firestore
          .collection('farmer_marketplace_orders')
          .doc(orderId);

      final listingId = data['listingId']?.toString() ?? '';

      if (listingId.isEmpty) {
        throw Exception('Listing information not found.');
      }

      final listingRef = firestore
          .collection('farmer_marketplace_listings')
          .doc(listingId);

      await firestore.runTransaction((transaction) async {
        final orderSnapshot = await transaction.get(orderRef);
        final listingSnapshot = await transaction.get(listingRef);

        if (!orderSnapshot.exists) {
          throw Exception('Order not found.');
        }

        if (!listingSnapshot.exists) {
          throw Exception('Product listing not found.');
        }

        final order = orderSnapshot.data() as Map<String, dynamic>;
        final listing = listingSnapshot.data() as Map<String, dynamic>;

        final currentStatus = order['status']?.toString() ?? '';

        if (currentStatus == 'Completed') {
          throw Exception('Completed orders cannot be cancelled.');
        }

        if (currentStatus == 'Cancelled') {
          throw Exception('This order is already cancelled.');
        }

        final orderedQuantity = (order['quantity'] as num?)?.toDouble() ?? 0;

        final currentAvailable =
            (listing['availableQuantity'] as num?)?.toDouble() ?? 0;

        final originalQuantity = (listing['quantity'] as num?)?.toDouble() ?? 0;

        final restoredQuantity = currentAvailable + orderedQuantity;

        // Don't allow available quantity to exceed original listing quantity.
        final newAvailableQuantity = restoredQuantity > originalQuantity
            ? originalQuantity
            : restoredQuantity;

        transaction.update(listingRef, {
          'availableQuantity': newAvailableQuantity,
          'status': newAvailableQuantity > 0 ? 'Available' : 'Sold',
          'updatedAt': FieldValue.serverTimestamp(),
        });

        transaction.update(orderRef, {
          'status': 'Cancelled',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order cancelled and quantity restored.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Widget _marketplaceOrderStatusChip(String status) {
    Color color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'confirmed':
        color = Colors.blue;
        icon = Icons.check_circle_outline;
        break;

      case 'ready for pickup':
        color = Colors.orange;
        icon = Icons.inventory_2_outlined;
        break;

      case 'completed':
        color = Colors.green;
        icon = Icons.task_alt;
        break;

      case 'cancelled':
        color = Colors.red;
        icon = Icons.cancel_outlined;
        break;

      default:
        color = Colors.grey;
        icon = Icons.pending_actions;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showSellForm() {
    String sellCategory = 'Grain';
    String sellUnit = 'Kg';
    String sellCondition = 'Fresh';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            double quantity = double.tryParse(quantityController.text) ?? 0;

            double price = double.tryParse(priceController.text) ?? 0;

            double total = quantity * price;

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'List Product for Sale',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Product Name
                    TextField(
                      controller: productController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                        prefixIcon: Icon(Icons.agriculture),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Category
                    DropdownButtonFormField<String>(
                      initialValue: sellCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(Icons.category),
                        border: OutlineInputBorder(),
                      ),
                      items: categories
                          .where((category) => category != 'All')
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() {
                            sellCategory = value;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 15),

                    // Quantity + Unit
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: quantityController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (_) {
                              setModalState(() {});
                            },
                            decoration: InputDecoration(
                              labelText: 'Quantity ($sellUnit)',
                              prefixIcon: const Icon(Icons.scale),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: sellUnit,
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                              border: OutlineInputBorder(),
                            ),
                            items: units
                                .map(
                                  (unit) => DropdownMenuItem(
                                    value: unit,
                                    child: Text(unit),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setModalState(() {
                                  sellUnit = value;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // Price per Unit
                    TextField(
                      controller: priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) {
                        setModalState(() {});
                      },
                      decoration: InputDecoration(
                        labelText: 'Your Selling Price (per $sellUnit)',
                        prefixText: '₹ ',
                        prefixIcon: const Icon(Icons.currency_rupee),
                        border: const OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Estimated Total
                    if (quantityController.text.isNotEmpty &&
                        priceController.text.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Estimated Total Value',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              '₹${total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              '${quantityController.text} '
                              '$sellUnit × '
                              '₹${priceController.text}/'
                              '$sellUnit',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 15),

                    // Condition
                    DropdownButtonFormField<String>(
                      initialValue: sellCondition,
                      decoration: const InputDecoration(
                        labelText: 'Condition',
                        prefixIcon: Icon(Icons.info_outline),
                        border: OutlineInputBorder(),
                      ),
                      items: conditions
                          .map(
                            (condition) => DropdownMenuItem(
                              value: condition,
                              child: Text(condition),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() {
                            sellCondition = value;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 15),

                    // Description
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Add some details about your product',
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Continue
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _saveMarketplaceListing(
                            sellCategory,
                            sellUnit,
                            sellCondition,
                          );
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Continue'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _calculateTotal() {
    setState(() {});
  }

  Future<void> _saveMarketplaceListing(
    String sellCategory,
    String sellUnit,
    String sellCondition,
  ) async {
    final productName = productController.text.trim();
    final quantity = double.tryParse(quantityController.text.trim());
    final pricePerUnit = double.tryParse(priceController.text.trim());
    final description = descriptionController.text.trim();

    if (productName.isEmpty ||
        quantity == null ||
        quantity <= 0 ||
        pricePerUnit == null ||
        pricePerUnit <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid product, quantity and price.'),
        ),
      );
      return;
    }

    final sellerId =
        widget.user?['id']?.toString() ??
        widget.user?['userId']?.toString() ??
        '';

    final sellerName = widget.user?['name']?.toString() ?? '';

    final sellerMobile = widget.user?['mobile']?.toString() ?? '';

    final village = widget.user?['village']?.toString() ?? '';

    if (sellerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Farmer information not found.')),
      );
      return;
    }

    final totalPrice = quantity * pricePerUnit;

    try {
      final listingRef = FirebaseFirestore.instance
          .collection('farmer_marketplace_listings')
          .doc();

      await listingRef.set({
        'listingId': listingRef.id,
        'sellerId': sellerId,
        'sellerName': sellerName,
        'sellerMobile': sellerMobile,
        'village': village,
        'productName': productName,
        'category': sellCategory,
        'quantity': quantity,
        'availableQuantity': quantity,
        'unit': sellUnit,
        'pricePerUnit': pricePerUnit,
        'totalPrice': totalPrice,
        'condition': sellCondition,
        'description': description,
        'status': 'Available',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.pop(context);

      productController.clear();
      quantityController.clear();
      priceController.clear();
      descriptionController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product listed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to list product: $e')));
    }
  }
}
