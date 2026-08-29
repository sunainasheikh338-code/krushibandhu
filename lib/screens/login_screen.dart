import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../language/app_translations.dart';
import '../language/language_provider.dart';
import '../services/database_service.dart';
import 'admin_screen.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController mobileController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  // ============================================================
  // ONLY THIS MOBILE NUMBER CAN ACCESS ADMIN
  // ============================================================

  static const String adminMobile = '9741634709';

  @override
  void dispose() {
    mobileController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // LANGUAGE
  // ============================================================

  Map<String, String> get _lang {
    final languageProvider =
        Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    return AppTranslations.translations[
            languageProvider.locale.languageCode] ??
        AppTranslations.translations["en"]!;
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> login() async {
    final mobile = mobileController.text.trim();
    final password = passwordController.text;

    // ==========================================================
    // EMPTY FIELD CHECK
    // ==========================================================

    if (mobile.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please enter ${_lang["mobile_number"]!} & ${_lang["password"]!}",
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    // ==========================================================
    // MOBILE NUMBER - EXACTLY 10 DIGITS
    // ==========================================================

    if (!RegExp(r'^[0-9]{10}$').hasMatch(mobile)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Enter a valid 10-digit mobile number",
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    // ==========================================================
    // MOBILE NUMBER - MUST START WITH 6, 7, 8 OR 9
    // ==========================================================

    if (!RegExp(r'^[6-9]').hasMatch(mobile)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Mobile number must start with 6, 7, 8 or 9",
          ),
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
          content: Text(
            "Password must be exactly 8 characters",
          ),
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
          content: Text(
            "Password must not contain spaces",
          ),
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

    try {
      // ========================================================
      // DATABASE LOGIN
      // ========================================================

      final user = await DatabaseService.login(
        mobile,
        password,
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      // ========================================================
      // INVALID LOGIN
      // ========================================================

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Invalid Mobile Number or Password",
            ),
            backgroundColor: Colors.red,
          ),
        );

        return;
      }

      // ========================================================
      // ADMIN LOGIN
      //
      // ONLY 9741634709 CAN OPEN ADMIN DASHBOARD
      // ========================================================

      if (mobile == adminMobile) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Admin Login Successful",
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const AdminScreen(),
          ),
        );

        return;
      }

      // ========================================================
      // NORMAL USER LOGIN
      // ========================================================

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Login Successful",
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(user: user),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Login error: $e",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final languageProvider =
        Provider.of<LanguageProvider>(context);

    final lang =
        AppTranslations.translations[
                languageProvider.locale.languageCode] ??
            AppTranslations.translations["en"]!;

    return Scaffold(
      backgroundColor: Colors.green.shade50,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        title: Text(
          lang["login"]!,
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 40),

            // ==================================================
            // ICON
            // ==================================================

            const Icon(
              Icons.agriculture,
              size: 100,
              color: Colors.green,
            ),

            const SizedBox(height: 20),

            // ==================================================
            // WELCOME
            // ==================================================

            Text(
              lang["welcome"]!,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 30),

            // ==================================================
            // MOBILE NUMBER
            // ==================================================

            TextField(
              controller: mobileController,

              keyboardType: TextInputType.phone,

              // ONLY NUMBERS
              // MAXIMUM 10 DIGITS
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],

              decoration: InputDecoration(
                labelText: lang["mobile_number"]!,
                prefixIcon: const Icon(Icons.phone),
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // PASSWORD
            // ==================================================

            TextField(
              controller: passwordController,

              obscureText: obscurePassword,

              // MAXIMUM 8 CHARACTERS
              // NO SPACES
              inputFormatters: [
                LengthLimitingTextInputFormatter(8),
                FilteringTextInputFormatter.deny(
                  RegExp(r'\s'),
                ),
              ],

              decoration: InputDecoration(
                labelText: lang["password"]!,
                prefixIcon: const Icon(Icons.lock),
                border: const OutlineInputBorder(),

                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),

                  onPressed: () {
                    setState(() {
                      obscurePassword =
                          !obscurePassword;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ==================================================
            // LOGIN BUTTON
            // ==================================================

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: isLoading ? null : login,

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,

                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
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
                    : Text(
                        lang["login"]!,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // SIGN UP
            // ==================================================

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const SignupScreen(),
                  ),
                );
              },

              child: Text(
                lang["dont_have_account"]!,
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}