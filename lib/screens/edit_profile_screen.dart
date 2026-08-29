import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  final String name;
  final String mobile;
  final String village;
  final String land;
  final String crop;

  const EditProfileScreen({
    super.key,
    required this.name,
    required this.mobile,
    required this.village,
    required this.land,
    required this.crop,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController mobileController;
  late TextEditingController villageController;
  late TextEditingController landController;
  late TextEditingController cropController;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.name);
    mobileController = TextEditingController(text: widget.mobile);
    villageController = TextEditingController(text: widget.village);
    landController = TextEditingController(text: widget.land);
    cropController = TextEditingController(text: widget.crop);
  }

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    villageController.dispose();
    landController.dispose();
    cropController.dispose();
    super.dispose();
  }

  void saveProfile() {
    Navigator.pop(context, {
      "name": nameController.text.trim(),
      "mobile": mobileController.text.trim(),
      "village": villageController.text.trim(),
      "land": landController.text.trim(),
      "crop": cropController.text.trim(),
    });
  }

  Widget buildField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            buildField(nameController, "Full Name", Icons.person),
            buildField(mobileController, "Mobile Number", Icons.phone),
            buildField(villageController, "Village", Icons.location_on),
            buildField(landController, "Land Area", Icons.agriculture),
            buildField(cropController, "Main Crop", Icons.grass),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  "Save Changes",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}