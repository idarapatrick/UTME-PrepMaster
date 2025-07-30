import 'dart:io';
import 'dart:convert';
import '../../domain/models/test_question.dart';

class PdfTextExtractionService {
  // Extract text from PDF file - simplified approach
  static Future<String> extractTextFromPdf(File pdfFile) async {
    try {
      // For now, return a placeholder since PDF text extraction is complex
      // In a real implementation, you would use a proper PDF parsing library
      return 'PDF text extraction not implemented yet. Please use sample questions for testing.';
    } catch (e) {
      print('Error extracting text from PDF: $e');
      rethrow;
    }
  }

  // Parse questions from extracted text
  static List<TestQuestion> parseQuestionsFromText(String text, String subject) {
    final questions = <TestQuestion>[];
    final lines = text.split('\n');
    
    String currentQuestion = '';
    List<String> currentOptions = [];
    int correctAnswer = 0;
    String explanation = '';
    String currentTopic = '';
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      
      if (line.isEmpty) continue;
      
      // Detect question pattern (starts with number)
      if (RegExp(r'^\d+\.').hasMatch(line)) {
        // Save previous question if exists
        if (currentQuestion.isNotEmpty && currentOptions.isNotEmpty) {
          questions.add(TestQuestion(
            id: 'q${questions.length + 1}',
            question: currentQuestion,
            options: currentOptions,
            correctAnswer: correctAnswer,
            explanation: explanation,
            subject: subject,
            topic: currentTopic,
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
        
        // Check for correct answer indicators
        if (line.contains('*') || line.contains('✓') || line.contains('(correct)')) {
          correctAnswer = currentOptions.length - 1;
        }
      }
      // Detect explanation
      else if (line.toLowerCase().contains('explanation') || 
               line.toLowerCase().contains('answer') ||
               line.toLowerCase().contains('solution')) {
        explanation = line;
      }
      // Detect topic headers
      else if (line.toUpperCase() == line && line.length > 3 && line.length < 50) {
        currentTopic = line;
      }
      // If line doesn't match any pattern, it might be part of the question
      else if (currentQuestion.isNotEmpty && currentOptions.isEmpty) {
        currentQuestion += ' ' + line;
      }
    }
    
    // Add the last question
    if (currentQuestion.isNotEmpty && currentOptions.isNotEmpty) {
      questions.add(TestQuestion(
        id: 'q${questions.length + 1}',
        question: currentQuestion,
        options: currentOptions,
        correctAnswer: correctAnswer,
        explanation: explanation,
        subject: subject,
        topic: currentTopic,
      ));
    }
    
    return questions;
  }

  // Enhanced parsing for different question formats
  static List<TestQuestion> parseQuestionsEnhanced(String text, String subject) {
    final questions = <TestQuestion>[];
    final sections = text.split(RegExp(r'\n\s*\n')); // Split by double newlines
    
    for (final section in sections) {
      final lines = section.split('\n');
      if (lines.length < 3) continue; // Skip sections with too few lines
      
      String question = '';
      List<String> options = [];
      int correctAnswer = 0;
      String explanation = '';
      
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;
        
        // Check if this is a question line
        if (RegExp(r'^\d+\.').hasMatch(line)) {
          question = line.replaceFirst(RegExp(r'^\d+\.\s*'), '');
        }
        // Check if this is an option line
        else if (RegExp(r'^[A-D]\)').hasMatch(line)) {
          final option = line.replaceFirst(RegExp(r'^[A-D]\)\s*'), '');
          options.add(option);
          
          // Check for correct answer
          if (line.contains('*') || line.contains('✓')) {
            correctAnswer = options.length - 1;
          }
        }
        // Check for explanation
        else if (line.toLowerCase().contains('explanation') || 
                 line.toLowerCase().contains('answer')) {
          explanation = line;
        }
        // If it's not an option or explanation, it might be part of the question
        else if (question.isNotEmpty && options.isEmpty) {
          question += ' ' + line;
        }
      }
      
      // Only add if we have a valid question with options
      if (question.isNotEmpty && options.length >= 2) {
        questions.add(TestQuestion(
          id: 'q${questions.length + 1}',
          question: question,
          options: options,
          correctAnswer: correctAnswer,
          explanation: explanation,
          subject: subject,
        ));
      }
    }
    
    return questions;
  }

  // Validate parsed questions
  static List<TestQuestion> validateQuestions(List<TestQuestion> questions) {
    return questions.where((question) {
      // Check if question has valid structure
      return question.question.isNotEmpty &&
             question.options.length >= 2 &&
             question.correctAnswer >= 0 &&
             question.correctAnswer < question.options.length;
    }).toList();
  }

  // Generate sample questions for testing
  static List<TestQuestion> generateSampleQuestions(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
        return [
          TestQuestion(
            id: 'math_1',
            question: 'What is the value of 2² × 3³?',
            options: ['A) 72', 'B) 108', 'C) 216', 'D) 432'],
            correctAnswer: 1,
            explanation: '2² = 4, 3³ = 27, so 4 × 27 = 108',
            subject: subject,
            topic: 'Algebra',
            difficulty: 'medium',
          ),
          TestQuestion(
            id: 'math_2',
            question: 'Solve for x: 3x + 7 = 22',
            options: ['A) 3', 'B) 5', 'C) 7', 'D) 9'],
            correctAnswer: 1,
            explanation: '3x + 7 = 22 → 3x = 15 → x = 5',
            subject: subject,
            topic: 'Linear Equations',
            difficulty: 'easy',
          ),
        ];
      
      case 'physics':
        return [
          TestQuestion(
            id: 'physics_1',
            question: 'What is the SI unit of force?',
            options: ['A) Joule', 'B) Newton', 'C) Watt', 'D) Pascal'],
            correctAnswer: 1,
            explanation: 'The SI unit of force is the Newton (N)',
            subject: subject,
            topic: 'Mechanics',
            difficulty: 'easy',
          ),
          TestQuestion(
            id: 'physics_2',
            question: 'Which of the following is a vector quantity?',
            options: ['A) Mass', 'B) Time', 'C) Velocity', 'D) Temperature'],
            correctAnswer: 2,
            explanation: 'Velocity has both magnitude and direction, making it a vector quantity',
            subject: subject,
            topic: 'Vectors',
            difficulty: 'medium',
          ),
        ];
      
      case 'chemistry':
        return [
          TestQuestion(
            id: 'chemistry_1',
            question: 'What is the chemical symbol for gold?',
            options: ['A) Ag', 'B) Au', 'C) Fe', 'D) Cu'],
            correctAnswer: 1,
            explanation: 'Au is the chemical symbol for gold (from Latin "aurum")',
            subject: subject,
            topic: 'Elements',
            difficulty: 'easy',
          ),
          TestQuestion(
            id: 'chemistry_2',
            question: 'What is the atomic number of carbon?',
            options: ['A) 4', 'B) 6', 'C) 8', 'D) 12'],
            correctAnswer: 1,
            explanation: 'Carbon has an atomic number of 6',
            subject: subject,
            topic: 'Atomic Structure',
            difficulty: 'easy',
          ),
        ];
      
      case 'biology':
        return [
          TestQuestion(
            id: 'biology_1',
            question: 'What is the powerhouse of the cell?',
            options: ['A) Nucleus', 'B) Mitochondria', 'C) Golgi apparatus', 'D) Endoplasmic reticulum'],
            correctAnswer: 1,
            explanation: 'Mitochondria is known as the powerhouse of the cell because it produces energy through cellular respiration',
            subject: subject,
            topic: 'Cell Biology',
            difficulty: 'easy',
          ),
          TestQuestion(
            id: 'biology_2',
            question: 'Which of the following is a function of the cell membrane?',
            options: [
              'A) Protein synthesis',
              'B) Selective permeability',
              'C) Energy production',
              'D) DNA replication'
            ],
            correctAnswer: 1,
            explanation: 'The cell membrane controls what enters and exits the cell, making it selectively permeable',
            subject: subject,
            topic: 'Cell Biology',
            difficulty: 'medium',
          ),
        ];
      
      case 'english':
        return [
          TestQuestion(
            id: 'english_1',
            question: 'Choose the correct form: "She _____ to the store yesterday."',
            options: ['A) go', 'B) goes', 'C) went', 'D) going'],
            correctAnswer: 2,
            explanation: 'The past tense of "go" is "went"',
            subject: subject,
            topic: 'Grammar',
            difficulty: 'easy',
          ),
          TestQuestion(
            id: 'english_2',
            question: 'Which sentence is grammatically correct?',
            options: [
              'A) Me and him went to the store',
              'B) He and I went to the store',
              'C) Him and I went to the store',
              'D) Me and he went to the store'
            ],
            correctAnswer: 1,
            explanation: 'When using multiple subjects, use subject pronouns: "He and I"',
            subject: subject,
            topic: 'Grammar',
            difficulty: 'medium',
          ),
        ];
      
      default:
        return [
          TestQuestion(
            id: 'generic_1',
            question: 'Sample question for $subject?',
            options: ['A) Option 1', 'B) Option 2', 'C) Option 3', 'D) Option 4'],
            correctAnswer: 0,
            explanation: 'This is a sample question',
            subject: subject,
            topic: 'General',
            difficulty: 'easy',
          ),
        ];
    }
  }
} 