import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../data/services/firestore_service.dart';
import '../../data/services/cbt_question_service.dart';
import '../theme/app_colors.dart';
import '../providers/user_stats_provider.dart';
import '../../domain/models/test_question.dart';
// Import questions from the correct directory
import '../../data/questions/english.dart';
import '../../data/questions/mathematics.dart';
import '../../data/questions/physics.dart';
import '../../data/questions/chemistry.dart';
import '../../data/questions/biology.dart';
import '../../data/questions/government.dart';
import '../../data/questions/economics.dart';
import '../../data/questions/geography.dart';
import '../../data/questions/commerce.dart';
import '../../data/questions/christian_studies.dart';
import '../../data/questions/islamic_studies.dart';

class QuizScreen extends StatefulWidget {
  final String subject;
  final String quizType;
  const QuizScreen({super.key, required this.subject, required this.quizType});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  final List<String> _selectedAnswers = List.filled(10, '');
  final bool _paused = false;
  int _timeElapsed = 0; // seconds
  late List<_QuizQuestion> _questions;
  bool _loading = true;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _generateQuestions();
    _startTimer();
  }

  void _generateQuestions() async {
    setState(() => _loading = true);
    
    try {
      // Try to get questions from centralized service first
      final firebaseQuestions = await CbtQuestionService.getQuestionsForSubject(widget.subject);
      
      if (firebaseQuestions.isNotEmpty) {
        // Filter by quiz type if needed
        _questions = _filterQuestionsByType(firebaseQuestions, widget.quizType);
      } else {
        // Fallback to local questions if no Firebase questions
        _questions = _getQuestionsForSubject(widget.subject, widget.quizType);
      }
    } catch (e) {
      // Error loading questions from Firebase
      // Fallback to local questions
      _questions = _getQuestionsForSubject(widget.subject, widget.quizType);
    }
    
    setState(() => _loading = false);
  }

  List<_QuizQuestion> _filterQuestionsByType(List<TestQuestion> questions, String quizType) {
    // Convert TestQuestion to _QuizQuestion and filter by type
    return questions.map((q) => _QuizQuestion(
      id: q.id,
      question: q.question,
      options: q.options,
      correctAnswer: q.options[q.correctAnswer],
      explanation: q.explanation,
    )).toList();
  }

  List<_QuizQuestion> _getQuestionsForSubject(String subject, String quizType) {
    final questions = <_QuizQuestion>[];
    List<TestQuestion> allQuestions = [];
    
    switch (subject) {
      case 'Mathematics':
        allQuestions = mathematicsQuestions;
        break;
      case 'Physics':
        allQuestions = physicsQuestions;
        break;
      case 'Chemistry':
        allQuestions = chemistryQuestions;
        break;
      case 'Biology':
        allQuestions = biologyQuestions;
        break;
      case 'English':
        allQuestions = englishQuestions;
        break;
      case 'Government':
        allQuestions = governmentQuestions;
        break;
      case 'Economics':
        allQuestions = economicsQuestions;
        break;
      case 'Geography':
        allQuestions = geographyQuestions;
        break;
      case 'Commerce':
        allQuestions = commerceQuestions;
        break;
      case 'Christian Religious Studies':
        allQuestions = crsQuestions;
        break;
      case 'Islamic Studies':
        allQuestions = islamicStudiesQuestions;
        break;
      default:
        // Generic questions for other subjects
        for (int i = 0; i < 40; i++) {
          allQuestions.add(TestQuestion(
            id: '${subject}_$i',
            question: 'Sample question $i for $subject?',
            options: ['Option A', 'Option B', 'Option C', 'Option D'],
            correctAnswer: i % 4,
            subject: subject,
            explanation: 'This is a sample explanation.',
          ));
        }
    }
    
    // For quizzes, randomly select 10 questions
    if (quizType == 'quiz') {
      final random = Random();
      final shuffledQuestions = List<TestQuestion>.from(allQuestions);
      shuffledQuestions.shuffle(random);
      
      // Take first 10 questions (or all if less than 10)
      final selectedQuestions = shuffledQuestions.take(10).toList();
      questions.addAll(_convertTestQuestionsToQuizQuestions(selectedQuestions));
    } else {
      // For CBT tests, use all questions
      questions.addAll(_convertTestQuestionsToQuizQuestions(allQuestions));
    }
    
    return questions;
  }

  List<_QuizQuestion> _convertTestQuestionsToQuizQuestions(List<TestQuestion> testQuestions) {
    return testQuestions.map((q) => _QuizQuestion(
      id: q.id,
      question: q.question,
      options: q.options,
      correctAnswer: q.options[q.correctAnswer],
      explanation: q.explanation,
    )).toList();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && !_paused && !_finished) {
        setState(() {
          _timeElapsed++;
        });
        _startTimer();
      }
    });
  }

  void _selectAnswer(String answer) {
    if (_finished) return;
    
    setState(() {
      _selectedAnswers[_currentQuestionIndex] = answer;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _finishQuiz();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _finishQuiz() {
    setState(() {
      _finished = true;
    });
    _saveResults();
  }

  void _saveResults() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final correctAnswers = _calculateCorrectAnswers();
      final score = (correctAnswers / _questions.length) * 100;
      
      try {
        await FirestoreService.saveQuizResult(
          user.uid,
          widget.subject,
          score.toInt(),
          _questions.length,
          Duration(seconds: _timeElapsed),
        );
        
        // Update user stats with new XP system
        final userStatsProvider = Provider.of<UserStatsProvider>(context, listen: false);
        await userStatsProvider.completeQuizWithNewSystem(
          subjectId: widget.subject,
          totalQuestions: _questions.length,
          correctAnswers: correctAnswers,
          timeSpentMinutes: _timeElapsed ~/ 60, // Convert seconds to minutes
        );
        
      } catch (e) {
        // Error saving quiz results
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving results: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  int _calculateCorrectAnswers() {
    int correct = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_selectedAnswers[i] == _questions[i].correctAnswer) {
        correct++;
      }
    }
    return correct;
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${widget.subject} Quiz'),
          backgroundColor: AppColors.dominantPurple,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              );
            },
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_finished) {
      return _buildResultsScreen();
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subject} Quiz'),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            );
          },
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                _formatTime(_timeElapsed),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.dominantPurple),
          ),
          
          // Question counter
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dominantPurple,
                  ),
                ),
              ],
            ),
          ),
          
          // Question
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentQuestion.question,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Options
                  ...currentQuestion.options.map((option) {
                    final isSelected = _selectedAnswers[_currentQuestionIndex] == option;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () => _selectAnswer(option),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.dominantPurple : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? AppColors.dominantPurple : Colors.grey[300]!,
                            ),
                          ),
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 16,
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          
          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _currentQuestionIndex > 0 ? _previousQuestion : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Previous'),
                ),
                ElevatedButton(
                  onPressed: _currentQuestionIndex < _questions.length - 1 ? _nextQuestion : _finishQuiz,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dominantPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(_currentQuestionIndex < _questions.length - 1 ? 'Next' : 'Finish'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsScreen() {
    final correctAnswers = _calculateCorrectAnswers();
    final score = (correctAnswers / _questions.length) * 100;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Score display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.dominantPurple,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '${score.toInt()}%',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You got $correctAnswers out of ${_questions.length} questions correct',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Time taken: ${_formatTime(_timeElapsed)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dominantPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Back to Home'),
              ),
            ),
            
            const SizedBox(height: 12),
            
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentQuestionIndex = 0;
                    _selectedAnswers.fillRange(0, _selectedAnswers.length, '');
                    _timeElapsed = 0;
                    _finished = false;
                  });
                  _startTimer();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.dominantPurple,
                  side: const BorderSide(color: AppColors.dominantPurple),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Retake Quiz'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;

  _QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });
}
