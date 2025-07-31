import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String _baseUrl = 'https://gemini-api.up.railway.app/ai';

  static Future<String> getAIResponse(String message) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? 'Sorry, I couldn\'t generate a response.';
      } else {
        // Error: ${response.statusCode}, ${response.body}
        return 'Sorry, something went wrong. Please try again later.';
      }
    } catch (e) {
      // Network error
      return 'Sorry, there was a network error. Please check your connection and try again.';
    }
  }
}
