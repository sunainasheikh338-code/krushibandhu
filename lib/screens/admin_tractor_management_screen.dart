import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'add_tractor_screen.dart';
import 'admin_equipment_management_screen.dart';

class AdminTractorManagementScreen extends StatefulWidget {
  const AdminTractorManagementScreen({super.key});

  @override
  State<AdminTractorManagementScreen> createState() =>
      _AdminTractorManagementScreenState();
}

class _AdminTractorManagementScreenState
    extends State<AdminTractorManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================
  // EDIT TRACTOR
  // ============================================================

  void _showTractorDialog({
    String? documentId,
    Map<String, dynamic>? existingData,
  }) {
    final tractorNameController = TextEditingController(
      text: existingData?['tractorName']?.toString() ?? '',
    );

    final brandController = TextEditingController(
      text: existingData?['brand']?.toString() ?? '',
    );

    final modelController = TextEditingController(
      text: existingData?['model']?.toString() ?? '',
    );

    final ownerNameController = TextEditingController(
      text: existingData?['ownerName']?.toString() ?? '',
    );

    final mobileController = TextEditingController(
      text: existingData?['mobile']?.toString() ?? '',
    );

    final villageController = TextEditingController(
      text: existingData?['village']?.toString() ?? '',
    );

    final pricePerHourController = TextEditingController(
      text: existingData?['pricePerHour']?.toString() ?? '',
    );

    final pricePerDayController = TextEditingController(
      text: existingData?['pricePerDay']?.toString() ?? '',
    );

    final labourChargeController = TextEditingController(
      text: existingData?['labourCharge']?.toString() ?? '',
    );

    final descriptionController = TextEditingController(
      text: existingData?['description']?.toString() ?? '',
    );

    final imageUrlController = TextEditingController(
      text: existingData?['imageUrl']?.toString() ?? '',
    );

    String tractorType =
        existingData?['tractorType']?.toString() ?? '2WD Tractor';

    bool labourAvailable =
        existingData?['labourAvailable'] == true;

    bool isAvailable =
        existingData?['isAvailable'] != false;

    final List<String> tractorTypes = [
      'Mini Tractor',
      '2WD Tractor',
      '4WD Tractor',
      'Power Tiller',
      'Other',
    ];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                documentId == null
                    ? 'Tractor Details'
                    : 'Edit Tractor',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: tractorNameController,
                      decoration: const InputDecoration(
                        labelText: 'Tractor Name',
                        hintText: 'Example: Mahindra 575 DI',
                        prefixIcon: Icon(Icons.agriculture),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextField(
                      controller: brandController,
                      decoration: const InputDecoration(
                        labelText: 'Brand',
                        hintText: 'Example: Mahindra',
                        prefixIcon: Icon(Icons.business),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextField(
                      controller: modelController,
                      decoration: const InputDecoration(
                        labelText: 'Model',
                        hintText: 'Example: 575 DI',
                        prefixIcon: Icon(
                          Icons.precision_manufacturing,
                        ),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 14),

                    DropdownButtonFormField<String>(
                      value: tractorTypes.contains(tractorType)
                          ? tractorType
                          : tractorTypes[0],
                      decoration: const InputDecoration(
                        labelText: 'Tractor Type',
                        prefixIcon: Icon(Icons.category),
                        border: OutlineInputBorder(),
                      ),
                      items: tractorTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;

                        setDialogState(() {
                          tractorType = value;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: ownerNameController,
                      decoration: const InputDecoration(
                        labelText: 'Owner Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextField(
                      controller: mobileController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Mobile Number',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextField(
                      controller: villageController,
                      decoration: const InputDecoration(
                        labelText: 'Village / Location',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: pricePerHourController,
                      keyboardType:
                      const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Price Per Hour',
                        prefixIcon: Icon(
                          Icons.currency_rupee,
                        ),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextField(
                      controller: pricePerDayController,
                      keyboardType:
                      const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Price Per Day',
                        prefixIcon: Icon(
                          Icons.currency_rupee,
                        ),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 14),

                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Labour Available',
                      ),
                      value: labourAvailable,
                      activeColor: Colors.green,
                      onChanged: (value) {
                        setDialogState(() {
                          labourAvailable = value;
                        });
                      },
                    ),

                    if (labourAvailable) ...[
                      const SizedBox(height: 8),

                      TextField(
                        controller: labourChargeController,
                        keyboardType:
                        const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Labour Charge Per Day',
                          prefixIcon: Icon(
                            Icons.currency_rupee,
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],

                    const SizedBox(height: 14),

                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextField(
                      controller: imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Image URL',
                        prefixIcon: Icon(Icons.image),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 10),

                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Available for Rental',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        isAvailable
                            ? 'Farmers can rent this tractor'
                            : 'Hidden from farmers',
                      ),
                      value: isAvailable,
                      activeColor: Colors.green,
                      onChanged: (value) {
                        setDialogState(() {
                          isAvailable = value;
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

                if (documentId != null)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      final name =
                      tractorNameController.text.trim();

                      if (name.isEmpty) {
                        _showMessage(
                          'Please enter tractor name.',
                          Colors.red,
                        );
                        return;
                      }

                      final pricePerHour =
                      double.tryParse(
                        pricePerHourController.text.trim(),
                      );

                      final pricePerDay =
                      double.tryParse(
                        pricePerDayController.text.trim(),
                      );

                      if (pricePerHour == null ||
                          pricePerHour <= 0) {
                        _showMessage(
                          'Please enter a valid hourly price.',
                          Colors.red,
                        );
                        return;
                      }

                      if (pricePerDay == null ||
                          pricePerDay <= 0) {
                        _showMessage(
                          'Please enter a valid daily price.',
                          Colors.red,
                        );
                        return;
                      }

                      final labourCharge =
                          double.tryParse(
                            labourChargeController.text.trim(),
                          ) ??
                              0;

                      if (labourAvailable &&
                          labourCharge <= 0) {
                        _showMessage(
                          'Please enter a valid labour charge.',
                          Colors.red,
                        );
                        return;
                      }

                      try {
                        await _firestore
                            .collection('tractor_listings')
                            .doc(documentId)
                            .update({
                          'tractorName': name,
                          'brand':
                          brandController.text.trim(),
                          'model':
                          modelController.text.trim(),
                          'tractorType': tractorType,
                          'ownerName':
                          ownerNameController.text.trim(),
                          'mobile':
                          mobileController.text.trim(),
                          'village':
                          villageController.text.trim(),
                          'pricePerHour': pricePerHour,
                          'pricePerDay': pricePerDay,
                          'labourAvailable':
                          labourAvailable,
                          'labourCharge': labourAvailable
                              ? labourCharge
                              : 0,
                          'description':
                          descriptionController.text.trim(),
                          'imageUrl':
                          imageUrlController.text.trim(),
                          'isAvailable': isAvailable,
                          'updatedAt':
                          FieldValue.serverTimestamp(),
                        });

                        if (!mounted) return;

                        Navigator.pop(dialogContext);

                        _showMessage(
                          'Tractor updated successfully.',
                          Colors.green,
                        );
                      } catch (e) {
                        _showMessage(
                          'Failed to update tractor:\n$e',
                          Colors.red,
                        );
                      }
                    },
                    child: const Text('Update'),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // DELETE TRACTOR
  // ============================================================

  Future<void> _deleteTractor(
      String documentId,
      String tractorName,
      ) async {
    final bool? confirm =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Tractor?',
          ),
          content: Text(
            'Are you sure you want to delete "$tractorName"?',
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
          .collection('tractor_listings')
          .doc(documentId)
          .delete();

      if (!mounted) return;

      _showMessage(
        'Tractor deleted successfully.',
        Colors.green,
      );
    } catch (e) {
      _showMessage(
        'Failed to delete tractor:\n$e',
        Colors.red,
      );
    }
  }

  // ============================================================
  // ENABLE / DISABLE
  // ============================================================

  Future<void> _toggleAvailability(
      String documentId,
      bool currentValue,
      ) async {
    try {
      await _firestore
          .collection('tractor_listings')
          .doc(documentId)
          .update({
        'isAvailable': !currentValue,
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

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

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
      backgroundColor:
      const Color(0xFFF5F7F5),

      // ==========================================================
      // ADD TRACTOR BUTTON
      // ==========================================================

      floatingActionButton:
      FloatingActionButton.extended(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
              const AddTractorScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Tractor'),
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: Column(
        children: [
          // ========================================================
          // MANAGE EQUIPMENT BUTTON
          // ========================================================

          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              12,
              16,
              4,
            ),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const AdminEquipmentManagementScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.build,
                ),
                label: const Text(
                  'Manage Equipment',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green,
                  side: const BorderSide(
                    color: Colors.green,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),

          // ========================================================
          // FIRESTORE TRACTOR LIST
          // ========================================================

          Expanded(
            child: StreamBuilder<
                QuerySnapshot<Map<String, dynamic>>>(
              stream: _firestore
                  .collection('tractor_listings')
                  .snapshots(),

              builder: (context, snapshot) {
                // --------------------------------------------------
                // LOADING
                // --------------------------------------------------

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.green,
                    ),
                  );
                }

                // --------------------------------------------------
                // ERROR
                // --------------------------------------------------

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding:
                      const EdgeInsets.all(20),
                      child: Text(
                        'Error loading tractors:\n${snapshot.error}',
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

                // --------------------------------------------------
                // EMPTY
                // --------------------------------------------------

                if (docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize:
                      MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.agriculture_outlined,
                          size: 70,
                          color: Colors.grey,
                        ),

                        SizedBox(height: 15),

                        Text(
                          'No tractors added yet.',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 8),

                        Text(
                          'Add a tractor to manage it here.',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // --------------------------------------------------
                // TRACTOR LIST
                // --------------------------------------------------

                return ListView.builder(
                  padding:
                  const EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    100,
                  ),
                  itemCount: docs.length,

                  itemBuilder:
                      (context, index) {
                    final doc = docs[index];
                    final data = doc.data();

                    final String tractorName =
                        data['tractorName']
                            ?.toString() ??
                            '-';

                    final String brand =
                        data['brand']
                            ?.toString() ??
                            '-';

                    final String model =
                        data['model']
                            ?.toString() ??
                            '-';

                    final String tractorType =
                        data['tractorType']
                            ?.toString() ??
                            '-';

                    final String ownerName =
                        data['ownerName']
                            ?.toString() ??
                            '-';

                    final String village =
                        data['village']
                            ?.toString() ??
                            '-';

                    final double pricePerHour =
                    data['pricePerHour'] is num
                        ? (data['pricePerHour']
                    as num)
                        .toDouble()
                        : 0;

                    final double pricePerDay =
                    data['pricePerDay'] is num
                        ? (data['pricePerDay']
                    as num)
                        .toDouble()
                        : 0;

                    final bool isAvailable =
                        data['isAvailable'] != false;

                    final bool labourAvailable =
                        data['labourAvailable'] ==
                            true;

                    return Card(
                      margin:
                      const EdgeInsets.only(
                        bottom: 14,
                      ),
                      elevation: 3,
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          18,
                        ),
                      ),
                      child: Padding(
                        padding:
                        const EdgeInsets.all(
                          16,
                        ),
                        child: Column(
                          children: [
                            // ======================================
                            // HEADER
                            // ======================================

                            Row(
                              children: [
                                Container(
                                  width: 58,
                                  height: 58,
                                  decoration:
                                  BoxDecoration(
                                    color: isAvailable
                                        ? Colors
                                        .green
                                        .shade50
                                        : Colors
                                        .grey
                                        .shade200,
                                    borderRadius:
                                    BorderRadius
                                        .circular(
                                      15,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.agriculture,
                                    size: 32,
                                    color:
                                    isAvailable
                                        ? Colors
                                        .green
                                        : Colors
                                        .grey,
                                  ),
                                ),

                                const SizedBox(
                                  width: 14,
                                ),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                    children: [
                                      Text(
                                        tractorName,
                                        style:
                                        const TextStyle(
                                          fontSize: 19,
                                          fontWeight:
                                          FontWeight
                                              .bold,
                                        ),
                                      ),

                                      const SizedBox(
                                        height: 4,
                                      ),

                                      Text(
                                        '$brand • $model',
                                        style:
                                        const TextStyle(
                                          color:
                                          Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Container(
                                  padding:
                                  const EdgeInsets
                                      .symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration:
                                  BoxDecoration(
                                    color: isAvailable
                                        ? Colors
                                        .green
                                        .shade50
                                        : Colors
                                        .red
                                        .shade50,
                                    borderRadius:
                                    BorderRadius
                                        .circular(
                                      20,
                                    ),
                                  ),
                                  child: Text(
                                    isAvailable
                                        ? 'Available'
                                        : 'Disabled',
                                    style: TextStyle(
                                      color: isAvailable
                                          ? Colors
                                          .green
                                          : Colors
                                          .red,
                                      fontWeight:
                                      FontWeight
                                          .bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 14,
                            ),

                            // ======================================
                            // TRACTOR DETAILS
                            // ======================================

                            Row(
                              children: [
                                Expanded(
                                  child: _infoItem(
                                    Icons.category,
                                    'Type',
                                    tractorType,
                                  ),
                                ),

                                Expanded(
                                  child: _infoItem(
                                    Icons.location_on,
                                    'Location',
                                    village,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 12,
                            ),

                            Row(
                              children: [
                                Expanded(
                                  child: _infoItem(
                                    Icons
                                        .currency_rupee,
                                    'Per Hour',
                                    '₹${pricePerHour.toStringAsFixed(0)}',
                                  ),
                                ),

                                Expanded(
                                  child: _infoItem(
                                    Icons
                                        .calendar_today,
                                    'Per Day',
                                    '₹${pricePerDay.toStringAsFixed(0)}',
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 12,
                            ),

                            Row(
                              children: [
                                Expanded(
                                  child: _infoItem(
                                    Icons.person,
                                    'Owner',
                                    ownerName,
                                  ),
                                ),

                                Expanded(
                                  child: _infoItem(
                                    Icons.groups,
                                    'Labour',
                                    labourAvailable
                                        ? 'Available'
                                        : 'Not Available',
                                  ),
                                ),
                              ],
                            ),

                            const Divider(
                              height: 25,
                            ),

                            // ======================================
                            // ACTIONS
                            // ======================================

                            Row(
                              children: [
                                Expanded(
                                  child:
                                  OutlinedButton
                                      .icon(
                                    onPressed: () {
                                      _showTractorDialog(
                                        documentId:
                                        doc.id,
                                        existingData:
                                        data,
                                      );
                                    },
                                    icon:
                                    const Icon(
                                      Icons.edit,
                                    ),
                                    label:
                                    const Text(
                                      'Edit',
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  width: 8,
                                ),

                                Expanded(
                                  child:
                                  OutlinedButton
                                      .icon(
                                    style:
                                    OutlinedButton
                                        .styleFrom(
                                      foregroundColor:
                                      isAvailable
                                          ? Colors
                                          .orange
                                          : Colors
                                          .green,
                                    ),
                                    onPressed: () {
                                      _toggleAvailability(
                                        doc.id,
                                        isAvailable,
                                      );
                                    },
                                    icon: Icon(
                                      isAvailable
                                          ? Icons
                                          .visibility_off
                                          : Icons
                                          .visibility,
                                    ),
                                    label: Text(
                                      isAvailable
                                          ? 'Disable'
                                          : 'Enable',
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  width: 8,
                                ),

                                IconButton(
                                  color: Colors.red,
                                  tooltip: 'Delete',
                                  onPressed: () {
                                    _deleteTractor(
                                      doc.id,
                                      tractorName,
                                    );
                                  },
                                  icon:
                                  const Icon(
                                    Icons
                                        .delete_outline,
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
          ),
        ],
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

        const SizedBox(
          width: 8,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),

              Text(
                value,
                overflow:
                TextOverflow.ellipsis,
                style:
                const TextStyle(
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}