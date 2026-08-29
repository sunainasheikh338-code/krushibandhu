import 'package:flutter/material.dart';

class LeftoverFertilizerSellingScreen extends StatefulWidget {
  const LeftoverFertilizerSellingScreen({super.key});

  @override
  State<LeftoverFertilizerSellingScreen> createState() =>
      _LeftoverFertilizerSellingScreenState();
}

class _LeftoverFertilizerSellingScreenState
    extends State<LeftoverFertilizerSellingScreen> {

  final TextEditingController fertilizerController =
      TextEditingController();

  final TextEditingController quantityController =
      TextEditingController();

  final TextEditingController expiryDateController =
      TextEditingController();

  final TextEditingController priceController =
      TextEditingController();

  final TextEditingController villageController =
      TextEditingController();

  final TextEditingController mobileController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Leftover Fertilizer Selling"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            const Icon(
              Icons.inventory_2,
              size: 90,
              color: Colors.green,
            ),

            const SizedBox(height: 20),

            TextField(
              controller: fertilizerController,
              decoration: const InputDecoration(
                labelText: "Fertilizer Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Quantity (kg)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: expiryDateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Expiry Date",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2050),
                );

                if (pickedDate != null) {
                  expiryDateController.text =
                      "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                }
              },
            ),

            const SizedBox(height: 15),

            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Price (₹)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: villageController,
              decoration: const InputDecoration(
                labelText: "Village",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: mobileController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Mobile Number",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Fertilizer Listed Successfully",
                      ),
                    ),
                  );
                },
                child: const Text("Sell Fertilizer"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}