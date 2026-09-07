import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LeftoverFertilizerSellingScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const LeftoverFertilizerSellingScreen({super.key, required this.user});

  @override
  State<LeftoverFertilizerSellingScreen> createState() =>
      _LeftoverFertilizerSellingScreenState();
}

class _LeftoverFertilizerSellingScreenState
    extends State<LeftoverFertilizerSellingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _quantityController = TextEditingController();

  final TextEditingController _detailsController = TextEditingController();

  String? _selectedFertilizer;
  String _condition = "Good";

  int _availableQuantity = 0;
  double _originalPrice = 0;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    _quantityController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _quantityController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  String get farmerMobile {
    return (widget.user["mobile"] ??
            widget.user["phone"] ??
            widget.user["farmerMobile"] ??
            "")
        .toString()
        .trim();
  }

  String get farmerName {
    return (widget.user["name"] ??
            widget.user["farmerName"] ??
            widget.user["fullName"] ??
            "Farmer")
        .toString()
        .trim();
  }

  String get farmerVillage {
    return (widget.user["village"] ?? "").toString().trim();
  }

  double get sellingPrice {
    return _originalPrice * 0.80;
  }

  int get quantityToSell {
    final value = int.tryParse(_quantityController.text.trim());

    if (value == null || value < 0) {
      return 0;
    }

    return value;
  }

  double get totalSellingPrice {
    return sellingPrice * quantityToSell;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Leftover Fertilizers",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          tabs: const [
            Tab(icon: Icon(Icons.shopping_cart), text: "BUY"),
            Tab(icon: Icon(Icons.sell), text: "SELL"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildBuyTab(), _buildSellTab()],
      ),
    );
  }

  Widget _buildBuyTab() {
    if (farmerMobile.isEmpty) {
      return const Center(
        child: Text(
          "Farmer details not found.",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _firestore
          .collection("leftover_fertilizers")
          .where("status", isEqualTo: "Available")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.green),
          );
        }

        if (snapshot.hasError) {
          return _buildError(
            "Unable to load leftover fertilizers.",
            snapshot.error.toString(),
          );
        }

        final allListings = snapshot.data?.docs ?? [];

        final listings = allListings.where((doc) {
          final data = doc.data();

          final sellerMobile = (data["sellerMobile"] ?? "").toString().trim();

          final availableQuantity =
              (data["availableQuantity"] as num?)?.toInt() ?? 0;

          return sellerMobile != farmerMobile && availableQuantity > 0;
        }).toList();

        if (listings.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_basket_outlined,
                    size: 90,
                    color: Colors.green.shade300,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "No Leftover Fertilizers Available",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Other farmers haven't listed any leftover fertilizers for sale yet.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: listings.length,
          itemBuilder: (context, index) {
            final doc = listings[index];

            return _buildBuyListingCard(doc);
          },
        );
      },
    );
  }

  Widget _buildBuyListingCard(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    final fertilizerName = (data["fertilizerName"] ?? "Unknown Fertilizer")
        .toString();

    final sellerName = (data["sellerName"] ?? "Farmer").toString();

    final village = (data["village"] ?? "Unknown Village").toString();

    final condition = (data["condition"] ?? "Good").toString();

    final availableQuantity = (data["availableQuantity"] as num?)?.toInt() ?? 0;

    final originalPrice = (data["originalPrice"] as num?)?.toDouble() ?? 0;

    final sellingPrice = (data["sellingPrice"] as num?)?.toDouble() ?? 0;

    final totalPrice = sellingPrice * availableQuantity;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.grass,
                    size: 28,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    fertilizerName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 20,
                  color: Colors.grey.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Seller: $sellerName",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: Colors.grey.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    village,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _infoItem(
                    Icons.inventory_2_outlined,
                    "Available",
                    "$availableQuantity Bags",
                  ),
                ),
                Expanded(
                  child: _infoItem(
                    Icons.fact_check_outlined,
                    "Condition",
                    condition,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _priceRow(
                    "Original Price",
                    "₹${originalPrice.toStringAsFixed(2)} / Bag",
                  ),
                  const SizedBox(height: 8),
                  _priceRow(
                    "Farmer Selling Price",
                    "₹${sellingPrice.toStringAsFixed(2)} / Bag",
                    bold: true,
                  ),
                  const Divider(height: 20),
                  _priceRow(
                    "Total Value",
                    "₹${totalPrice.toStringAsFixed(2)}",
                    bold: true,
                    large: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showBuyDialog(doc);
                },
                icon: const Icon(Icons.shopping_cart),
                label: const Text(
                  "BUY NOW",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
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

  void _showBuyDialog(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    final fertilizerName = (data["fertilizerName"] ?? "Unknown Fertilizer")
        .toString();

    final availableQuantity = (data["availableQuantity"] as num?)?.toInt() ?? 0;

    final sellingPrice = (data["sellingPrice"] as num?)?.toDouble() ?? 0;

    final quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        double totalAmount = 0;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final enteredQuantity = int.tryParse(quantityController.text) ?? 0;

            totalAmount = enteredQuantity * sellingPrice;

            return AlertDialog(
              title: const Text(
                "Buy Leftover Fertilizer",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fertilizerName,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text("Available: $availableQuantity Bags"),

                    const SizedBox(height: 6),

                    Text(
                      "Selling Price: ₹${sellingPrice.toStringAsFixed(2)} / Bag",
                    ),

                    const SizedBox(height: 18),

                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Quantity to Buy",
                        hintText: "Enter number of Bags",
                        suffixText: "Bags",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: (_) {
                        setDialogState(() {});
                      },
                    ),

                    const SizedBox(height: 16),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Total Amount",
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "₹${totalAmount.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
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
                  child: const Text("CANCEL"),
                ),

                ElevatedButton(
                  onPressed:
                      enteredQuantity <= 0 ||
                          enteredQuantity > availableQuantity
                      ? null
                      : () async {
                          Navigator.pop(dialogContext);

                          await _placeLeftoverOrder(doc, enteredQuantity);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("CONFIRM BUY"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _placeLeftoverOrder(
    QueryDocumentSnapshot<Map<String, dynamic>> listingDoc,
    int quantity,
  ) async {
    try {
      final buyerId =
          (widget.user["uid"] ??
                  widget.user["userId"] ??
                  widget.user["id"] ??
                  "")
              .toString();

      final buyerName = (widget.user["name"] ?? "").toString();

      final listingRef = listingDoc.reference;

      final orderRef = _firestore.collection("leftover_orders").doc();

      await _firestore.runTransaction((transaction) async {

        final listingSnapshot = await transaction.get(listingRef);

        if (!listingSnapshot.exists) {
          throw Exception("This fertilizer listing no longer exists.");
        }

        final listingData = listingSnapshot.data();

        if (listingData == null) {
          throw Exception("Unable to read fertilizer listing.");
        }

        final status = (listingData["status"] ?? "").toString().toLowerCase();

        final availableQuantity =
            (listingData["availableQuantity"] as num?)?.toInt() ?? 0;

        final sellingPrice =
            (listingData["sellingPrice"] as num?)?.toDouble() ?? 0;

        final sellerId = (listingData["sellerId"] ?? "").toString();

        final sellerName = (listingData["sellerName"] ?? "").toString();

        final fertilizerName = (listingData["fertilizerName"] ?? "").toString();

        if (status != "available") {
          throw Exception("This fertilizer is no longer available.");
        }

        if (availableQuantity <= 0) {
          throw Exception("This fertilizer is sold out.");
        }

        if (quantity <= 0) {
          throw Exception("Invalid quantity.");
        }

        if (quantity > availableQuantity) {
          throw Exception("Only $availableQuantity Bags are available.");
        }

        // ------------------------------------------------------
        // CALCULATE TOTAL
        // ------------------------------------------------------

        final totalAmount = quantity * sellingPrice;

        final remainingQuantity = availableQuantity - quantity;

        final newStatus = remainingQuantity == 0 ? "Sold" : "Available";

        // ------------------------------------------------------
        // CREATE ORDER
        // ------------------------------------------------------

        transaction.set(orderRef, {
          "orderId": orderRef.id,
          "listingId": listingDoc.id,

          "buyerId": buyerId,
          "buyerName": buyerName,

          "sellerId": sellerId,
          "sellerName": sellerName,

          "fertilizerName": fertilizerName,

          "quantity": quantity,

          "pricePerBag": sellingPrice,

          "totalAmount": totalAmount,

          "status": "Pending",

          "createdAt": FieldValue.serverTimestamp(),
        });

        // ------------------------------------------------------
        // UPDATE LISTING QUANTITY
        // ------------------------------------------------------

        transaction.update(listingRef, {
          "availableQuantity": remainingQuantity,

          "status": newStatus,

          "updatedAt": FieldValue.serverTimestamp(),
        });
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Purchase successful! $quantity Bags ordered."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst("Exception: ", "")),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ------------------------------------------------------------
  // SELL TAB
  // ------------------------------------------------------------

  Widget _buildSellTab() {
    if (farmerMobile.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            "Farmer details not found.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      // Load all farmer fertilizer bookings.
      // We filter Completed in Dart to avoid requiring
      // a Firestore composite index.
      stream: _firestore
          .collection("fertilizer_bookings")
          .where("farmerMobile", isEqualTo: farmerMobile)
          .snapshots(),
      builder: (context, bookingSnapshot) {
        if (bookingSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.green),
          );
        }

        if (bookingSnapshot.hasError) {
          return _buildError(
            "Unable to load your fertilizer purchases.",
            bookingSnapshot.error.toString(),
          );
        }

        final bookingDocs = bookingSnapshot.data?.docs ?? [];

        final completedBookings = bookingDocs.where((doc) {
          final data = doc.data();

          return (data["status"] ?? "").toString().toLowerCase() == "completed";
        }).toList();

        // --------------------------------------------------------
        // LOAD FARMER'S EXISTING MARKETPLACE LISTINGS
        // --------------------------------------------------------

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _firestore
              .collection("leftover_fertilizers")
              .where("sellerMobile", isEqualTo: farmerMobile)
              .snapshots(),
          builder: (context, listingSnapshot) {
            if (listingSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.green),
              );
            }

            if (listingSnapshot.hasError) {
              return _buildError(
                "Unable to load your leftover fertilizer listings.",
                listingSnapshot.error.toString(),
              );
            }

            final listingDocs = listingSnapshot.data?.docs ?? [];

            // ----------------------------------------------------
            // PURCHASED FERTILIZER INVENTORY
            // ----------------------------------------------------

            final Map<String, Map<String, dynamic>> purchasedMap = {};

            for (final doc in completedBookings) {
              final data = doc.data();

              final fertilizerName = (data["fertilizer"] ?? "")
                  .toString()
                  .trim();

              if (fertilizerName.isEmpty) {
                continue;
              }

              final quantity = (data["quantity"] as num?)?.toInt() ?? 0;

              final price = (data["pricePerBag"] as num?)?.toDouble() ?? 0;

              if (purchasedMap.containsKey(fertilizerName)) {
                purchasedMap[fertilizerName]!["quantity"] =
                    (purchasedMap[fertilizerName]!["quantity"] as int) +
                    quantity;

                purchasedMap[fertilizerName]!["price"] = price;
              } else {
                purchasedMap[fertilizerName] = {
                  "quantity": quantity,
                  "price": price,
                };
              }
            }

            // ----------------------------------------------------
            // CALCULATE ALREADY USED / LISTED INVENTORY
            // ----------------------------------------------------

            final Map<String, int> usedQuantityMap = {};

            for (final doc in listingDocs) {
              final data = doc.data();

              final fertilizerName = (data["fertilizerName"] ?? "")
                  .toString()
                  .trim();

              if (fertilizerName.isEmpty) {
                continue;
              }

              final status = (data["status"] ?? "Available")
                  .toString()
                  .toLowerCase();

              // Cancelled/rejected listings return inventory.
              if (status == "cancelled" || status == "rejected") {
                continue;
              }

              // IMPORTANT:
              //
              // Use original "quantity", NOT availableQuantity.
              //
              // Example:
              // Listed 20 → buyer buys 5 → availableQuantity = 15
              //
              // The farmer has already committed/sold 5 and
              // still has 15 in the marketplace.
              //
              // Therefore the original 20 must be counted
              // as consumed from the farmer's original stock.
              final quantity = (data["quantity"] as num?)?.toInt() ?? 0;

              usedQuantityMap[fertilizerName] =
                  (usedQuantityMap[fertilizerName] ?? 0) + quantity;
            }

            // ----------------------------------------------------
            // CALCULATE REMAINING SELLABLE QUANTITY
            // ----------------------------------------------------

            final Map<String, Map<String, dynamic>> availableMap = {};

            purchasedMap.forEach((fertilizerName, data) {
              final purchasedQuantity = data["quantity"] as int;

              final alreadyUsed = usedQuantityMap[fertilizerName] ?? 0;

              final remaining = purchasedQuantity - alreadyUsed;

              availableMap[fertilizerName] = {
                "quantity": remaining < 0 ? 0 : remaining,
                "price": data["price"],
              };
            });

            // If currently selected fertilizer no longer has
            // inventory, reset the form.
            if (_selectedFertilizer != null &&
                !availableMap.containsKey(_selectedFertilizer)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;

                setState(() {
                  _selectedFertilizer = null;
                  _availableQuantity = 0;
                  _originalPrice = 0;
                });

                _quantityController.clear();
              });
            } else if (_selectedFertilizer != null) {
              final latestAvailable =
                  availableMap[_selectedFertilizer]?["quantity"] as int? ?? 0;

              if (latestAvailable != _availableQuantity) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;

                  setState(() {
                    _availableQuantity = latestAvailable;
                  });
                });
              }
            }

            return _buildSellContent(availableMap, listingDocs);
          },
        );
      },
    );
  }

  // ------------------------------------------------------------
  // SELL CONTENT
  // ------------------------------------------------------------

  Widget _buildSellContent(
    Map<String, Map<String, dynamic>> availableMap,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> listingDocs,
  ) {
    final fertilizerNames = availableMap.keys.toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ------------------------------------------------------
          // MY ACTIVE LISTINGS
          // ------------------------------------------------------

          const Text(
            "My Active Listings",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          ...listingDocs
              .where((doc) {
                final status = (doc.data()["status"] ?? "Available")
                    .toString()
                    .toLowerCase();

                return status == "available";
              })
              .map((doc) {
                return _buildMyListingCard(doc);
              }),

          if (listingDocs.where((doc) {
            final status = (doc.data()["status"] ?? "Available")
                .toString()
                .toLowerCase();

            return status == "available";
          }).isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(Icons.inventory_2_outlined, color: Colors.grey),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "You don't have any active leftover fertilizer listings.",
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 28),

          const Divider(),

          const SizedBox(height: 20),

          // ------------------------------------------------------
          // SELL NEW FERTILIZER
          // ------------------------------------------------------
          const Text(
            "Sell More Fertilizer",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 14),

          if (fertilizerNames.isEmpty ||
              availableMap.values.every(
                (item) => (item["quantity"] as int) <= 0,
              ))
            _buildNoRemainingInventory()
          else
            _buildSellForm(availableMap, fertilizerNames),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // MY LISTING CARD
  // ------------------------------------------------------------

  Widget _buildMyListingCard(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    final fertilizerName = (data["fertilizerName"] ?? "Unknown Fertilizer")
        .toString();

    final quantity = (data["quantity"] as num?)?.toInt() ?? 0;

    final availableQuantity =
        (data["availableQuantity"] as num?)?.toInt() ?? quantity;

    final sellingPrice = (data["sellingPrice"] as num?)?.toDouble() ?? 0;

    final condition = (data["condition"] ?? "Good").toString();

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.grass,
                    color: Colors.green.shade700,
                    size: 27,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    fertilizerName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "AVAILABLE",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _infoItem(
                    Icons.inventory_2_outlined,
                    "Listed",
                    "$quantity Bags",
                  ),
                ),
                Expanded(
                  child: _infoItem(
                    Icons.shopping_bag_outlined,
                    "Remaining",
                    "$availableQuantity Bags",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _infoItem(
                    Icons.currency_rupee,
                    "Selling Price",
                    "₹${sellingPrice.toStringAsFixed(2)} / Bag",
                  ),
                ),
                Expanded(
                  child: _infoItem(
                    Icons.fact_check_outlined,
                    "Condition",
                    condition,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // NO REMAINING INVENTORY
  // ------------------------------------------------------------

  Widget _buildNoRemainingInventory() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 55,
            color: Colors.orange.shade700,
          ),
          const SizedBox(height: 12),
          const Text(
            "No Fertilizer Available to Sell",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "All your completed fertilizer purchases have already been listed or sold.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // SELL FORM
  // ------------------------------------------------------------

  Widget _buildSellForm(
    Map<String, Map<String, dynamic>> availableMap,
    List<String> fertilizerNames,
  ) {
    // Only show fertilizers with remaining inventory.
    final sellableNames = fertilizerNames.where((name) {
      return (availableMap[name]?["quantity"] as int? ?? 0) > 0;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.verified_outlined, color: Colors.green, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Only your remaining fertilizer inventory can be listed for resale.",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // ------------------------------------------------------
        // FERTILIZER DROPDOWN
        // ------------------------------------------------------
        DropdownButtonFormField<String>(
          value: _selectedFertilizer,
          decoration: InputDecoration(
            labelText: "Select Fertilizer",
            prefixIcon: const Icon(Icons.grass, color: Colors.green),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          items: sellableNames.map((name) {
            final available = availableMap[name]?["quantity"] as int? ?? 0;

            return DropdownMenuItem<String>(
              value: name,
              child: Text("$name ($available Bags available)"),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedFertilizer = value;

              if (value != null) {
                _availableQuantity =
                    availableMap[value]?["quantity"] as int? ?? 0;

                _originalPrice =
                    (availableMap[value]?["price"] as num?)?.toDouble() ?? 0;
              } else {
                _availableQuantity = 0;
                _originalPrice = 0;
              }
            });

            _quantityController.clear();
          },
        ),

        const SizedBox(height: 16),

        // ------------------------------------------------------
        // AVAILABLE QUANTITY
        // ------------------------------------------------------
        if (_selectedFertilizer != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.inventory_2_outlined, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Available to Sell",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "$_availableQuantity Bags",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        if (_selectedFertilizer != null) const SizedBox(height: 16),

        // ------------------------------------------------------
        // QUANTITY TO SELL
        // ------------------------------------------------------
        TextFormField(
          controller: _quantityController,
          keyboardType: TextInputType.number,
          enabled: _selectedFertilizer != null && _availableQuantity > 0,
          decoration: InputDecoration(
            labelText: "Quantity to Sell",
            hintText: "Enter number of bags",
            prefixIcon: const Icon(
              Icons.shopping_bag_outlined,
              color: Colors.green,
            ),
            suffixText: "Bags",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),

        if (_selectedFertilizer != null && quantityToSell > _availableQuantity)
          Padding(
            padding: const EdgeInsets.only(top: 7, left: 8),
            child: Text(
              "Quantity cannot exceed $_availableQuantity bags.",
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),

        const SizedBox(height: 16),

        // ------------------------------------------------------
        // PRICE
        // ------------------------------------------------------
        if (_selectedFertilizer != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                _priceRow(
                  "Original Purchase Price",
                  "₹${_originalPrice.toStringAsFixed(2)} / Bag",
                ),
                const SizedBox(height: 10),
                _priceRow(
                  "Your Selling Price",
                  "₹${sellingPrice.toStringAsFixed(2)} / Bag",
                  bold: true,
                ),
                const Divider(height: 22),
                _priceRow("Discount Given", "20%"),
                const SizedBox(height: 10),
                _priceRow(
                  "Total Selling Amount",
                  "₹${totalSellingPrice.toStringAsFixed(2)}",
                  bold: true,
                  large: true,
                ),
              ],
            ),
          ),

        const SizedBox(height: 22),

        // ------------------------------------------------------
        // CONDITION
        // ------------------------------------------------------
        const Text(
          "Fertilizer Condition",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        DropdownButtonFormField<String>(
          value: _condition,
          decoration: InputDecoration(
            labelText: "Condition",
            prefixIcon: const Icon(
              Icons.fact_check_outlined,
              color: Colors.green,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          items: const [
            DropdownMenuItem(value: "Sealed", child: Text("Sealed / Unopened")),
            DropdownMenuItem(value: "Good", child: Text("Good")),
            DropdownMenuItem(value: "Opened", child: Text("Opened")),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _condition = value;
              });
            }
          },
        ),

        const SizedBox(height: 22),

        // ------------------------------------------------------
        // SELLER DETAILS
        // ------------------------------------------------------
        const Text(
          "Seller Details",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        _readOnlyField(
          label: "Seller Name",
          value: farmerName,
          icon: Icons.person_outline,
        ),

        const SizedBox(height: 12),

        _readOnlyField(
          label: "Village",
          value: farmerVillage.isEmpty
              ? "Village not available"
              : farmerVillage,
          icon: Icons.location_on_outlined,
        ),

        const SizedBox(height: 12),

        _readOnlyField(
          label: "Mobile Number",
          value: farmerMobile,
          icon: Icons.phone_outlined,
        ),

        const SizedBox(height: 22),

        // ------------------------------------------------------
        // ADDITIONAL DETAILS
        // ------------------------------------------------------
        const Text(
          "Additional Details (Optional)",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        TextFormField(
          controller: _detailsController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText:
                "Example: Properly stored, dry condition, original packaging...",
            prefixIcon: const Padding(
              padding: EdgeInsets.only(bottom: 55),
              child: Icon(Icons.notes_outlined, color: Colors.green),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),

        const SizedBox(height: 25),

        // ------------------------------------------------------
        // LIST BUTTON
        // ------------------------------------------------------
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _validateSellingForm,
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.sell),
            label: Text(
              _isSaving ? "LISTING..." : "LIST FOR SALE",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  // ------------------------------------------------------------
  // VALIDATE + SAVE
  // ------------------------------------------------------------

  Future<void> _validateSellingForm() async {
    if (_selectedFertilizer == null) {
      _showMessage("Please select a fertilizer.", isError: true);
      return;
    }

    if (quantityToSell <= 0) {
      _showMessage(
        "Please enter the quantity you want to sell.",
        isError: true,
      );
      return;
    }

    if (quantityToSell > _availableQuantity) {
      _showMessage(
        "You cannot sell more than $_availableQuantity bags.",
        isError: true,
      );
      return;
    }

    if (farmerMobile.isEmpty) {
      _showMessage("Farmer mobile number not found.", isError: true);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final document = _firestore.collection("leftover_fertilizers").doc();

      final listingId = document.id;

      final listingData = <String, dynamic>{
        "listingId": listingId,

        "sellerId":
            (widget.user["uid"] ??
                    widget.user["userId"] ??
                    widget.user["id"] ??
                    "")
                .toString(),

        "sellerName": farmerName,

        "sellerMobile": farmerMobile,

        "village": farmerVillage,

        "fertilizerName": _selectedFertilizer,

        // Original quantity listed
        "quantity": quantityToSell,

        // Current quantity available to BUY
        "availableQuantity": quantityToSell,

        "originalPrice": _originalPrice,

        "sellingPrice": sellingPrice,

        "totalPrice": totalSellingPrice,

        "condition": _condition,

        "details": _detailsController.text.trim(),

        "status": "Available",

        "createdAt": FieldValue.serverTimestamp(),

        "updatedAt": FieldValue.serverTimestamp(),
      };

      await document.set(listingData);

      if (!mounted) return;

      setState(() {
        _isSaving = false;
        _selectedFertilizer = null;
        _availableQuantity = 0;
        _originalPrice = 0;
        _condition = "Good";
      });

      _quantityController.clear();
      _detailsController.clear();

      _showMessage("Fertilizer listed for sale successfully!");
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showMessage("Failed to list fertilizer: $e", isError: true);
    }
  }

  // ------------------------------------------------------------
  // PRICE ROW
  // ------------------------------------------------------------

  Widget _priceRow(
    String title,
    String value, {
    bool bold = false,
    bool large = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: large ? 16 : 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          value,
          style: TextStyle(
            fontSize: large ? 18 : 14,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            color: large ? Colors.green.shade800 : Colors.black87,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // READ ONLY FIELD
  // ------------------------------------------------------------

  Widget _readOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
    );
  }

  // ------------------------------------------------------------
  // INFO ITEM
  // ------------------------------------------------------------

  Widget _infoItem(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 19, color: Colors.green.shade700),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // ERROR
  // ------------------------------------------------------------

  Widget _buildError(String title, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red.shade400),
            const SizedBox(height: 15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // SNACKBAR
  // ------------------------------------------------------------

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}
