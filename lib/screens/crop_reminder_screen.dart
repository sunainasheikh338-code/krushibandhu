import 'package:flutter/material.dart';

class CropReminderScreen extends StatefulWidget {
  const CropReminderScreen({super.key});

  @override
  State<CropReminderScreen> createState() => _CropReminderScreenState();
}

class _CropReminderScreenState extends State<CropReminderScreen> {
  final TextEditingController cropController = TextEditingController();
  final TextEditingController activityController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crop Reminder"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(
              Icons.notifications_active,
              size: 90,
              color: Colors.green,
            ),

            const SizedBox(height: 20),

            TextField(
              controller: cropController,
              decoration: const InputDecoration(
                labelText: "Crop Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              items: const [
                DropdownMenuItem(
                  value: "Watering",
                  child: Text("Watering"),
                ),
                DropdownMenuItem(
                  value: "Fertilizer",
                  child: Text("Fertilizer"),
                ),
                DropdownMenuItem(
                  value: "Pesticide",
                  child: Text("Pesticide"),
                ),
                DropdownMenuItem(
                  value: "Harvest",
                  child: Text("Harvest"),
                ),
              ],
              decoration: const InputDecoration(
                labelText: "Reminder Type",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                activityController.text = value!;
              },
            ),

            const SizedBox(height: 15),

            TextField(
              controller: dateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Reminder Date",
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
              controller: timeController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Reminder Time",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.access_time),
              ),
              onTap: () async {
                TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );

                if (picked != null) {
                  timeController.text = picked.format(context);
                }
              },
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Reminder Saved Successfully"),
                    ),
                  );
                },
                child: const Text("Save Reminder"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}