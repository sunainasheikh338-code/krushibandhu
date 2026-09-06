import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminFertilizerManagementScreen extends StatefulWidget {
  const AdminFertilizerManagementScreen({super.key});

  @override
  State<AdminFertilizerManagementScreen> createState() =>
      _AdminFertilizerManagementScreenState();
}

class _AdminFertilizerManagementScreenState
    extends State<AdminFertilizerManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================
  // ADD / EDIT FERTILIZER
  // ============================================================

  void _showFertilizerDialog({
    String? documentId,
    Map<String, dynamic>? existingData,
  }) {
    final nameController = TextEditingController(
      text: existingData?['name']?.toString() ?? '',
    );

    final priceController = TextEditingController(
      text: existingData?['price']?.toString() ?? '',
    );

    final stockController = TextEditingController(
      text: existingData?['stock']?.toString() ?? '',
    );

    bool active = existingData?['active'] != false;

    final bool isEditing = documentId != null;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                isEditing ? 'Edit Fertilizer' : 'Add Fertilizer',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ------------------------------------------------
                    // NAME
                    // ------------------------------------------------

                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Fertilizer Name',
                        hintText: 'Example: Urea',
                        prefixIcon: Icon(Icons.eco),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ------------------------------------------------
                    // PRICE
                    // ------------------------------------------------

                    TextField(
                      controller: priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Price per Bag',
                        hintText: 'Example: 266',
                        prefixIcon: Icon(
                          Icons.currency_rupee,
                        ),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ------------------------------------------------
                    // STOCK
                    // ------------------------------------------------

                    TextField(
                      controller: stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Available Stock',
                        hintText: 'Example: 500',
                        prefixIcon: Icon(
                          Icons.inventory_2,
                        ),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ------------------------------------------------
                    // ACTIVE
                    // ------------------------------------------------

                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Available for Booking',
                      ),
                      subtitle: Text(
                        active
                            ? 'Farmers can book this fertilizer'
                            : 'Hidden from farmers',
                      ),
                      value: active,
                      activeColor: Colors.green,
                      onChanged: (value) {
                        setDialogState(() {
                          active = value;
                        });
                      },
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final name = nameController.text.trim();

                    final price = double.tryParse(
                      priceController.text.trim(),
                    );

                    final stock = int.tryParse(
                      stockController.text.trim(),
                    );

                    // ------------------------------------------------
                    // VALIDATION
                    // ------------------------------------------------

                    if (name.isEmpty) {
                      _showMessage(
                        'Please enter fertilizer name.',
                        Colors.red,
                      );
                      return;
                    }

                    if (price == null || price <= 0) {
                      _showMessage(
                        'Please enter a valid price.',
                        Colors.red,
                      );
                      return;
                    }

                    if (stock == null || stock < 0) {
                      _showMessage(
                        'Please enter a valid stock.',
                        Colors.red,
                      );
                      return;
                    }

                    try {
                      // ==============================================
                      // UPDATE EXISTING
                      // ==============================================

                      if (isEditing) {
                        await _firestore
                            .collection('fertilizers')
                            .doc(documentId)
                            .update({
                          'name': name,
                          'price': price,
                          'stock': stock,
                          'active': active,
                          'updatedAt':
                          FieldValue.serverTimestamp(),
                        });
                      }

                      // ==============================================
                      // ADD NEW
                      // ==============================================

                      else {
                        await _firestore
                            .collection('fertilizers')
                            .add({
                          'name': name,
                          'price': price,
                          'stock': stock,
                          'active': active,
                          'createdAt':
                          FieldValue.serverTimestamp(),
                          'updatedAt':
                          FieldValue.serverTimestamp(),
                        });
                      }

                      if (!mounted) return;

                      Navigator.pop(dialogContext);

                      _showMessage(
                        isEditing
                            ? 'Fertilizer updated successfully.'
                            : 'Fertilizer added successfully.',
                        Colors.green,
                      );
                    } catch (e) {
                      _showMessage(
                        'Failed to save fertilizer:\n$e',
                        Colors.red,
                      );
                    }
                  },
                  child: Text(
                    isEditing ? 'Update' : 'Add',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // DELETE FERTILIZER
  // ============================================================

  Future<void> _deleteFertilizer(
      String documentId,
      String name,
      ) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Fertilizer?',
          ),
          content: Text(
            'Are you sure you want to delete "$name"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('Cancel'),
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
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await _firestore
          .collection('fertilizers')
          .doc(documentId)
          .delete();

      if (!mounted) return;

      _showMessage(
        'Fertilizer deleted successfully.',
        Colors.green,
      );
    } catch (e) {
      _showMessage(
        'Failed to delete fertilizer:\n$e',
        Colors.red,
      );
    }
  }

  // ============================================================
  // ENABLE / DISABLE
  // ============================================================

  Future<void> _toggleActive(
      String documentId,
      bool currentValue,
      ) async {
    try {
      await _firestore
          .collection('fertilizers')
          .doc(documentId)
          .update({
        'active': !currentValue,
        'updatedAt':
        FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _showMessage(
        'Failed to update availability:\n$e',
        Colors.red,
      );
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
      String message,
      Color color,
      ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      // ==========================================================
      // ADD BUTTON
      // ==========================================================

      floatingActionButton:
      FloatingActionButton.extended(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        onPressed: () {
          _showFertilizerDialog();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Fertilizer'),
      ),

      // ==========================================================
      // FIRESTORE
      // ==========================================================

      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: _firestore
            .collection('fertilizers')
            .snapshots(),

        builder: (context, snapshot) {
          // ------------------------------------------------------
          // LOADING
          // ------------------------------------------------------

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            );
          }

          // ------------------------------------------------------
          // ERROR
          // ------------------------------------------------------

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Error loading fertilizers:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            );
          }

          final docs =
              snapshot.data?.docs ?? [];

          // ------------------------------------------------------
          // EMPTY
          // ------------------------------------------------------

          if (docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.eco_outlined,
                    size: 70,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'No fertilizers added yet.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap "Add Fertilizer" to create one.',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          // ------------------------------------------------------
          // LIST
          // ------------------------------------------------------

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              100,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();

              final String name =
                  data['name']?.toString() ?? '-';

              final double price =
              data['price'] is num
                  ? (data['price'] as num)
                  .toDouble()
                  : double.tryParse(
                data['price']?.toString() ??
                    '',
              ) ??
                  0;

              final int stock =
              data['stock'] is num
                  ? (data['stock'] as num).toInt()
                  : int.tryParse(
                data['stock']?.toString() ??
                    '',
              ) ??
                  0;

              final bool active =
                  data['active'] != false;

              return Card(
                margin: const EdgeInsets.only(
                  bottom: 14,
                ),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(18),
                ),
                child: Padding(
                  padding:
                  const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // ==========================================
                      // HEADER
                      // ==========================================

                      Row(
                        children: [
                          Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              color: active
                                  ? Colors.green.shade50
                                  : Colors.grey.shade200,
                              borderRadius:
                              BorderRadius.circular(
                                15,
                              ),
                            ),
                            child: Icon(
                              Icons.eco,
                              size: 32,
                              color: active
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight:
                                    FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '₹${price.toStringAsFixed(0)} / bag',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight:
                                    FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ========================================
                          // STATUS
                          // ========================================

                          Container(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: active
                                  ? Colors.green.shade50
                                  : Colors.red.shade50,
                              borderRadius:
                              BorderRadius.circular(
                                20,
                              ),
                            ),
                            child: Text(
                              active
                                  ? 'Active'
                                  : 'Disabled',
                              style: TextStyle(
                                color: active
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight:
                                FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // ==========================================
                      // STOCK / PRICE
                      // ==========================================

                      Row(
                        children: [
                          Expanded(
                            child: _infoItem(
                              Icons.inventory_2,
                              'Stock',
                              '$stock bags',
                            ),
                          ),
                          Expanded(
                            child: _infoItem(
                              Icons.currency_rupee,
                              'Price',
                              '₹${price.toStringAsFixed(0)}',
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 25),

                      // ==========================================
                      // ACTIONS
                      // ==========================================

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                _showFertilizerDialog(
                                  documentId: doc.id,
                                  existingData: data,
                                );
                              },
                              icon: const Icon(
                                Icons.edit,
                              ),
                              label: const Text(
                                'Edit',
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: OutlinedButton.icon(
                              style:
                              OutlinedButton.styleFrom(
                                foregroundColor: active
                                    ? Colors.orange
                                    : Colors.green,
                              ),
                              onPressed: () {
                                _toggleActive(
                                  doc.id,
                                  active,
                                );
                              },
                              icon: Icon(
                                active
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              label: Text(
                                active
                                    ? 'Disable'
                                    : 'Enable',
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          IconButton(
                            color: Colors.red,
                            tooltip: 'Delete',
                            onPressed: () {
                              _deleteFertilizer(
                                doc.id,
                                name,
                              );
                            },
                            icon: const Icon(
                              Icons.delete_outline,
                            ),
                          ),
                        ],
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

  // ============================================================
  // INFO ITEM
  // ============================================================

  Widget _infoItem(
      IconData icon,
      String title,
      String value,
      ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.green,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}