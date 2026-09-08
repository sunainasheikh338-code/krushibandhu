import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// import '../services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController villageController = TextEditingController();
  final TextEditingController landController = TextEditingController();
  final TextEditingController cropController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    villageController.dispose();
    landController.dispose();
    cropController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // ============================================================
  // REGISTER USER
  // ============================================================

  Future<void> registerUser() async {
    final name = nameController.text.trim();
    final mobile = mobileController.text.trim();
    final village = villageController.text.trim();
    final land = landController.text.trim();
    final crop = cropController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    // ==========================================================
    // EMPTY FIELD CHECK
    // ==========================================================

    if (name.isEmpty ||
        mobile.isEmpty ||
        village.isEmpty ||
        land.isEmpty ||
        crop.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ==========================================================
    // FULL NAME
    // ==========================================================

    if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Full Name should contain letters and spaces only"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ==========================================================
    // MOBILE NUMBER
    // ==========================================================

    if (!RegExp(r'^[0-9]{10}$').hasMatch(mobile)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter a valid 10-digit mobile number"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ==========================================================
    // MOBILE START
    // ==========================================================

    if (!RegExp(r'^[6-9]').hasMatch(mobile)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mobile number must start with 6, 7, 8 or 9"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ==========================================================
    // VILLAGE
    // ==========================================================

    if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(village)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Village should contain letters and spaces only"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ==========================================================
    // LAND AREA
    // ==========================================================

    if (!RegExp(r'^[0-9]+(\.[0-9]+)?$').hasMatch(land)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Land Area should contain numbers only"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ==========================================================
    // MAIN CROP
    // ==========================================================

    if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(crop)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Main Crop should contain letters and spaces only"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ==========================================================
    // PASSWORD - EXACTLY 8 CHARACTERS
    // ==========================================================

    if (password.length != 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password must be exactly 8 characters"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ==========================================================
    // PASSWORD - UPPERCASE
    // ==========================================================

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password must contain at least one uppercase letter"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ==========================================================
    // PASSWORD - LOWERCASE
    // ==========================================================

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password must contain at least one lowercase letter"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ==========================================================
    // PASSWORD - NUMBER
    // ==========================================================

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password must contain at least one number"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ==========================================================
    // PASSWORD - SPECIAL CHARACTER
    // ==========================================================

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-\\/\[\]+=]').hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password must contain at least one special character"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ==========================================================
    // PASSWORD - NO SPACES
    // ==========================================================

    if (password.contains(' ')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password must not contain spaces"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ==========================================================
    // CONFIRM PASSWORD
    // ==========================================================

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ==========================================================
    // START LOADING
    // ==========================================================

    setState(() {
      isLoading = true;
    });

    // try {
    //   await DatabaseService.insertUser({
    //     "name": name,
    //     "mobile": mobile,
    //     "village": village,
    //     "land": land,
    //     "crop": crop,
    //     "password": password,
    //   });
    //
    //   if (!mounted) return;
    //
    //   setState(() {
    //     isLoading = false;
    //   });
    //
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text("Registration Successful"),
    //       backgroundColor: Colors.green,
    //     ),
    //   );
    //
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(
    //       builder: (_) => const LoginScreen(),
    //     ),
    //   );
    // }
    // catch (e) {
    try {
      final existingUser = await FirebaseFirestore.instance
          .collection('users')
          .where('mobile', isEqualTo: mobile)
          .limit(1)
          .get();

      if (existingUser.docs.isNotEmpty) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Mobile number already registered"),
            backgroundColor: Colors.red,
          ),
        );

        return;
      }

      final userDocument = FirebaseFirestore.instance.collection('users').doc();

      await userDocument.set({
        "userId": userDocument.id,
        "name": name,
        "mobile": mobile,
        "village": village,
        "land": land,
        "crop": crop,
        "password": password,
        "role": "farmer",
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registration Successful"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mobile number already registered"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscure,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,

      appBar: AppBar(
        title: const Text("User Registration"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const Icon(Icons.person_add, size: 100, color: Colors.green),

            const SizedBox(height: 20),

            const Text(
              "Create Your Account",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 30),

            // ==================================================
            // FULL NAME
            // ==================================================
            buildTextField(
              nameController,
              "Full Name",
              Icons.person,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
              ],
            ),

            // ==================================================
            // MOBILE
            // ==================================================
            buildTextField(
              mobileController,
              "Mobile Number",
              Icons.phone,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
            ),

            // ==================================================
            // VILLAGE
            // ==================================================
            buildTextField(
              villageController,
              "Village",
              Icons.location_on,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
              ],
            ),

            // ==================================================
            // LAND AREA
            // ==================================================
            buildTextField(
              landController,
              "Land Area (Acres)",
              Icons.agriculture,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
            ),

            // ==================================================
            // MAIN CROP
            // ==================================================
            buildTextField(
              cropController,
              "Main Crop",
              Icons.grass,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
              ],
            ),

            // ==================================================
            // PASSWORD
            // ==================================================
            buildTextField(
              passwordController,
              "Password",
              Icons.lock,
              obscure: obscurePassword,

              inputFormatters: [
                LengthLimitingTextInputFormatter(8),
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
              ],

              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    obscurePassword = !obscurePassword;
                  });
                },
              ),
            ),

            // ==================================================
            // CONFIRM PASSWORD
            // ==================================================
            buildTextField(
              confirmPasswordController,
              "Confirm Password",
              Icons.lock_outline,
              obscure: obscureConfirmPassword,

              inputFormatters: [
                LengthLimitingTextInputFormatter(8),
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
              ],

              suffixIcon: IconButton(
                icon: Icon(
                  obscureConfirmPassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    obscureConfirmPassword = !obscureConfirmPassword;
                  });
                },
              ),
            ),

            const SizedBox(height: 5),

            // ==================================================
            // PASSWORD REQUIREMENTS
            // ==================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade200),
              ),

              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    "Password must contain:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text("• Exactly 8 characters"),
                  Text("• At least one uppercase letter (A-Z)"),
                  Text("• At least one lowercase letter (a-z)"),
                  Text("• At least one number (0-9)"),
                  Text("• At least one special character"),
                  Text("• No spaces"),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // ==================================================
            // REGISTER BUTTON
            // ==================================================
            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: isLoading ? null : registerUser,

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,

                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),

                child: isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,

                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Register",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
              ),
            ),

            // ==================================================
            // LOGIN
            // ==================================================
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },

              child: const Text("Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }
}
