import 'package:flutter/material.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _controller = TextEditingController();

  final List<Map<String, String>> messages = [];

  void sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    String question = _controller.text.toLowerCase();
    String reply = "";

    if (question.contains("fertilizer")) {
      reply =
          "To book fertilizer, open the Fertilizer Booking module, choose the fertilizer, select quantity and booking slot, then confirm your booking.";
    } else if (question.contains("qr")) {
      reply =
          "Open the QR Verification module and scan the fertilizer QR code. The app will verify whether the fertilizer is genuine.";
    } else if (question.contains("tractor")) {
      reply =
          "Go to Tractor Rental, select an available tractor, choose the rental date and submit your request.";
    } else if (question.contains("leftover")) {
      reply =
          "Use the Leftover Fertilizer Selling module to sell unused fertilizer to other farmers.";
    } else if (question.contains("labour")) {
      reply =
          "Open Labour Hiring to search for workers, view their details and hire them.";
    } else if (question.contains("crop")) {
      reply =
          "Crop Reminders notify you about irrigation, fertilizer application, pesticide spraying and harvesting.";
    } else if (question.contains("language")) {
      reply =
          "Multi-language Support lets you use the app in your preferred language.";
    } else if (question.contains("voice")) {
      reply =
          "Voice Assistant allows you to interact with KrushiBandhu using voice commands.";
    } else if (question.contains("market")) {
      reply =
          "Farmer Marketplace allows farmers to buy and sell agricultural products.";
    } else if (question.contains("credit")) {
      reply =
          "Farmer Credit Score is calculated based on farming activities and transaction history.";
    } else if (question.contains("profile")) {
      reply =
          "Open the Profile section to view or update your personal information.";
    } else if (question.contains("admin")) {
      reply =
          "The Admin module manages users, products, bookings and overall system activities.";
    } else if (question.contains("login")) {
      reply =
          "If you cannot log in, check your email and password. If the problem continues, contact the administrator.";
    } else if (question.contains("booking")) {
      reply =
          "You can check your booking status in the Fertilizer Booking module.";
    } else if (question.contains("hello") ||
        question.contains("hi")) {
      reply =
          "Hello! Welcome to KrushiBandhu. How can I help you today?";
    } else {
      reply =
          "Sorry, I couldn't understand your question. Please ask about Fertilizer Booking, QR Verification, Tractor Rental, Leftover Fertilizer Selling, Labour Hiring, Crop Reminders, Multi-language Support, Voice Assistant, Farmer Marketplace, Farmer Credit Score, Profile, Admin or Login.";
    }

    setState(() {
      messages.add({
        "sender": "user",
        "text": _controller.text,
      });

      messages.add({
        "sender": "ai",
        "text": reply,
      });

      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("KrushiBandhu AI Assistant"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];

                bool isUser = msg["sender"] == "user";

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 300),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Colors.green.shade200
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg["text"]!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Ask your question...",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Colors.green,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}