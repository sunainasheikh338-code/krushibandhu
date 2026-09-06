import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminEquipmentManagementScreen extends StatefulWidget {
  const AdminEquipmentManagementScreen({super.key});

  @override
  State<AdminEquipmentManagementScreen> createState() =>
      _AdminEquipmentManagementScreenState();
}

class _AdminEquipmentManagementScreenState
    extends State<AdminEquipmentManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _equipmentCollection =>
      _firestore.collection('equipment');

  Future<void> _showEquipmentDialog({
    DocumentSnapshot<Map<String, dynamic>>? document,
  }) async {
    final data = document?.data();

    final nameController =
    TextEditingController(text: data?['name']?.toString() ?? '');
    final typeController =
    TextEditingController(text: data?['type']?.toString() ?? '');
    final priceController = TextEditingController(
      text: data?['price']?.toString() ?? '',
    );
    final descriptionController = TextEditingController(
      text: data?['description']?.toString() ?? '',
    );

    String compatibleTractorType =
        data?['compatibleTractorType']?.toString() ?? '2WD Tractor';

    bool isAvailable = data?['isAvailable'] ?? true;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                document == null ? 'Add Equipment' : 'Edit Equipment',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Equipment Name',
                        hintText: 'Example: Rotavator',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: compatibleTractorType,
                      decoration: const InputDecoration(
                        labelText: 'Compatible Tractor Type',
                        prefixIcon: Icon(Icons.agriculture),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Mini Tractor',
                          child: Text('Mini Tractor'),
                        ),
                        DropdownMenuItem(
                          value: '2WD Tractor',
                          child: Text('2WD Tractor'),
                        ),
                        DropdownMenuItem(
                          value: '4WD Tractor',
                          child: Text('4WD Tractor'),
                        ),
                        DropdownMenuItem(
                          value: 'Power Tiller',
                          child: Text('Power Tiller'),
                        ),
                        DropdownMenuItem(
                          value: 'Other',
                          child: Text('Other'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;

                        setDialogState(() {
                          compatibleTractorType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: typeController,
                      decoration: const InputDecoration(
                        labelText: 'Equipment Type',
                        hintText: 'Example: Tillage',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        hintText: 'Example: 300',
                        prefixText: '₹ ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Describe the equipment',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Available'),
                      value: isAvailable,
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
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final type = typeController.text.trim();
                    final price =
                        double.tryParse(priceController.text.trim()) ?? 0;

                    if (name.isEmpty) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter equipment name'),
                        ),
                      );
                      return;
                    }

                    if (type.isEmpty) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter equipment type'),
                        ),
                      );
                      return;
                    }

                    if (price < 0) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          content: Text('Price cannot be negative'),
                        ),
                      );
                      return;
                    }

                    try {
                      if (document == null) {
                        final newDoc = _equipmentCollection.doc();

                        await newDoc.set({
                          'equipmentId': newDoc.id,
                          'name': name,
                          'type': type,
                          'price': price,
                          'compatibleTractorType': compatibleTractorType,
                          'description':
                          descriptionController.text.trim(),
                          'isAvailable': isAvailable,
                          'createdAt': FieldValue.serverTimestamp(),
                          'updatedAt': FieldValue.serverTimestamp(),
                        });
                      } else {
                        await document.reference.update({
                          'name': name,
                          'type': type,
                          'price': price,
                          'compatibleTractorType': compatibleTractorType,
                          'description':
                          descriptionController.text.trim(),
                          'isAvailable': isAvailable,
                          'updatedAt': FieldValue.serverTimestamp(),
                        });
                      }

                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }

                      if (mounted) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            content: Text(
                              document == null
                                  ? 'Equipment added successfully'
                                  : 'Equipment updated successfully',
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                          ),
                        );
                      }
                    }
                  },
                  child: Text(
                    document == null ? 'Add' : 'Update',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    typeController.dispose();
    priceController.dispose();
    descriptionController.dispose();
  }

  Future<void> _toggleAvailability(
      DocumentSnapshot<Map<String, dynamic>> document,
      bool currentValue,
      ) async {
    try {
      await document.reference.update({
        'isAvailable': !currentValue,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              !currentValue
                  ? 'Equipment enabled'
                  : 'Equipment disabled',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
          ),
        );
      }
    }
  }

  Future<void> _deleteEquipment(
      DocumentSnapshot<Map<String, dynamic>> document,
      ) async {
    final data = document.data();
    final name = data?['name']?.toString() ?? 'this equipment';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Equipment'),
          content: Text(
            'Are you sure you want to delete "$name"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await document.reference.delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Equipment deleted successfully'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
          ),
        );
      }
    }
  }

  Widget _buildEquipmentCard(
      BuildContext context,
      DocumentSnapshot<Map<String, dynamic>> document,
      ) {
    final data = document.data() ?? {};

    final name = data['name']?.toString() ?? 'Unnamed Equipment';
    final type = data['type']?.toString() ?? 'Unknown';
    final compatibleTractorType = data['compatibleTractorType']?.toString() ?? 'Not specified';
    final description = data['description']?.toString() ?? '';
    final price = data['price'];

    final isAvailable = data['isAvailable'] == true;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
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
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        type,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isAvailable
                        ? Colors.green.withValues(alpha: 0.12)
                        : Colors.red.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isAvailable ? 'Available' : 'Disabled',
                    style: TextStyle(
                      color: isAvailable ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                const Icon(
                  Icons.currency_rupee,
                  size: 18,
                  color: Colors.green,
                ),
                const SizedBox(width: 5),
                Text(
                  '${price ?? 0}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '/ rental',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(
                  Icons.agriculture,
                  size: 18,
                  color: Colors.green,
                ),
                const SizedBox(width: 5),
                Text(
                  'Compatible: $compatibleTractorType',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            if (description.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ],

            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 4),

            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      _showEquipmentDialog(document: document);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      _toggleAvailability(
                        document,
                        isAvailable,
                      );
                    },
                    icon: Icon(
                      isAvailable
                          ? Icons.block
                          : Icons.check_circle,
                    ),
                    label: Text(
                      isAvailable ? 'Disable' : 'Enable',
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      _deleteEquipment(document);
                    },
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    label: const Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        onPressed: () {
          _showEquipmentDialog();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Equipment'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _equipmentCollection.orderBy('name').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Error loading equipment:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final documents = snapshot.data?.docs ?? [];

          if (documents.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.agriculture,
                      size: 60,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No equipment added yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Tap "Add Equipment" to create your first equipment.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            children: documents
                .map(
                  (document) => _buildEquipmentCard(
                context,
                document,
              ),
            )
                .toList(),
          );
        },
      ),
    );
  }
}