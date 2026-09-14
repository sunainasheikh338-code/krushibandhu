import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class AIService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _groqApiKey = String.fromEnvironment('GROQ_API_KEY');

  static const String _groqUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  static const String _model = 'openai/gpt-oss-20b';

  static const String _systemInstruction = '''
You are KrushiBandhu AI Assistant.

KrushiBandhu is an agriculture-focused application that helps farmers
with fertilizers, tractors, equipment, crop reminders, labour services,
marketplace services, bookings, and other farming-related activities.

Rules:

1. Greetings and normal conversation:
   Respond naturally and politely.

2. Agriculture and KrushiBandhu questions:
   Give useful and simple answers.
   If application data is provided, use that data accurately.

3. Unrelated questions:
   Politely explain that you are focused on KrushiBandhu and
   agriculture-related topics.

4. Never invent application data.
   If the provided application data does not contain the requested
   information, clearly say that the information is not available.

5. Keep answers simple and useful for farmers.

6. When application data is provided, do not change or invent
   prices, availability, names, quantities, or other values.
''';

  static Future<String> ask(String question) async {
    try {
      if (_groqApiKey.isEmpty) {
        return 'AI service is not configured.';
      }

      final lowerQuestion = question.toLowerCase();

      String databaseContext = '';

      // Fertilizer
      if (_isFertilizerQuestion(lowerQuestion)) {
        databaseContext = await _getFertilizerContext();
      }
      // Tractor
      else if (_isTractorQuestion(lowerQuestion)) {
        databaseContext = await _getTractorContext();
      }

      final prompt =
          '''
$_systemInstruction

Application data from KrushiBandhu:
$databaseContext

User question:
$question

Answer the user based on the rules above.
''';

      final response = await http.post(
        Uri.parse(_groqUrl),
        headers: {
          'Authorization': 'Bearer $_groqApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'system', 'content': _systemInstruction},
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.2,
        }),
      );

      if (response.statusCode != 200) {
        return 'Unable to get a response from the AI service.';
      }

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      final choices = responseData['choices'] as List<dynamic>?;

      if (choices == null || choices.isEmpty) {
        return 'I could not generate a response.';
      }

      final firstChoice = choices.first as Map<String, dynamic>;

      final message = firstChoice['message'] as Map<String, dynamic>?;

      final content = message?['content']?.toString();

      if (content == null || content.trim().isEmpty) {
        return 'I could not generate a response.';
      }

      return content.trim();
    } catch (e) {
      return 'Unable to connect to the AI service.';
    }
  }

  static bool _isFertilizerQuestion(String question) {
    const keywords = [
      'fertilizer',
      'fertiliser',
      'fertilizers',
      'fertilisers',
      'urea',
      'dap',
      'npk',
      'manure',
    ];

    return keywords.any(question.contains);
  }

  static Future<String> _getFertilizerContext() async {
    final snapshot = await _firestore.collection('fertilizers').get();

    if (snapshot.docs.isEmpty) {
      return 'No fertilizer data is currently available in Firestore.';
    }

    final buffer = StringBuffer();

    buffer.writeln('Fertilizers available in KrushiBandhu:');

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final name = data['name']?.toString() ?? 'Unknown';
      final price = data['price']?.toString() ?? 'Not available';
      final stock = data['stock']?.toString() ?? 'Not available';
      final active = data['active'];

      buffer.writeln(
        '- Name: $name, '
        'Price: $price, '
        'Stock: $stock, '
        'Active: ${active == true ? 'Yes' : 'No'}',
      );
    }

    return buffer.toString();
  }

  static bool _isTractorQuestion(String question) {
    const keywords = [
      'tractor',
      'tractors',
      'tractor rental',
      'rent tractor',
      'rent a tractor',
      'power tiller',
    ];

    return keywords.any(question.contains);
  }

  static Future<String> _getTractorContext() async {
    final snapshot = await _firestore.collection('tractor_listings').get();

    if (snapshot.docs.isEmpty) {
      return 'No tractor data is currently available in Firestore.';
    }

    final buffer = StringBuffer();

    buffer.writeln('Tractors listed in KrushiBandhu:');

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final tractorName = data['tractorName']?.toString() ?? 'Unknown';

      final brand = data['brand']?.toString() ?? 'Not available';

      final model = data['model']?.toString() ?? 'Not available';

      final tractorType = data['tractorType']?.toString() ?? 'Not available';

      final village = data['village']?.toString() ?? 'Not available';

      final pricePerHour = data['pricePerHour']?.toString() ?? 'Not available';

      final pricePerDay = data['pricePerDay']?.toString() ?? 'Not available';

      final labourAvailable = data['labourAvailable'] == true;

      final labourCharge = data['labourCharge']?.toString() ?? 'Not available';

      final isAvailable = data['isAvailable'] == true;

      buffer.writeln(
        '- Tractor: $tractorName, '
        'Brand: $brand, '
        'Model: $model, '
        'Type: $tractorType, '
        'Village: $village, '
        'Price per hour: ₹$pricePerHour, '
        'Price per day: ₹$pricePerDay, '
        'Labour available: ${labourAvailable ? 'Yes' : 'No'}, '
        'Labour charge: ₹$labourCharge, '
        'Available: ${isAvailable ? 'Yes' : 'No'}',
      );
    }

    return buffer.toString();
  }
}
