import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String _apiKey = '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';
  static const String _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';

  static Future<String> getAIResponse(String message) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://yourdomain.com', 
      },
      body: jsonEncode({
        "model": "mistralai/mixtral-8x7b",
        "messages": [
          {"role": "system", "content": "You are an AI tutor helping students prepare for UTME exams."},
          {"role": "user", "content": message}
        ],
        "temperature": 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      print('Error: ${response.statusCode}, ${response.body}');
      return 'Sorry, something went wrong. Please try again later.';
    }
  }
}
