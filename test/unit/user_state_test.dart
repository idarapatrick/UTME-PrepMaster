import 'package:flutter_test/flutter_test.dart';
import 'package:utme_prep_master/presentation/providers/user_state.dart';

void main() {
  group('UserState Unit Tests', () {
    test('should initialize with null values', () {
      final userState = UserState();

      expect(userState.avatarUrl, isNull);
      expect(userState.displayName, isNull);
    });

    test('should set avatar URL', () {
      final userState = UserState();
      const testUrl = 'https://example.com/avatar.jpg';

      userState.setAvatar(testUrl);

      expect(userState.avatarUrl, equals(testUrl));
    });

    test('should set display name', () {
      final userState = UserState();
      const testName = 'John Doe';

      userState.setDisplayName(testName);

      expect(userState.displayName, equals(testName));
    });

    test('should load user profile', () {
      final userState = UserState();
      final profile = {
        'avatarUrl': 'https://example.com/avatar.jpg',
        'displayName': 'Jane Smith',
      };

      userState.loadUserProfile(profile);

      expect(userState.avatarUrl, equals('https://example.com/avatar.jpg'));
      expect(userState.displayName, equals('Jane Smith'));
    });

    test('should handle profile with null values', () {
      final userState = UserState();
      final profile = {'avatarUrl': null, 'displayName': null};

      userState.loadUserProfile(profile);

      expect(userState.avatarUrl, isNull);
      expect(userState.displayName, isNull);
    });

    test('should handle partial profile data', () {
      final userState = UserState();
      final profile = {
        'avatarUrl': 'https://example.com/avatar.jpg',
        // displayName not provided
      };

      userState.loadUserProfile(profile);

      expect(userState.avatarUrl, equals('https://example.com/avatar.jpg'));
      expect(userState.displayName, isNull);
    });
  });
}
