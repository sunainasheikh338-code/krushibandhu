import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/local_notification_service.dart';

class CropReminderScreen extends StatefulWidget {
  const CropReminderScreen({super.key});

  @override
  State<CropReminderScreen> createState() => _CropReminderScreenState();
}

class _CropReminderScreenState extends State<CropReminderScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> _getReminders() {
    return _firestore
        .collection('crop_reminders')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  void _openAddReminder() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddCropReminderScreen()),
    );
  }

  Future<void> _deleteReminder(String reminderId) async {
    await _firestore.collection('crop_reminders').doc(reminderId).delete();

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Reminder deleted")));
  }

  void _showDeleteConfirmation(String reminderId, String cropName) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Delete Reminder"),
          content: Text("Do you want to delete the reminder for $cropName?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _deleteReminder(reminderId);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  String _formatTimestamp(dynamic value) {
    if (value is Timestamp) {
      final date = value.toDate();

      return "${date.day.toString().padLeft(2, '0')}/"
          "${date.month.toString().padLeft(2, '0')}/"
          "${date.year}";
    }

    return "Date not available";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Crop Reminder",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _getReminders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading reminders:\n${snapshot.error}",
                textAlign: TextAlign.center,
              ),
            );
          }

          final reminders = snapshot.data?.docs ?? [];

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _openAddReminder,
                    icon: const Icon(Icons.add),
                    label: const Text(
                      "Add Reminder",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "My Reminders",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: reminders.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_none,
                              size: 70,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 12),
                            Text(
                              "No reminders yet",
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Tap Add Reminder to create one",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: reminders.length,
                        itemBuilder: (context, index) {
                          final doc = reminders[index];
                          final data = doc.data();

                          final cropName = data['cropName'] ?? 'Unknown Crop';

                          final activity = data['activity'] ?? 'Reminder';

                          final reminderDate = data['reminderDate'] ?? '';

                          final reminderTime = data['reminderTime'] ?? '';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 3,
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
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.agriculture,
                                          color: Colors.green,
                                          size: 28,
                                        ),
                                      ),

                                      const SizedBox(width: 12),

                                      Expanded(
                                        child: Text(
                                          cropName,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),

                                      IconButton(
                                        onPressed: () {
                                          _showDeleteConfirmation(
                                            doc.id,
                                            cropName,
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.notifications_active,
                                        size: 20,
                                        color: Colors.green,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        activity,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        size: 20,
                                        color: Colors.green,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(reminderDate),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        size: 20,
                                        color: Colors.green,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(reminderTime),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class AddCropReminderScreen extends StatefulWidget {
  const AddCropReminderScreen({super.key});

  @override
  State<AddCropReminderScreen> createState() => _AddCropReminderScreenState();
}

class _AddCropReminderScreenState extends State<AddCropReminderScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController cropController = TextEditingController();

  final TextEditingController activityController = TextEditingController();

  final TextEditingController dateController = TextEditingController();

  final TextEditingController timeController = TextEditingController();

  DateTime? selectedReminderDateTime;

  bool _isSaving = false;

  Future<void> _saveReminder() async {
    if (cropController.text.trim().isEmpty ||
        activityController.text.trim().isEmpty ||
        dateController.text.trim().isEmpty ||
        timeController.text.trim().isEmpty ||
        selectedReminderDateTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final reminderRef = _firestore.collection('crop_reminders').doc();

      await reminderRef.set({
        'reminderId': reminderRef.id,
        'cropName': cropController.text.trim(),
        'activity': activityController.text.trim(),
        'reminderDate': dateController.text.trim(),
        'reminderTime': timeController.text.trim(),
        'reminderAt': Timestamp.fromDate(selectedReminderDateTime!),
        'createdAt': FieldValue.serverTimestamp(),
        'notificationSent': false,
      });

      await LocalNotificationService.scheduleNotification(
        id: reminderRef.id.hashCode,
        title: '${cropController.text.trim()} Reminder 🌱',
        message: 'Time for ${activityController.text.trim()}',
        scheduledDate: selectedReminderDateTime!,
      );

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to save reminder: $e")));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    cropController.dispose();
    activityController.dispose();
    dateController.dispose();
    timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add Crop Reminder",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
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
                DropdownMenuItem(value: "Watering", child: Text("Watering")),
                DropdownMenuItem(
                  value: "Fertilizer",
                  child: Text("Fertilizer"),
                ),
                DropdownMenuItem(value: "Pesticide", child: Text("Pesticide")),
                DropdownMenuItem(value: "Harvest", child: Text("Harvest")),
              ],
              decoration: const InputDecoration(
                labelText: "Reminder Type",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                activityController.text = value ?? '';
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
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2050),
                );

                if (picked != null) {
                  dateController.text =
                      "${picked.day}/${picked.month}/${picked.year}";

                  selectedReminderDateTime = DateTime(
                    picked.year,
                    picked.month,
                    picked.day,
                  );
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
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );

                if (picked != null) {
                  timeController.text = picked.format(context);

                  if (selectedReminderDateTime != null) {
                    selectedReminderDateTime = DateTime(
                      selectedReminderDateTime!.year,
                      selectedReminderDateTime!.month,
                      selectedReminderDateTime!.day,
                      picked.hour,
                      picked.minute,
                    );
                  }
                }
              },
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveReminder,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(_isSaving ? "Saving..." : "Save Reminder"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
