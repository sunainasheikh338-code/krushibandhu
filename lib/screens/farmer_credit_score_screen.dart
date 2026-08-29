import 'package:flutter/material.dart';

class FarmerCreditScoreScreen extends StatefulWidget {
  const FarmerCreditScoreScreen({super.key});

  @override
  State<FarmerCreditScoreScreen> createState() =>
      _FarmerCreditScoreScreenState();
}

class _FarmerCreditScoreScreenState
    extends State<FarmerCreditScoreScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController landController = TextEditingController();
  final TextEditingController incomeController = TextEditingController();

  int score = 0;
  String rating = "";

  void calculateScore() {
    double land = double.tryParse(landController.text) ?? 0;
    double income = double.tryParse(incomeController.text) ?? 0;

    score = 300;

    if (land >= 1) score += 100;
    if (land >= 3) score += 100;

    if (income >= 50000) score += 150;
    if (income >= 100000) score += 150;

    if (score > 900) score = 900;

    if (score >= 800) {
      rating = "Excellent";
    } else if (score >= 700) {
      rating = "Good";
    } else if (score >= 600) {
      rating = "Average";
    } else {
      rating = "Needs Improvement";
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Farmer Credit Score"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Farmer Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: landController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Land (Acres)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: incomeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Annual Income",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: calculateScore,
                child: const Text("Calculate Credit Score"),
              ),
            ),

            const SizedBox(height: 30),

            Text(
              "Credit Score : $score",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              rating,
              style: const TextStyle(
                fontSize: 22,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}