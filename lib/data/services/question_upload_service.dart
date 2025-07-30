import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/test_question.dart';

class QuestionUploadService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Upload questions for a specific subject
  static Future<void> uploadSubjectQuestions({
    required String subject,
    required List<TestQuestion> questions,
    required String examYear,
    String? description,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

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
          'difficulty': question.difficulty ?? 'medium',
          'topic': question.topic ?? '',
          'uploadedBy': user.uid,
          'uploadedAt': FieldValue.serverTimestamp(),
          'description': description ?? 'CBT Practice Questions',
          'isActive': true,
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
      };

      batch.set(subjectRef, subjectData, SetOptions(merge: true));

      await batch.commit();
      print('Successfully uploaded ${questions.length} questions for $subject');
    } catch (e) {
      print('Error uploading questions: $e');
      rethrow;
    }
  }

  // Upload questions from PDF text (you'll need to parse the PDF first)
  static Future<void> uploadQuestionsFromText({
    required String subject,
    required String pdfText,
    required String examYear,
    String? description,
  }) async {
    try {
      // Parse the PDF text into questions
      final questions = _parseQuestionsFromText(pdfText, subject);
      
      // Upload the parsed questions
      await uploadSubjectQuestions(
        subject: subject,
        questions: questions,
        examYear: examYear,
        description: description,
      );
    } catch (e) {
      print('Error uploading questions from text: $e');
      rethrow;
    }
  }

  // Parse questions from PDF text (basic implementation)
  static List<TestQuestion> _parseQuestionsFromText(String text, String subject) {
    final questions = <TestQuestion>[];
    final lines = text.split('\n');
    
    String currentQuestion = '';
    List<String> currentOptions = [];
    int correctAnswer = 0;
    String explanation = '';
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      
      if (line.isEmpty) continue;
      
      // Detect question pattern (starts with number)
      if (RegExp(r'^\d+\.').hasMatch(line)) {
        // Save previous question if exists
        if (currentQuestion.isNotEmpty) {
          questions.add(TestQuestion(
            id: 'q${questions.length + 1}',
            question: currentQuestion,
            options: currentOptions,
            correctAnswer: correctAnswer,
            explanation: explanation,
            subject: subject,
          ));
        }
        
        // Start new question
        currentQuestion = line.replaceFirst(RegExp(r'^\d+\.\s*'), '');
        currentOptions = [];
        correctAnswer = 0;
        explanation = '';
      }
      // Detect options (A, B, C, D)
      else if (RegExp(r'^[A-D]\)').hasMatch(line)) {
        final option = line.replaceFirst(RegExp(r'^[A-D]\)\s*'), '');
        currentOptions.add(option);
        
        // Assume the correct answer is marked somehow (you'll need to adjust this)
        if (line.contains('*') || line.contains('✓')) {
          correctAnswer = currentOptions.length - 1;
        }
      }
      // Detect explanation
      else if (line.toLowerCase().contains('explanation') || 
               line.toLowerCase().contains('answer')) {
        explanation = line;
      }
    }
    
    // Add the last question
    if (currentQuestion.isNotEmpty) {
      questions.add(TestQuestion(
        id: 'q${questions.length + 1}',
        question: currentQuestion,
        options: currentOptions,
        correctAnswer: correctAnswer,
        explanation: explanation,
        subject: subject,
      ));
    }
    
    return questions;
  }

  // Get all available subjects
  static Future<List<String>> getAvailableSubjects() async {
    try {
      final snapshot = await _firestore.collection('cbt_questions').get();
      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print('Error getting available subjects: $e');
      return [];
    }
  }

  // Get questions for a specific subject
  static Future<List<TestQuestion>> getQuestionsForSubject(String subject) async {
    try {
      final snapshot = await _firestore
          .collection('cbt_questions')
          .doc(subject.toLowerCase())
          .collection('questions')
          .where('isActive', isEqualTo: true)
          .orderBy('questionNumber')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return TestQuestion(
          id: data['id'] ?? doc.id,
          question: data['question'] ?? '',
          options: List<String>.from(data['options'] ?? []),
          correctAnswer: data['correctAnswer'] ?? 0,
          explanation: data['explanation'] ?? '',
          subject: data['subject'] ?? subject,
          difficulty: data['difficulty'],
          topic: data['topic'],
        );
      }).toList();
    } catch (e) {
      print('Error getting questions for $subject: $e');
      return [];
    }
  }

  // Get questions by difficulty
  static Future<List<TestQuestion>> getQuestionsByDifficulty(
    String subject, 
    String difficulty
  ) async {
    try {
      final snapshot = await _firestore
          .collection('cbt_questions')
          .doc(subject.toLowerCase())
          .collection('questions')
          .where('isActive', isEqualTo: true)
          .where('difficulty', isEqualTo: difficulty)
          .orderBy('questionNumber')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return TestQuestion(
          id: data['id'] ?? doc.id,
          question: data['question'] ?? '',
          options: List<String>.from(data['options'] ?? []),
          correctAnswer: data['correctAnswer'] ?? 0,
          explanation: data['explanation'] ?? '',
          subject: data['subject'] ?? subject,
          difficulty: data['difficulty'],
          topic: data['topic'],
        );
      }).toList();
    } catch (e) {
      print('Error getting questions by difficulty: $e');
      return [];
    }
  }

  // Delete questions for a subject
  static Future<void> deleteSubjectQuestions(String subject) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Check if user is admin (you can implement admin check)
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final isAdmin = userDoc.data()?['role'] == 'admin';

      if (!isAdmin) {
        throw Exception('Only admins can delete questions');
      }

      final questionsSnapshot = await _firestore
          .collection('cbt_questions')
          .doc(subject.toLowerCase())
          .collection('questions')
          .get();

      final batch = _firestore.batch();
      
      for (final doc in questionsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete subject document
      batch.delete(_firestore.collection('cbt_questions').doc(subject.toLowerCase()));

      await batch.commit();
      print('Successfully deleted all questions for $subject');
    } catch (e) {
      print('Error deleting questions: $e');
      rethrow;
    }
  }
} 