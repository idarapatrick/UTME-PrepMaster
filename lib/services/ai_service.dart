import 'dart:convert';
import 'package:http/http.dart' as http;
import '../secrets.dart';

class AIService {
  static const String _apiKey = geminiAPIKey;
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  static Future<String> getAIResponse(String message) async {
    final response = await http.post(
      Uri.parse('$_baseUrl?key=$geminiAPIKey'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": message}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      print('Error: ${response.statusCode}, ${response.body}');
      return 'Sorry, something went wrong. Please try again later.';
    }
  }
}
