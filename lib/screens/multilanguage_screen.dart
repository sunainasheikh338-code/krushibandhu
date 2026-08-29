import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../language/language_provider.dart';

class MultiLanguageScreen extends StatefulWidget {
  const MultiLanguageScreen({super.key});

  @override
  State<MultiLanguageScreen> createState() => _MultiLanguageScreenState();
}

class _MultiLanguageScreenState extends State<MultiLanguageScreen> {
  String selectedLanguage = "English";

  final Map<String, String> languages = {
    "English": "en",
    "Kannada": "kn",
    "Hindi": "hi",
    "Telugu": "te",
    "Tamil": "ta",
    "Marathi": "mr",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Multi-language Support"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(
              Icons.language,
              size: 90,
              color: Colors.green,
            ),

            const SizedBox(height: 20),

            const Text(
              "Select Your Language",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: selectedLanguage,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: languages.keys.map((language) {
                return DropdownMenuItem(
                  value: language,
                  child: Text(language),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedLanguage = value!;
                });
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  String code = languages[selectedLanguage]!;

                  await Provider.of<LanguageProvider>(
                    context,
                    listen: false,
                  ).changeLanguage(code);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "$selectedLanguage selected successfully",
                      ),
                    ),
                  );

                  Navigator.pop(context);
                },
                child: const Text("Save Language"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}