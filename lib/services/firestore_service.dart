import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  static Future<void> createUserProfile(User user) async {
    final doc = _db.collection('users').doc(user.uid);
    final snapshot = await doc.get();
    if (!snapshot.exists) {
      await doc.set({
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'isAnonymous': user.isAnonymous,
      });
    }
  }

  static Future<void> saveTestResult({
    required String userId,
    required String testId,
    required double score,
    required List<Map<String, dynamic>> answers,
  }) async {
    await _db.collection('users').doc(userId).collection('test_results').add({
      'testId': testId,
      'score': score,
      'answers': answers,
      'takenAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> saveUserSubjects(
    String userId,
    List<String> subjects,
  ) async {
    await _db.collection('users').doc(userId).update({'subjects': subjects});
  }

  static Future<List<String>> loadUserSubjects(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    final data = doc.data();
    if (data != null && data['subjects'] != null) {
      return List<String>.from(data['subjects']);
    }
    return [];
  }

  static Future<void> saveSubjectProgress({
    required String userId,
    required String subject,
    required int attempted,
    required int correct,
    required double bestScore,
  }) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('subject_progress')
        .doc(subject)
        .set({
          'attempted': attempted,
          'correct': correct,
          'bestScore': bestScore,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  static Future<Map<String, dynamic>?> loadSubjectProgress(
    String userId,
    String subject,
  ) async {
    final doc = await _db
        .collection('users')
        .doc(userId)
        .collection('subject_progress')
        .doc(subject)
        .get();
    return doc.exists ? doc.data() : null;
  }

  static Future<void> saveMockTestResult({
    required String userId,
    required List<Map<String, dynamic>> subjectResults,
    required double totalScore,
  }) async {
    await _db.collection('users').doc(userId).collection('mock_tests').add({
      'subjectResults': subjectResults,
      'totalScore': totalScore,
      'takenAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> saveQuizResult({
    required String userId,
    required String subject,
    required int correct,
    required int attempted,
    required double score,
  }) async {
    await _db.collection('users').doc(userId).collection('quizzes').add({
      'subject': subject,
      'correct': correct,
      'attempted': attempted,
      'score': score,
      'takenAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    return doc.exists ? doc.data() : null;
  }

  static Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    await _db
        .collection('users')
        .doc(userId)
        .set(data, SetOptions(merge: true));
  }

  // Save or update full user profile
  static Future<void> saveFullUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    await _db
        .collection('users')
        .doc(userId)
        .set(data, SetOptions(merge: true));
  }

  // Upload file to Firebase Storage and return download URL
  static Future<String> uploadFile(
    String userId,
    String path,
    String fileName,
    Uint8List bytes,
  ) async {
    final ref = FirebaseStorage.instance.ref().child(
      'users/$userId/$path/$fileName',
    );
    final uploadTask = await ref.putData(bytes);
    return await uploadTask.ref.getDownloadURL();
  }

  // Save PDF metadata
  static Future<void> savePdf(
    String userId,
    String fileName,
    String url,
  ) async {
    await _db.collection('users').doc(userId).collection('library_pdfs').add({
      'fileName': fileName,
      'url': url,
      'uploadedAt': FieldValue.serverTimestamp(),
    });
  }

  // Save note
  static Future<void> saveNote(String userId, String note) async {
    await _db.collection('users').doc(userId).collection('library_notes').add({
      'note': note,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Save link
  static Future<void> saveLink(
    String userId,
    String link, {
    String? title,
  }) async {
    await _db.collection('users').doc(userId).collection('library_links').add({
      'link': link,
      'title': title,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Fetch leaderboard data (XP and CBT)
  static Future<List<Map<String, dynamic>>> fetchXpLeaderboard(
    String period,
  ) async {
    // period: '24h', 'weekly', 'monthly'
    final query = await _db
        .collection('users')
        .orderBy('xp', descending: true)
        .limit(20)
        .get();
    return query.docs.map((d) => d.data()).toList();
  }

  static Future<List<Map<String, dynamic>>> fetchCbtLeaderboard() async {
    // Example: fetch top CBT scores in last 2 weeks
    final now = DateTime.now();
    final twoWeeksAgo = now.subtract(const Duration(days: 14));
    final query = await _db
        .collectionGroup('mock_tests')
        .where('takenAt', isGreaterThan: Timestamp.fromDate(twoWeeksAgo))
        .orderBy('totalScore', descending: true)
        .limit(20)
        .get();
    return query.docs.map((d) => d.data()).toList();
  }

  // Fetch badges for a user
  static Future<List<Map<String, dynamic>>> fetchUserBadges(
    String userId,
  ) async {
    final query = await _db
        .collection('users')
        .doc(userId)
        .collection('badges')
        .get();
    return query.docs.map((d) => d.data()).toList();
  }

  // Static list of Nigerian tertiary institutions (for dropdowns)
  static List<String> nigerianInstitutions() => [
    'University of Lagos',
    'Obafemi Awolowo University',
    'Ahmadu Bello University',
    'University of Ibadan',
    'Covenant University',
    'Yaba College of Technology',
    'Federal Polytechnic Bida',
    'Nigerian Army University',
    'Federal College of Education Zaria',
    'Lagos State Polytechnic',
    'Babcock University',
    'Nile University',
    'Auchi Polytechnic',
    'Federal University of Technology Akure',
    'Nnamdi Azikiwe University',
    'Federal University of Agriculture Abeokuta',
    'Kaduna Polytechnic',
    'National Open University of Nigeria',
    // ... (expand with full list as needed)
    'Others...',
  ];
}
