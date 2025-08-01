import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/test_question.dart';

class CbtQuestionService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ===== DEVELOPER FUNCTIONS (for uploading questions) =====

  // Upload questions for a specific subject (Developer use only)
  static Future<void> uploadSubjectQuestions({
    required String subject,
    required List<TestQuestion> questions,
    required String examYear,
    String? description,
    String? difficulty,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Check if user is admin/developer
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userRole = userDoc.data()?['role'] ?? 'user';

      if (userRole != 'admin' && userRole != 'developer') {
        throw Exception('Only developers can upload questions');
      }

      final batch = _firestore.batch();

      for (int i = 0; i < questions.length; i++) {
        final question = questions[i];
        final questionRef = _firestore
            .collection('cbt_questions')
            .doc(subject.toLowerCase())
            .collection('questions')
            .doc();

        final questionData = {
          'id': questionRef.id,
          'subject': subject,
          'examYear': examYear,
          'questionNumber': i + 1,
          'question': question.question,
          'options': question.options,
          'correctAnswer': question.correctAnswer,
          'explanation': question.explanation,
          'difficulty': question.difficulty ?? difficulty ?? 'medium',
          'topic': question.topic ?? '',
          'uploadedBy': user.uid,
          'uploadedAt': FieldValue.serverTimestamp(),
          'description': description ?? 'CBT Practice Questions',
          'isActive': true,
          'isVerified': false, // Questions need verification
        };

        batch.set(questionRef, questionData);
      }

      // Create subject metadata
      final subjectRef = _firestore
          .collection('cbt_questions')
          .doc(subject.toLowerCase());

      final subjectData = {
        'subject': subject,
        'totalQuestions': questions.length,
        'examYear': examYear,
        'description': description ?? 'CBT Practice Questions',
        'lastUpdated': FieldValue.serverTimestamp(),
        'uploadedBy': user.uid,
        'isActive': true,
        'difficulty': difficulty ?? 'medium',
      };

      batch.set(subjectRef, subjectData, SetOptions(merge: true));

      await batch.commit();
      // Successfully uploaded questions for subject
    } catch (e) {
      // Error uploading questions
      rethrow;
    }
  }

  // ===== USER FUNCTIONS (for accessing questions) =====

  // Get all available subjects for CBT tests
  static Future<List<String>> getAvailableSubjects() async {
    try {
      final snapshot = await _firestore
          .collection('cbt_questions')
          .where('isActive', isEqualTo: true)
          .get();
      return snapshot.docs
          .map((doc) => doc.data()['subject'] as String)
          .toList();
    } catch (e) {
      // Error getting available subjects
      return [];
    }
  }

  // Get questions for a specific subject (User access)
  static Future<List<TestQuestion>> getQuestionsForSubject(
    String subject,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('cbt_questions')
          .doc(subject.toLowerCase())
          .collection('questions')
          .where('isActive', isEqualTo: true)
          .where('isVerified', isEqualTo: true) // Only verified questions
          .orderBy('questionNumber')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        final dataMap = data as Map<String, dynamic>?;
        return TestQuestion(
          id: dataMap?['id'] ?? doc.id,
          question: dataMap?['question'] ?? '',
          options: List<String>.from(dataMap?['options'] ?? []),
          correctAnswer: dataMap?['correctAnswer'] ?? 0,
          explanation: dataMap?['explanation'] ?? '',
          subject: dataMap?['subject'] ?? subject,
          difficulty: dataMap?['difficulty'] as String?,
          topic: dataMap?['topic'] as String?,
        );
      }).toList();
    } catch (e) {
      // Error getting questions for subject
      return [];
    }
  }

  // Get questions by difficulty level
  static Future<List<TestQuestion>> getQuestionsByDifficulty(
    String subject,
    String difficulty,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('cbt_questions')
          .doc(subject.toLowerCase())
          .collection('questions')
          .where('isActive', isEqualTo: true)
          .where('isVerified', isEqualTo: true)
          .where('difficulty', isEqualTo: difficulty)
          .orderBy('questionNumber')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        final dataMap = data as Map<String, dynamic>?;
        return TestQuestion(
          id: dataMap?['id'] ?? doc.id,
          question: dataMap?['question'] ?? '',
          options: List<String>.from(dataMap?['options'] ?? []),
          correctAnswer: dataMap?['correctAnswer'] ?? 0,
          explanation: dataMap?['explanation'] ?? '',
          subject: dataMap?['subject'] ?? subject,
          difficulty: dataMap?['difficulty'],
          topic: dataMap?['topic'],
        );
      }).toList();
    } catch (e) {
      // Error getting questions by difficulty
      return [];
    }
  }

  // Get random questions for CBT test
  static Future<List<TestQuestion>> getRandomQuestionsForCbt({
    required String subject,
    required int count,
    String? difficulty,
  }) async {
    try {
      Query query = _firestore
          .collection('cbt_questions')
          .doc(subject.toLowerCase())
          .collection('questions')
          .where('isActive', isEqualTo: true)
          .where('isVerified', isEqualTo: true);

      if (difficulty != null) {
        query = query.where('difficulty', isEqualTo: difficulty);
      }

      final snapshot = await query.get();
      final allQuestions = snapshot.docs.map((doc) {
        final data = doc.data();
        final dataMap = data as Map<String, dynamic>?;
        return TestQuestion(
          id: dataMap?['id'] ?? doc.id,
          question: dataMap?['question'] ?? '',
          options: List<String>.from(dataMap?['options'] ?? []),
          correctAnswer: dataMap?['correctAnswer'] ?? 0,
          explanation: dataMap?['explanation'] ?? '',
          subject: dataMap?['subject'] ?? subject,
          difficulty: dataMap?['difficulty'],
          topic: dataMap?['topic'],
        );
      }).toList();

      // Shuffle and take required number
      allQuestions.shuffle();
      return allQuestions.take(count).toList();
    } catch (e) {
      // Error getting random questions
      return [];
    }
  }

  // Get CBT test configuration
  static Future<Map<String, dynamic>> getCbtTestConfig(String testType) async {
    try {
      final doc = await _firestore
          .collection('cbt_configs')
          .doc(testType)
          .get();

      if (doc.exists) {
        return Map<String, dynamic>.from(doc.data() ?? {});
      }

      // Default configurations
      final defaultConfigs = {
        'full_cbt': {
          'title': 'Full CBT Mock Test',
          'description': 'Complete UTME simulation with all subjects',
          'duration': 120, // 2 hours
          'questions': 180,
          'subjects': [
            'English',
            'Mathematics',
            'Physics',
            'Chemistry',
            'Biology',
          ],
          'questionsPerSubject': 36,
        },
        'science_cbt': {
          'title': 'Science CBT Test',
          'description': 'Physics, Chemistry, and Biology CBT simulation',
          'duration': 60, // 1 hour
          'questions': 60,
          'subjects': ['Physics', 'Chemistry', 'Biology'],
          'questionsPerSubject': 20,
        },
        'mathematics_cbt': {
          'title': 'Mathematics CBT Test',
          'description': 'Mathematics CBT simulation',
          'duration': 40, // 40 minutes
          'questions': 40,
          'subjects': ['Mathematics'],
          'questionsPerSubject': 40,
        },
        'english_cbt': {
          'title': 'English CBT Test',
          'description': 'English language CBT simulation',
          'duration': 40, // 40 minutes
          'questions': 40,
          'subjects': ['English'],
          'questionsPerSubject': 40,
        },
      };

      return Map<String, dynamic>.from(
        defaultConfigs[testType] ?? defaultConfigs['full_cbt']!,
      );
    } catch (e) {
      // Error getting CBT test config
      return {};
    }
  }

  // ===== ADMIN FUNCTIONS =====

  // Verify questions (Admin only)
  static Future<void> verifyQuestions(
    String subject,
    List<String> questionIds,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userRole = userDoc.data()?['role'] ?? 'user';

      if (userRole != 'admin') {
        throw Exception('Only admins can verify questions');
      }

      final batch = _firestore.batch();

      for (final questionId in questionIds) {
        final questionRef = _firestore
            .collection('cbt_questions')
            .doc(subject.toLowerCase())
            .collection('questions')
            .doc(questionId);

        batch.update(questionRef, {'isVerified': true});
      }

      await batch.commit();
      // Successfully verified questions for subject
    } catch (e) {
      // Error verifying questions
      rethrow;
    }
  }

  // Delete questions (Admin only)
  static Future<void> deleteQuestions(
    String subject,
    List<String> questionIds,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userRole = userDoc.data()?['role'] ?? 'user';

      if (userRole != 'admin') {
        throw Exception('Only admins can delete questions');
      }

      final batch = _firestore.batch();

      for (final questionId in questionIds) {
        final questionRef = _firestore
            .collection('cbt_questions')
            .doc(subject.toLowerCase())
            .collection('questions')
            .doc(questionId);

        batch.delete(questionRef);
      }

      await batch.commit();
      // Successfully deleted questions for subject
    } catch (e) {
      // Error deleting questions
      rethrow;
    }
  }

  // Get question statistics
  static Future<Map<String, dynamic>> getQuestionStats() async {
    try {
      final subjects = await getAvailableSubjects();
      final stats = <String, dynamic>{};

      for (final subject in subjects) {
        final snapshot = await _firestore
            .collection('cbt_questions')
            .doc(subject.toLowerCase())
            .collection('questions')
            .get();

        final totalQuestions = snapshot.docs.length;
        final verifiedQuestions = snapshot.docs
            .where((doc) => doc.data()['isVerified'] == true)
            .length;
        final activeQuestions = snapshot.docs
            .where((doc) => doc.data()['isActive'] == true)
            .length;

        stats[subject] = {
          'total': totalQuestions,
          'verified': verifiedQuestions,
          'active': activeQuestions,
          'pending': totalQuestions - verifiedQuestions,
        };
      }

      return stats;
    } catch (e) {
      // Error getting question stats
      return {};
    }
  }
}
