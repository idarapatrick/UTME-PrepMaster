import 'package:cloud_firestore/cloud_firestore.dart';

class UsernameService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Username validation rules
  static const List<String> _forbiddenCharacters = [
    '-',
    '(',
    ')',
    ',',
    '&',
    '%',
    '#',
    '!',
    '@',
    '\$',
    '^',
    '*',
    '+',
    '=',
    '[',
    ']',
    '{',
    '}',
    '|',
    '\\',
    ':',
    ';',
    '"',
    "'",
    '<',
    '>',
    '?',
    '/',
    '`',
    '~',
  ];

  /// Validates username according to the specified rules
  static String? validateUsername(String username) {
    // Check length
    if (username.length < 5) {
      return 'Username must be at least 5 characters long';
    }

    // Check for forbidden characters
    for (final char in _forbiddenCharacters) {
      if (username.contains(char)) {
        return 'Username cannot contain special characters like $char';
      }
    }

    // Check for spaces
    if (username.contains(' ')) {
      return 'Username cannot contain spaces';
    }

    // Check if it starts with a number
    if (username[0].contains(RegExp(r'[0-9]'))) {
      return 'Username cannot start with a number';
    }

    // Check if it's all lowercase
    if (username != username.toLowerCase()) {
      return 'Username must be all lowercase';
    }

    return null; // Valid username
  }

  /// Checks if username is available (not already taken)
  static Future<bool> isUsernameAvailable(String username) async {
    try {
      final querySnapshot = await _db
          .collection('users')
          .where('username', isEqualTo: username.toLowerCase())
          .limit(1)
          .get();

      return querySnapshot.docs.isEmpty;
    } catch (e) {
      print('Error checking username availability: $e');
      return false;
    }
  }

  /// Validates and checks availability of username
  static Future<Map<String, dynamic>> validateAndCheckUsername(
    String username,
  ) async {
    // First validate the format
    final validationError = validateUsername(username);
    if (validationError != null) {
      return {'isValid': false, 'error': validationError, 'isAvailable': false};
    }

    // Then check availability
    final isAvailable = await isUsernameAvailable(username);
    return {
      'isValid': true,
      'isAvailable': isAvailable,
      'error': isAvailable ? null : 'Username is already taken',
    };
  }

  /// Gets username by user ID
  static Future<String?> getUsernameByUserId(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data()?['username'];
      }
      return null;
    } catch (e) {
      print('Error getting username: $e');
      return null;
    }
  }

  /// Updates username for a user
  static Future<bool> updateUsername(String userId, String newUsername) async {
    try {
      // Check if username is available
      final isAvailable = await isUsernameAvailable(newUsername);
      if (!isAvailable) {
        return false;
      }

      // Update the user document
      await _db.collection('users').doc(userId).update({
        'username': newUsername.toLowerCase(),
      });

      return true;
    } catch (e) {
      print('Error updating username: $e');
      return false;
    }
  }
}
