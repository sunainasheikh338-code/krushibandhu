import 'package:flutter/material.dart';

class FarmerMarketplaceScreen extends StatefulWidget {
  const FarmerMarketplaceScreen({super.key});

  @override
  State<FarmerMarketplaceScreen> createState() =>
      _FarmerMarketplaceScreenState();
}

class _FarmerMarketplaceScreenState extends State<FarmerMarketplaceScreen> {
  final TextEditingController cropController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController contactController = TextEditingController();

  final List<Map<String, String>> crops = [];

  void addCrop() {
    if (cropController.text.isEmpty ||
        quantityController.text.isEmpty ||
        priceController.text.isEmpty ||
        locationController.text.isEmpty ||
        contactController.text.isEmpty) {
      return;
    }

    setState(() {
      crops.add({
        "crop": cropController.text,
        "quantity": quantityController.text,
        "price": priceController.text,
        "location": locationController.text,
        "contact": contactController.text,
      });

      cropController.clear();
      quantityController.clear();
      priceController.clear();
      locationController.clear();
      contactController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Farmer Marketplace"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: cropController,
              decoration: const InputDecoration(labelText: "Crop Name"),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Quantity (kg)"),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Price per kg"),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: "Location"),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: contactController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "Contact Number"),
            ),
            const SizedBox(height: 15),

            ElevatedButton(onPressed: addCrop, child: const Text("Add Crop")),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: crops.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.agriculture,
                        color: Colors.green,
                      ),
                      title: Text(crops[index]["crop"]!),
                      subtitle: Text(
                        "Qty: ${crops[index]["quantity"]} kg\n"
                        "Price: ₹${crops[index]["price"]}/kg\n"
                        "Location: ${crops[index]["location"]}\n"
                        "Contact: ${crops[index]["contact"]}",
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
