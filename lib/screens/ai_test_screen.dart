import 'package:flutter/material.dart';
import '../services/ai_service.dart';

class AITestScreen extends StatefulWidget {
  const AITestScreen({super.key});

  @override
  State<AITestScreen> createState() => _AITestScreenState();
}

class _AITestScreenState extends State<AITestScreen> {
  String response = 'Press the button to test Groq.';
  bool loading = false;

  Future<void> testGroq() async {
    setState(() {
      loading = true;
      response = 'Asking Groq...';
    });

    try {
      final result = await AIService.ask('Hi?');

      setState(() {
        response = result;
        loading = false;
      });
    } catch (e) {
      setState(() {
        response = 'ERROR:\n$e';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groq Test'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(response, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: loading ? null : testGroq,
              child: Text(loading ? 'Testing...' : 'Test Groq'),
            ),
          ],
        ),
      ),
    );
  }
}
