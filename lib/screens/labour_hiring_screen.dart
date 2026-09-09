import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LabourHiringScreen extends StatefulWidget {
  final Map<String, dynamic>? user;

  const LabourHiringScreen({super.key, this.user});

  @override
  State<LabourHiringScreen> createState() => _LabourHiringScreenState();
}

class _LabourHiringScreenState extends State<LabourHiringScreen> {
  final TextEditingController labourController = TextEditingController();
  final TextEditingController villageController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  Map<String, dynamic>? selectedLabour;

  int numberOfLabourers = 0;
  double totalCost = 0;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();

    villageController.text = widget.user?['village']?.toString() ?? '';
  }

  void _calculateTotal() {
    final count = int.tryParse(labourController.text.trim()) ?? 0;

    final wage =
        double.tryParse(selectedLabour?['wagePerDay']?.toString() ?? '0') ?? 0;

    setState(() {
      numberOfLabourers = count;
      totalCost = count * wage;
    });
  }

  Future<void> _selectDate() async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));

    final picked = await showDatePicker(
      context: context,
      initialDate: tomorrow,
      firstDate: tomorrow,
      lastDate: DateTime(2050),
    );

    if (picked != null) {
      setState(() {
        dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _hireLabour() async {
    if (selectedLabour == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a labour type")),
      );
      return;
    }

    final count = int.tryParse(labourController.text.trim());

    if (count == null || count <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid number of labourers")),
      );
      return;
    }

    final available =
        int.tryParse(
          selectedLabour?['availableLabourers']?.toString() ?? '0',
        ) ??
        0;

    if (count > available) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Only $available labourers are available")),
      );
      return;
    }

    if (villageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter the village")));
      return;
    }

    if (dateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select the work date")),
      );
      return;
    }

    final farmerId =
        widget.user?['id']?.toString() ??
        widget.user?['userId']?.toString() ??
        '';

    if (farmerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Farmer information not found")),
      );
      return;
    }

    final farmerName = widget.user?['name']?.toString() ?? '';

    final farmerMobile = widget.user?['mobile']?.toString() ?? '';

    final labourTypeId = selectedLabour?['id']?.toString() ?? '';

    final labourTypeName = selectedLabour?['name']?.toString() ?? '';

    final wage =
        double.tryParse(selectedLabour?['wagePerDay']?.toString() ?? '0') ?? 0;

    final totalAmount = count * wage;

    setState(() {
      isSubmitting = true;
    });

    try {
      final firestore = FirebaseFirestore.instance;

      final labourTypeRef = firestore
          .collection('labour_types')
          .doc(labourTypeId);

      final requestRef = firestore.collection('labour_requests').doc();

      await firestore.runTransaction((transaction) async {
        final labourSnapshot = await transaction.get(labourTypeRef);

        if (!labourSnapshot.exists) {
          throw Exception("Labour type is no longer available");
        }

        final labourData = labourSnapshot.data() as Map<String, dynamic>;

        final currentAvailable =
            int.tryParse(labourData['availableLabourers']?.toString() ?? '0') ??
            0;

        final active = labourData['active'] ?? false;

        if (!active) {
          throw Exception("This labour type is currently unavailable");
        }

        if (count > currentAvailable) {
          throw Exception("Only $currentAvailable labourers are available");
        }

        final requestData = <String, dynamic>{
          'requestId': requestRef.id,
          'farmerId': farmerId,
          'farmerName': farmerName,
          'farmerMobile': farmerMobile,
          'village': villageController.text.trim(),
          'labourTypeId': labourTypeId,
          'labourType': labourTypeName,
          'numberOfLabourers': count,
          'wagePerDay': wage,
          'totalCost': totalAmount,
          'workDate': dateController.text.trim(),
          'status': 'Pending',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        transaction.set(requestRef, requestData);

        transaction.update(labourTypeRef, {
          'availableLabourers': currentAvailable - count,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      if (!mounted) return;

      setState(() {
        isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Labour request submitted successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSubmitting = false;
      });

      String message = e.toString();

      if (message.startsWith("Exception: ")) {
        message = message.substring(11);
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  void dispose() {
    labourController.dispose();
    villageController.dispose();
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Labour Hiring"),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('labour_types')
            .where('active', isEqualTo: true)
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

          final labourTypes = snapshot.data?.docs ?? [];

          if (labourTypes.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.engineering, size: 70, color: Colors.grey),
                  SizedBox(height: 15),
                  Text(
                    "No labour types are currently available.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Icon(Icons.engineering, size: 90, color: Colors.green),

                const SizedBox(height: 20),

                DropdownButtonFormField<String>(
                  value: selectedLabour?['id']?.toString(),
                  decoration: const InputDecoration(
                    labelText: "Select Labour Type",
                    border: OutlineInputBorder(),
                  ),
                  items: labourTypes.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    final name = data['name']?.toString() ?? '';

                    final available = data['availableLabourers'] ?? 0;

                    return DropdownMenuItem<String>(
                      value: doc.id,
                      child: Text("$name ($available available)"),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;

                    final selectedDocument = labourTypes.firstWhere(
                      (doc) => doc.id == value,
                    );

                    final data =
                        selectedDocument.data() as Map<String, dynamic>;

                    setState(() {
                      selectedLabour = {'id': selectedDocument.id, ...data};

                      labourController.clear();
                      numberOfLabourers = 0;
                      totalCost = 0;
                    });
                  },
                ),

                const SizedBox(height: 15),

                if (selectedLabour != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedLabour!['name']?.toString() ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Wage: ₹${selectedLabour!['wagePerDay']} / day",
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Available Labourers: "
                          "${selectedLabour!['availableLabourers'] ?? 0}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 15),

                TextField(
                  controller: labourController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Number of Labourers Required",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) {
                    _calculateTotal();
                  },
                ),

                const SizedBox(height: 15),

                if (selectedLabour != null && numberOfLabourers > 0)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "Estimated Cost: ₹"
                      "${totalCost.toStringAsFixed(0)} / day",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                const SizedBox(height: 15),

                // Village
                TextField(
                  controller: villageController,
                  decoration: const InputDecoration(
                    labelText: "Village",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: dateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Work Date",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: _selectDate,
                ),

                const SizedBox(height: 25),

                // Hire button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : _hireLabour,
                    child: isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text("Hire Labour"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
