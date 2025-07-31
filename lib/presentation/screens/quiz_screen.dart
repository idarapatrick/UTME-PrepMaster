import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../data/services/firestore_service.dart';
import '../../data/services/cbt_question_service.dart';
import '../theme/app_colors.dart';
import '../providers/user_stats_provider.dart';
import '../../domain/models/test_question.dart';
import '../utils/responsive_helper.dart';

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
  bool _paused = false;
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
      print('Error loading questions from Firebase: $e');
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
      correctAnswer: q.correctAnswer,
      explanation: q.explanation,
    )).toList();
  }

  List<_QuizQuestion> _getQuestionsForSubject(String subject, String quizType) {
    final questions = <_QuizQuestion>[];
    
    switch (subject) {
      case 'Mathematics':
        questions.addAll(_getMathQuestions(quizType));
        break;
      case 'Physics':
        questions.addAll(_getPhysicsQuestions(quizType));
        break;
      case 'Chemistry':
        questions.addAll(_getChemistryQuestions(quizType));
        break;
      case 'Biology':
        questions.addAll(_getBiologyQuestions(quizType));
        break;
      case 'English':
        questions.addAll(_getEnglishQuestions(quizType));
        break;
      default:
        // Generic questions for other subjects
        for (int i = 0; i < 10; i++) {
          questions.add(_QuizQuestion(
            id: '${subject}_$i',
            question: 'Sample $subject Quiz Question ${i + 1}',
            options: ['A', 'B', 'C', 'D'],
            correctAnswer: i % 4,
            explanation: 'Explanation for $subject Q${i + 1}',
          ));
        }
    }
    
    return questions;
  }

  List<_QuizQuestion> _getMathQuestions(String quizType) {
    final questions = <_QuizQuestion>[];
    
    if (quizType == 'basic') {
      questions.addAll([
        _QuizQuestion(
          id: 'math_basic_1',
          question: 'What is the value of 2² × 3³?',
          options: ['A) 72', 'B) 108', 'C) 216', 'D) 432'],
          correctAnswer: 1,
          explanation: '2² = 4, 3³ = 27, so 4 × 27 = 108',
        ),
        _QuizQuestion(
          id: 'math_basic_2',
          question: 'Solve for x: 3x + 7 = 22',
          options: ['A) 3', 'B) 5', 'C) 7', 'D) 9'],
          correctAnswer: 1,
          explanation: '3x + 7 = 22 → 3x = 15 → x = 5',
        ),
        // Add more basic math questions...
      ]);
    } else if (quizType == 'problem_solving') {
      questions.addAll([
        _QuizQuestion(
          id: 'math_problem_1',
          question: 'A train travels 120 km in 2 hours. What is its speed in km/h?',
          options: ['A) 40 km/h', 'B) 60 km/h', 'C) 80 km/h', 'D) 120 km/h'],
          correctAnswer: 1,
          explanation: 'Speed = Distance ÷ Time = 120 ÷ 2 = 60 km/h',
        ),
        // Add more problem-solving questions...
      ]);
    }
    
    return questions;
  }

  List<_QuizQuestion> _getPhysicsQuestions(String quizType) {
    final questions = <_QuizQuestion>[];
    
    if (quizType == 'basic') {
      questions.addAll([
        _QuizQuestion(
          id: 'physics_basic_1',
          question: 'What is the SI unit of force?',
          options: ['A) Joule', 'B) Newton', 'C) Watt', 'D) Pascal'],
          correctAnswer: 1,
          explanation: 'The SI unit of force is the Newton (N)',
        ),
        _QuizQuestion(
          id: 'physics_basic_2',
          question: 'Which of the following is a vector quantity?',
          options: ['A) Mass', 'B) Time', 'C) Velocity', 'D) Temperature'],
          correctAnswer: 2,
          explanation: 'Velocity has both magnitude and direction, making it a vector quantity',
        ),
      ]);
    } else if (quizType == 'theory') {
      questions.addAll([
        _QuizQuestion(
          id: 'physics_theory_1',
          question: 'According to Newton\'s First Law, an object will:',
          options: [
            'A) Always accelerate',
            'B) Stay at rest or in uniform motion unless acted upon by a force',
            'C) Always move in a circle',
            'D) Always fall to the ground'
          ],
          correctAnswer: 1,
          explanation: 'Newton\'s First Law states that objects remain at rest or in uniform motion unless acted upon by an external force',
        ),
      ]);
    }
    
    return questions;
  }

  List<_QuizQuestion> _getChemistryQuestions(String quizType) {
    final questions = <_QuizQuestion>[];
    
    if (quizType == 'basic') {
      questions.addAll([
        _QuizQuestion(
          id: 'chemistry_basic_1',
          question: 'What is the chemical symbol for gold?',
          options: ['A) Ag', 'B) Au', 'C) Fe', 'D) Cu'],
          correctAnswer: 1,
          explanation: 'Au is the chemical symbol for gold (from Latin "aurum")',
        ),
        _QuizQuestion(
          id: 'chemistry_basic_2',
          question: 'What is the atomic number of carbon?',
          options: ['A) 4', 'B) 6', 'C) 8', 'D) 12'],
          correctAnswer: 1,
          explanation: 'Carbon has an atomic number of 6',
        ),
      ]);
    }
    
    return questions;
  }

  List<_QuizQuestion> _getBiologyQuestions(String quizType) {
    final questions = <_QuizQuestion>[];
    
    if (quizType == 'basic') {
      questions.addAll([
        _QuizQuestion(
          id: 'biology_basic_1',
          question: 'What is the powerhouse of the cell?',
          options: ['A) Nucleus', 'B) Mitochondria', 'C) Golgi apparatus', 'D) Endoplasmic reticulum'],
          correctAnswer: 1,
          explanation: 'Mitochondria is known as the powerhouse of the cell because it produces energy through cellular respiration',
        ),
        _QuizQuestion(
          id: 'biology_basic_2',
          question: 'Which of the following is a function of the cell membrane?',
          options: [
            'A) Protein synthesis',
            'B) Selective permeability',
            'C) Energy production',
            'D) DNA replication'
          ],
          correctAnswer: 1,
          explanation: 'The cell membrane controls what enters and exits the cell, making it selectively permeable',
        ),
      ]);
    }
    
    return questions;
  }

  List<_QuizQuestion> _getEnglishQuestions(String quizType) {
    final questions = <_QuizQuestion>[];
    
    if (quizType == 'grammar') {
      questions.addAll([
        _QuizQuestion(
          id: 'english_grammar_1',
          question: 'Choose the correct form: "She _____ to the store yesterday."',
          options: ['A) go', 'B) goes', 'C) went', 'D) going'],
          correctAnswer: 2,
          explanation: 'The past tense of "go" is "went"',
        ),
        _QuizQuestion(
          id: 'english_grammar_2',
          question: 'Which sentence is grammatically correct?',
          options: [
            'A) Me and him went to the store',
            'B) He and I went to the store',
            'C) Him and I went to the store',
            'D) Me and he went to the store'
          ],
          correctAnswer: 1,
          explanation: 'When using multiple subjects, use subject pronouns: "He and I"',
        ),
      ]);
    } else if (quizType == 'comprehension') {
      questions.addAll([
        _QuizQuestion(
          id: 'english_comprehension_1',
          question: 'Read the passage and answer: "The quick brown fox jumps over the lazy dog." What does the fox do?',
          options: [
            'A) Runs away',
            'B) Jumps over the dog',
            'C) Sleeps',
            'D) Eats'
          ],
          correctAnswer: 1,
          explanation: 'The passage states that the fox "jumps over the lazy dog"',
        ),
      ]);
    }
    
    return questions;
  }

  void _startTimer() async {
    while (!_finished && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (!_paused && mounted) {
        setState(() => _timeElapsed++);
      }
    }
  }

  void _selectAnswer(String answer) {
    setState(() {
      _selectedAnswers[_currentQuestionIndex] = answer;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() => _currentQuestionIndex++);
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() => _currentQuestionIndex--);
    }
  }

  int _calculateCorrectAnswers() {
    int correctCount = 0;
    for (int i = 0; i < _questions.length; i++) {
      final selectedAnswer = _selectedAnswers[i];
      if (selectedAnswer.isNotEmpty) {
        final selectedIndex = _questions[i].options.indexOf(selectedAnswer);
        if (selectedIndex == _questions[i].correctAnswer) {
          correctCount++;
        }
      }
    }
    return correctCount;
  }

  // Save quiz progress to local storage
  Future<void> _saveQuizProgress(String subject, int correct, int total) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final quizData = {
        'subject': subject,
        'correct': correct,
        'total': total,
        'score': (correct / total * 100).round(),
        'timestamp': DateTime.now().toIso8601String(),
      };

      final key = 'quiz_progress_${user.uid}_$subject';
      await prefs.setString(key, jsonEncode(quizData));
      print('Quiz progress saved to local storage');
    } catch (e) {
      print('Error saving quiz progress: $e');
    }
  }

  // Show completion dialog
  void _showCompletionDialog(int correct, int total, double score) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              correct >= total * 0.8 ? Icons.celebration : Icons.emoji_events,
              color: correct >= total * 0.8 ? Colors.amber : AppColors.dominantPurple,
            ),
            const SizedBox(width: 8),
            Text('Quiz Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You got $correct out of $total questions correct!',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Score: ${score.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.dominantPurple,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to previous screen
            },
            child: Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _pauseQuiz() {
    setState(() => _paused = true);
  }

  void _resumeQuiz() {
    setState(() => _paused = false);
  }

  void _submitQuiz() async {
    setState(() => _finished = true);
    int correct = 0;
    int attempted = 0;
    for (int i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      final selected = _selectedAnswers[i];
      if (selected.isNotEmpty) attempted++;
      if (selected == q.options[q.correctAnswer]) correct++;
    }
    double score = widget.subject == 'English' ? correct * 1.67 : correct * 2.5;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Save to Firestore service (existing functionality)
      await FirestoreService.saveQuizResult(
        user.uid,
        widget.subject,
        score.toInt(),
        attempted,
        Duration(seconds: _timeElapsed),
      );
      
      // Update real-time stats using UserStatsProvider
      final userStatsProvider = Provider.of<UserStatsProvider>(context, listen: false);
      await userStatsProvider.completeQuiz(
        subjectId: widget.subject,
        totalQuestions: _questions.length,
        correctAnswers: correct,
        timeSpentMinutes: _timeElapsed ~/ 60,
      );
      
      // Save quiz progress to local storage as backup
      await _saveQuizProgress(widget.subject, correct, _questions.length);
      
              final prev = await FirestoreService.loadSubjectProgress(
          user.uid,
          widget.subject,
        );
        
        // Show completion dialog with results
        if (mounted) {
          _showCompletionDialog(correct, _questions.length, score);
        }
      double bestScore = prev != null && prev['bestScore'] != null
          ? prev['bestScore']
          : 0;
      if (score > bestScore) {
        await FirestoreService.saveSubjectProgress(
          user.uid,
          {widget.subject: score},
        );
      }
    }
    _showResultsDialog(correct, attempted, score);
  }

  void _showResultsDialog(int correct, int attempted, double score) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              score >= 7 * (widget.subject == 'English' ? 1.67 : 2.5)
                  ? Icons.emoji_events
                  : Icons.school,
              color: AppColors.accentAmber,
            ),
            const SizedBox(width: 8),
            const Text('Quiz Results'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Score: ${score.toStringAsFixed(2)}'),
            Text('Correct: $correct / $attempted'),
            Text('Time: ${_formatTime(_timeElapsed)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? const Color(0xFF181A20)
        : AppColors.backgroundPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          '${widget.subject} Quiz',
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
          ),
        ),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _finished
              ? _buildResultsScreen(context, isDark)
              : ResponsiveHelper.responsiveSingleChildScrollView(
                  context: context,
                  child: Padding(
                    padding: ResponsiveHelper.getResponsiveEdgeInsets(context),
                    child: Column(
                      children: [
                        // Timer and Progress
                        _buildTimerAndProgress(context, isDark),
                        
                        SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
                        
                        // Question
                        _buildQuestionSection(context, isDark),
                        
                        SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
                        
                        // Options
                        _buildOptionsSection(context, isDark),
                        
                        SizedBox(height: ResponsiveHelper.getResponsivePadding(context) * 2),
                        
                        // Navigation Buttons
                        _buildNavigationButtons(context, isDark),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildTimerAndProgress(BuildContext context, bool isDark) {
    return ResponsiveHelper.responsiveCard(
      context: context,
      color: isDark ? const Color(0xFF23243B) : Colors.white,
      child: Column(
        children: [
          // Timer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                Icons.timer,
                color: AppColors.dominantPurple,
                size: ResponsiveHelper.getResponsiveIconSize(context, 20),
              ),
              Text(
                '${(_timeElapsed ~/ 60).toString().padLeft(2, '0')}:${(_timeElapsed % 60).toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() => _paused = !_paused);
                },
                icon: Icon(
                  _paused ? Icons.play_arrow : Icons.pause,
                  color: AppColors.dominantPurple,
                  size: ResponsiveHelper.getResponsiveIconSize(context, 20),
                ),
              ),
            ],
          ),
          
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context) / 2),
          
          // Progress
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _questions.length,
            backgroundColor: AppColors.textTertiary,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.dominantPurple),
          ),
          
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context) / 2),
          
          Text(
            'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionSection(BuildContext context, bool isDark) {
    final currentQuestion = _questions[_currentQuestionIndex];
    
    return ResponsiveHelper.responsiveCard(
      context: context,
      color: isDark ? const Color(0xFF23243B) : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question ${_currentQuestionIndex + 1}',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
          
          Text(
            currentQuestion.question,
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
              color: isDark ? Colors.white : AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsSection(BuildContext context, bool isDark) {
    final currentQuestion = _questions[_currentQuestionIndex];
    final options = ['A', 'B', 'C', 'D'];
    
    return ResponsiveHelper.responsiveCard(
      context: context,
      color: isDark ? const Color(0xFF23243B) : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select your answer:',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
          
          ...options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = _selectedAnswers[_currentQuestionIndex] == option;
            
            return Padding(
              padding: EdgeInsets.only(bottom: ResponsiveHelper.getResponsivePadding(context)),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedAnswers[_currentQuestionIndex] = option;
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context)),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.dominantPurple.withValues(alpha: 0.1)
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected 
                          ? AppColors.dominantPurple
                          : AppColors.textTertiary,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: ResponsiveHelper.getResponsiveIconSize(context, 24),
                        height: ResponsiveHelper.getResponsiveIconSize(context, 24),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? AppColors.dominantPurple
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected 
                                ? AppColors.dominantPurple
                                : AppColors.textTertiary,
                            width: 2,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                color: Colors.white,
                                size: ResponsiveHelper.getResponsiveIconSize(context, 16),
                              )
                            : null,
                      ),
                      
                      SizedBox(width: ResponsiveHelper.getResponsivePadding(context)),
                      
                      Text(
                        '$option.',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                          fontWeight: FontWeight.bold,
                          color: isSelected 
                              ? AppColors.dominantPurple
                              : isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      
                      SizedBox(width: ResponsiveHelper.getResponsivePadding(context)),
                      
                      Expanded(
                        child: Text(
                          currentQuestion.options[index],
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                            color: isSelected 
                                ? AppColors.dominantPurple
                                : isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context, bool isDark) {
    return Row(
      children: [
        // Previous Button
        Expanded(
          child: ResponsiveHelper.responsiveButton(
            context: context,
            text: 'Previous',
            onPressed: _currentQuestionIndex > 0
                ? () {
                    setState(() {
                      _currentQuestionIndex--;
                    });
                  }
                : null,
            backgroundColor: _currentQuestionIndex > 0
                ? AppColors.dominantPurple
                : AppColors.textTertiary,
            foregroundColor: Colors.white,
          ),
        ),
        
        SizedBox(width: ResponsiveHelper.getResponsivePadding(context)),
        
        // Next/Finish Button
        Expanded(
          child: ResponsiveHelper.responsiveButton(
            context: context,
            text: _currentQuestionIndex < _questions.length - 1 ? 'Next' : 'Finish',
            onPressed: () {
              if (_currentQuestionIndex < _questions.length - 1) {
                setState(() {
                  _currentQuestionIndex++;
                });
              } else {
                _submitQuiz();
              }
            },
            backgroundColor: AppColors.dominantPurple,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildResultsScreen(BuildContext context, bool isDark) {
    final correctAnswers = _calculateCorrectAnswers();
    final score = (correctAnswers / _questions.length * 100).round();
    
    return ResponsiveHelper.responsiveSingleChildScrollView(
      context: context,
      child: Padding(
        padding: ResponsiveHelper.getResponsiveEdgeInsets(context),
        child: Column(
          children: [
            // Results Header
            ResponsiveHelper.responsiveCard(
              context: context,
              color: isDark ? const Color(0xFF23243B) : Colors.white,
              child: Column(
                children: [
                  Icon(
                    score >= 70 ? Icons.celebration : Icons.school,
                    size: ResponsiveHelper.getResponsiveIconSize(context, 60),
                    color: score >= 70 ? AppColors.accentAmber : AppColors.dominantPurple,
                  ),
                  
                  SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
                  
                  Text(
                    score >= 70 ? 'Great Job!' : 'Keep Learning!',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 24),
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  
                  SizedBox(height: ResponsiveHelper.getResponsivePadding(context) / 2),
                  
                  Text(
                    'You scored $score%',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
            
            // Stats
            ResponsiveHelper.responsiveGridView(
              context: context,
              children: [
                _buildResultStat(
                  context,
                  'Correct',
                  '$correctAnswers',
                  Icons.check_circle,
                  AppColors.subjectGreen,
                  isDark,
                ),
                _buildResultStat(
                  context,
                  'Incorrect',
                  '${_questions.length - correctAnswers}',
                  Icons.cancel,
                  AppColors.accentAmber,
                  isDark,
                ),
                _buildResultStat(
                  context,
                  'Time',
                  '${(_timeElapsed ~/ 60).toString().padLeft(2, '0')}:${(_timeElapsed % 60).toString().padLeft(2, '0')}',
                  Icons.timer,
                  AppColors.dominantPurple,
                  isDark,
                ),
                _buildResultStat(
                  context,
                  'Score',
                  '$score%',
                  Icons.assessment,
                  AppColors.subjectBlue,
                  isDark,
                ),
              ],
            ),
            
            SizedBox(height: ResponsiveHelper.getResponsivePadding(context) * 2),
            
            // Action Buttons
            ResponsiveHelper.responsiveButton(
              context: context,
              text: 'Review Answers',
              onPressed: () {
                setState(() {
                  _currentQuestionIndex = 0;
                  _finished = false;
                });
              },
              backgroundColor: AppColors.dominantPurple,
              foregroundColor: Colors.white,
            ),
            
            SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
            
            ResponsiveHelper.responsiveButton(
              context: context,
              text: 'Back to Home',
              onPressed: () => Navigator.pop(context),
              backgroundColor: Colors.transparent,
              foregroundColor: AppColors.dominantPurple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultStat(BuildContext context, String label, String value, IconData icon, Color color, bool isDark) {
    return ResponsiveHelper.responsiveCard(
      context: context,
      color: isDark ? const Color(0xFF23243B) : Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: ResponsiveHelper.getResponsiveIconSize(context, 32),
          ),
          
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context) / 2),
          
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;

  _QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });
}
