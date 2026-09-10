import 'package:flutter/material.dart';
import '../services/database_service.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const ProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String id;
  late String name;
  late String mobile;
  late String village;
  late String land;
  late String crop;

  @override
  void initState() {
    super.initState();

    id = widget.user["id"];
    name = widget.user["name"] ?? "";
    mobile = widget.user["mobile"] ?? "";
    village = widget.user["village"] ?? "";
    land = widget.user["land"] ?? "";
    crop = widget.user["crop"] ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Farmer Profile"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 55,
              backgroundColor: Colors.green,
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 60,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Text(
              "Farmer",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            Card(
              child: ListTile(
                leading: const Icon(Icons.phone, color: Colors.green),
                title: const Text("Mobile"),
                subtitle: Text(mobile),
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.location_on, color: Colors.green),
                title: const Text("Village"),
                subtitle: Text(village),
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.agriculture, color: Colors.green),
                title: const Text("Land Area"),
                subtitle: Text(land),
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.grass, color: Colors.green),
                title: const Text("Main Crop"),
                subtitle: Text(crop),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProfileScreen(
                        name: name,
                        mobile: mobile,
                        village: village,
                        land: land,
                        crop: crop,
                      ),
                    ),
                  );

                  if (result != null) {
                    await DatabaseService.updateUser(
                      id,
                      {
                        "name": result["name"],
                        "mobile": result["mobile"],
                        "village": result["village"],
                        "land": result["land"],
                        "crop": result["crop"],
                        "password": widget.user["password"],
                      },
                    );

                    setState(() {
                      name = result["name"];
                      mobile = result["mobile"];
                      village = result["village"];
                      land = result["land"];
                      crop = result["crop"];
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Profile Updated Successfully"),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.edit),
                label: const Text("Edit Profile"),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}