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

  static Future<String> ask(String question, {String? userId}) async {
    try {
      if (_groqApiKey.isEmpty) {
        return 'AI service is not configured.';
      }

      final lowerQuestion = question.toLowerCase();

      String databaseContext = '';

      if (_isFertilizerQuestion(lowerQuestion)) {
        databaseContext = await _getFertilizerContext();
      } else if (_isTractorQuestion(lowerQuestion)) {
        databaseContext = await _getTractorContext();
      } else if (_isEquipmentQuestion(lowerQuestion)) {
        databaseContext = await _getEquipmentContext();
      } else if (_isLabourQuestion(lowerQuestion)) {
        databaseContext = await _getLabourContext();
      } else if (_isMarketplaceQuestion(lowerQuestion)) {
        databaseContext = await _getMarketplaceContext();
      } else if (_isMyMarketplaceOrderQuestion(lowerQuestion)) {
        databaseContext = await _getMyMarketplaceOrdersContext(userId);
      } else if (_isMarketplaceQuestion(lowerQuestion)) {
        databaseContext = await _getMarketplaceContext();
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
      return 'No fertilizer data is currently available in System.';
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
      return 'No tractor data is currently available in System.';
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

  static bool _isEquipmentQuestion(String question) {
    const keywords = [
      'equipment',
      'equipments',
      'farm equipment',
      'agricultural equipment',
      'farming equipment',
      'implements',
      'implement',
      'power tiller equipment',
    ];

    return keywords.any(question.contains);
  }

  static Future<String> _getEquipmentContext() async {
    final snapshot = await _firestore.collection('equipment').get();

    if (snapshot.docs.isEmpty) {
      return 'No equipment data is currently available in System.';
    }

    final buffer = StringBuffer();

    buffer.writeln('Equipment available in KrushiBandhu:');

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final name = data['name']?.toString() ?? 'Unknown';

      final type = data['type']?.toString() ?? 'Not available';

      final price = data['price']?.toString() ?? 'Not available';

      final description = data['description']?.toString() ?? 'Not available';

      final isAvailable = data['isAvailable'] == true;

      final compatibleTractorType =
          data['compatibleTractorType']?.toString() ?? 'Not specified';

      buffer.writeln(
        '- Name: $name, '
        'Type: $type, '
        'Price: ₹$price, '
        'Description: $description, '
        'Available: ${isAvailable ? 'Yes' : 'No'}, '
        'Compatible tractor type: $compatibleTractorType',
      );
    }

    return buffer.toString();
  }

  static bool _isLabourQuestion(String question) {
    const keywords = [
      'labour',
      'labor',
      'worker',
      'workers',
      'farm worker',
      'farm workers',
      'hiring',
      'hire worker',
      'labour service',
      'labour services',
    ];

    return keywords.any(question.contains);
  }

  static Future<String> _getLabourContext() async {
    final typesSnapshot = await _firestore.collection('labour_types').get();

    final requestsSnapshot = await _firestore
        .collection('labour_requests')
        .get();

    final buffer = StringBuffer();

    // Labour types
    if (typesSnapshot.docs.isNotEmpty) {
      buffer.writeln('Labour types available in KrushiBandhu:');

      for (final doc in typesSnapshot.docs) {
        final data = doc.data();

        buffer.writeln(
          '- ${data.entries.map((entry) => '${entry.key}: ${entry.value}').join(', ')}',
        );
      }
    } else {
      buffer.writeln('No labour types are currently available.');
    }

    // Labour requests
    if (requestsSnapshot.docs.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('Labour requests in KrushiBandhu:');

      for (final doc in requestsSnapshot.docs) {
        final data = doc.data();

        buffer.writeln(
          '- ${data.entries.map((entry) => '${entry.key}: ${entry.value}').join(', ')}',
        );
      }
    } else {
      buffer.writeln('');
      buffer.writeln('No labour requests are currently available.');
    }

    return buffer.toString();
  }

  static bool _isMarketplaceQuestion(String question) {
    const keywords = [
      'marketplace',
      'farmer marketplace',
      'farm marketplace',
      'market products',
      'products for sale',
      'products farmers are selling',
      'farmers selling',
      'buy from farmer',
      'agricultural products',
    ];

    return keywords.any(question.contains);
  }

  static Future<String> _getMarketplaceContext() async {
    final snapshot = await _firestore
        .collection('farmer_marketplace_listings')
        .get();

    if (snapshot.docs.isEmpty) {
      return 'No farmer marketplace listings are currently available.';
    }

    final buffer = StringBuffer();

    buffer.writeln('Farmer Marketplace listings in KrushiBandhu:');

    for (final doc in snapshot.docs) {
      final data = doc.data();

      buffer.writeln(
        '- ${data.entries.map((entry) => '${entry.key}: ${entry.value}').join(', ')}',
      );
    }

    return buffer.toString();
  }

  static bool _isMyMarketplaceOrderQuestion(String question) {
    const keywords = [
      'my marketplace order',
      'my marketplace orders',
      'my orders',
      'my order',
      'orders i placed',
      'orders i bought',
      'what did i order',
      'what have i ordered',
      'my purchases',
    ];

    return keywords.any(question.contains);
  }

  static Future<String> _getMyMarketplaceOrdersContext(String? userId) async {
    if (userId == null || userId.isEmpty) {
      return 'The logged-in farmer ID is not available.';
    }

    final snapshot = await _firestore
        .collection('farmer_marketplace_orders')
        .where('buyerId', isEqualTo: userId)
        .get();

    if (snapshot.docs.isEmpty) {
      return 'The logged-in farmer has no farmer marketplace orders.';
    }

    final buffer = StringBuffer();

    buffer.writeln(
      'Farmer Marketplace orders belonging to the logged-in farmer:',
    );

    for (final doc in snapshot.docs) {
      final data = doc.data();

      buffer.writeln(
        '- Product: ${data['productName'] ?? 'Unknown'}, '
        'Quantity: ${data['quantity'] ?? 'Unknown'} '
        '${data['unit'] ?? ''}, '
        'Price per unit: ₹${data['pricePerUnit'] ?? 'Unknown'}, '
        'Total amount: ₹${data['totalAmount'] ?? 'Unknown'}, '
        'Seller: ${data['sellerName'] ?? 'Unknown'}, '
        'Status: ${data['status'] ?? 'Unknown'}',
      );
    }

    return buffer.toString();
  }
}
