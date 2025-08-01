import 'package:flutter_test/flutter_test.dart';
import 'package:utme_prep_master/data/services/ai_service.dart';

void main() {
  group('AIService Unit Tests', () {
    test('should handle empty message', () async {
      // Test handling of empty message
      final response = await AIService.getAIResponse('');
      expect(response, isA<String>());
      expect(response.isNotEmpty, isTrue);
    });

    test('should handle normal message', () async {
      // Test handling of normal message
      final response = await AIService.getAIResponse('Hello, how are you?');
      expect(response, isA<String>());
      expect(response.isNotEmpty, isTrue);
    });

    test('should handle long message', () async {
      // Test handling of long message
      final longMessage = 'A' * 1000; // Very long message
      final response = await AIService.getAIResponse(longMessage);
      expect(response, isA<String>());
      expect(response.isNotEmpty, isTrue);
    });

    test('should handle special characters', () async {
      // Test handling of special characters
      final specialMessage = 'Hello! How are you? @#\$%^&*()';
      final response = await AIService.getAIResponse(specialMessage);
      expect(response, isA<String>());
      expect(response.isNotEmpty, isTrue);
    });
  });
}
