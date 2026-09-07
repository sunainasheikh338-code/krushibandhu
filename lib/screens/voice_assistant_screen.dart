import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'tractor_rental_screen.dart';
import 'fertilizer_booking_screen.dart';
import 'qr_verification_screen.dart';
import 'leftover_fertilizer_selling_screen.dart';
import 'labour_hiring_screen.dart';
import 'crop_reminder_screen.dart';
import 'multilanguage_screen.dart';
import 'farmer_marketplace_screen.dart';
import 'farmer_credit_score_screen.dart';

class VoiceAssistantScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const VoiceAssistantScreen({super.key, required this.user});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> {
  final SpeechToText speech = SpeechToText();

  String text = "Press the microphone and speak";

  Future<void> startListening() async {
    bool available = await speech.initialize();

    if (available) {
      await speech.listen(
        onResult: (result) {
          if (!mounted) return;

          setState(() {
            text = result.recognizedWords;
          });

          String command = result.recognizedWords.toLowerCase();

          // TRACTOR
          if (command.contains("tractor")) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TractorRentalScreen(user: widget.user),
              ),
            );
          }
          // FERTILIZER BOOKING
          else if (command.contains("fertilizer booking") ||
              command.contains("fertilizer")) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FertilizerBookingScreen(user: widget.user),
              ),
            );
          }
          // QR VERIFICATION
          else if (command.contains("verification") || command.contains("qr")) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QRVerificationScreen()),
            );
          }
          // LEFTOVER FERTILIZER
          else if (command.contains("leftover")) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    LeftoverFertilizerSellingScreen(user: widget.user),
              ),
            );
          }
          // LABOUR
          else if (command.contains("labour") || command.contains("labor")) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LabourHiringScreen()),
            );
          }
          // CROP REMINDER
          else if (command.contains("reminder")) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CropReminderScreen()),
            );
          }
          // LANGUAGE
          else if (command.contains("language")) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MultiLanguageScreen()),
            );
          }
          // MARKETPLACE
          else if (command.contains("market")) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const FarmerMarketplaceScreen(),
              ),
            );
          }
          // CREDIT SCORE
          else if (command.contains("credit")) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const FarmerCreditScoreScreen(),
              ),
            );
          }
        },
      );
    } else {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Speech recognition is not available."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Voice Assistant",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mic, size: 100, color: Colors.green),

              const SizedBox(height: 20),

              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: startListening,
                  icon: const Icon(Icons.mic),
                  label: const Text(
                    "Start Listening",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
