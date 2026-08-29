import 'package:flutter/material.dart';

class LabourHiringScreen extends StatefulWidget {
  const LabourHiringScreen({super.key});

  @override
  State<LabourHiringScreen> createState() => _LabourHiringScreenState();
}

class _LabourHiringScreenState extends State<LabourHiringScreen> {
  final TextEditingController workController = TextEditingController();
  final TextEditingController labourController = TextEditingController();
  final TextEditingController wageController = TextEditingController();
  final TextEditingController villageController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Labour Hiring"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(
              Icons.engineering,
              size: 90,
              color: Colors.green,
            ),

            const SizedBox(height: 20),

            TextField(
              controller: workController,
              decoration: const InputDecoration(
                labelText: "Type of Work",
                hintText: "Sowing / Weeding / Harvesting",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: labourController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Number of Labourers",
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
              controller: dateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Work Date",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2050),
                );

                if (picked != null) {
                  dateController.text =
                      "${picked.day}/${picked.month}/${picked.year}";
                }
              },
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
                      content: Text("Labour Request Posted Successfully"),
                    ),
                  );
                },
                child: const Text("Hire Labour"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}