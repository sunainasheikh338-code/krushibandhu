// TODO Implement this library.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminLabourManagementScreen extends StatefulWidget {
  const AdminLabourManagementScreen({super.key});

  @override
  State<AdminLabourManagementScreen> createState() =>
      _AdminLabourManagementScreenState();
}

class _AdminLabourManagementScreenState
    extends State<AdminLabourManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _showLabourDialog({DocumentSnapshot? document}) async {
    final data = document?.data() as Map<String, dynamic>?;

    final nameController = TextEditingController(
      text: data?['name']?.toString() ?? '',
    );

    final wageController = TextEditingController(
      text: data?['wagePerDay']?.toString() ?? '',
    );

    final availableLabourersController = TextEditingController(
      text: data?['availableLabourers']?.toString() ?? '',
    );

    bool active = data?['active'] ?? true;
    bool isSaving = false;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                document == null ? "Add Labour Type" : "Edit Labour Type",
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Labour Type",
                        hintText: "Sowing / Weeding / Harvesting",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: wageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Wage Per Day (₹)",
                        border: OutlineInputBorder(),
                        prefixText: "₹ ",
                      ),
                    ),

                    const SizedBox(height: 15),
                    TextField(
                      controller: availableLabourersController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Number of Labourers",
                        hintText: "Example: 20",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 10),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Available"),
                      value: active,
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
                  onPressed: isSaving
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final name = nameController.text.trim();
                          final wage = double.tryParse(
                            wageController.text.trim(),
                          );

                          final availableLabourers = int.tryParse(
                            availableLabourersController.text.trim(),
                          );

                          if (name.isEmpty ||
                              wage == null ||
                              wage <= 0 ||
                              availableLabourers == null ||
                              availableLabourers < 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Enter valid labour type, wage and number of labourers",
                                ),
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            isSaving = true;
                          });

                          try {
                            final labourData = <String, dynamic>{
                              'name': name,
                              'wagePerDay': wage,
                              'availableLabourers': availableLabourers,
                              'active': active,
                              'updatedAt': FieldValue.serverTimestamp(),
                            };

                            if (document == null) {
                              labourData['createdAt'] =
                                  FieldValue.serverTimestamp();

                              await _firestore
                                  .collection('labour_types')
                                  .add(labourData);
                            } else {
                              await _firestore
                                  .collection('labour_types')
                                  .doc(document.id)
                                  .update(labourData);
                            }

                            if (mounted) {
                              Navigator.pop(dialogContext);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    document == null
                                        ? "Labour type added successfully"
                                        : "Labour type updated successfully",
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            setDialogState(() {
                              isSaving = false;
                            });

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error: $e")),
                              );
                            }
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    wageController.dispose();
    availableLabourersController.dispose();
  }

  Future<void> _toggleLabour(DocumentSnapshot document) async {
    final data = document.data() as Map<String, dynamic>;
    final currentStatus = data['active'] ?? true;

    try {
      await _firestore.collection('labour_types').doc(document.id).update({
        'active': !currentStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              currentStatus ? "Labour type disabled" : "Labour type enabled",
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<void> _deleteLabour(DocumentSnapshot document) async {
    final data = document.data() as Map<String, dynamic>;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Labour Type"),
          content: Text("Are you sure you want to delete ${data['name']}?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await _firestore.collection('labour_types').doc(document.id).delete();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Labour type deleted")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Widget _buildLabourCard(DocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>;

    final name = data['name']?.toString() ?? '';
    final wage = data['wagePerDay'] ?? 0;
    final availableLabourers = data['availableLabourers'] ?? 0;
    final active = data['active'] ?? true;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: active
                  ? Colors.green.shade100
                  : Colors.grey.shade300,
              child: Icon(
                Icons.engineering,
                color: active ? Colors.green : Colors.grey,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Wage: ₹$wage / day",
                    style: const TextStyle(fontSize: 14),
                  ),

                  const SizedBox(height: 5),
                  Text(
                    "Labourers Available: $availableLabourers",
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    active ? "Available" : "Disabled",
                    style: TextStyle(
                      color: active ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showLabourDialog(document: document);
                } else if (value == 'toggle') {
                  _toggleLabour(document);
                } else if (value == 'delete') {
                  _deleteLabour(document);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text("Edit"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(active ? Icons.block : Icons.check_circle),
                      const SizedBox(width: 8),
                      Text(active ? "Disable" : "Enable"),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text("Delete"),
                    ],
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
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('labour_types')
            .orderBy('name')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading labour types:\n${snapshot.error}",
                textAlign: TextAlign.center,
              ),
            );
          }

          final documents = snapshot.data?.docs ?? [];

          if (documents.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.engineering,
                    size: 70,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "No labour types added yet",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: () => _showLabourDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text("Add Labour Type"),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: documents.length,
            itemBuilder: (context, index) {
              return _buildLabourCard(documents[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLabourDialog(),
        icon: const Icon(Icons.add),
        label: const Text("Add Labour"),
      ),
    );
  }
}
