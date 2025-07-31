import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../data/services/firestore_service.dart';
import '../../data/services/cbt_question_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/subject_selection_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/test_question.dart';
import '../utils/responsive_helper.dart';

class MockTestScreen extends StatefulWidget {
  const MockTestScreen({super.key});

  @override
  State<MockTestScreen> createState() => _MockTestScreenState();
}

class _MockTestScreenState extends State<MockTestScreen> {
  bool _isTestInProgress = false;
  int _currentQuestionIndex = 0;
  int _timeRemaining = 0; // in seconds
  List<String> _selectedAnswers = [];
  List<bool> _answeredQuestions = [];
  List<String> _userSubjects = [];
  String _currentSubject = '';
  final Map<String, List<int>> _subjectQuestionIndices = {};
  Map<String, int> _subjectAnswered = {};
  List<Map<String, dynamic>> _cbtHistory = [];
  bool _showHistory = false;

  List<MockTest> _availableTests = [];

  @override
  void initState() {
    super.initState();
    _loadUserSubjects();
    _loadCbtTests();
  }

  Future<void> _loadCbtTests() async {
    try {
      final testConfigs = [
        'full_cbt',
        'science_cbt', 
        'mathematics_cbt',
        'english_cbt',
      ];

      final tests = <MockTest>[];

      for (final configType in testConfigs) {
        final config = await CbtQuestionService.getCbtTestConfig(configType);
        
        if (config.isNotEmpty) {
          tests.add(MockTest(
            id: configType,
            title: config['title'] ?? 'CBT Test',
            description: config['description'] ?? 'CBT Practice Test',
            duration: config['duration'] ?? 60,
            questions: config['questions'] ?? 40,
            subjects: List<String>.from(config['subjects'] ?? []),
            difficulty: 'Advanced',
            isCbt: true,
          ));
        }
      }

      setState(() {
        _availableTests = tests;
      });
    } catch (e) {
      print('Error loading CBT tests: $e');
      // Fallback to default tests
      _availableTests = [
        MockTest(
          id: 'full_cbt',
          title: 'Full CBT Mock Test',
          description: 'Complete UTME simulation with all subjects',
          duration: 120,
          questions: 180,
          subjects: ['English', 'Mathematics', 'Physics', 'Chemistry', 'Biology'],
          difficulty: 'Advanced',
          isCbt: true,
        ),
      ];
    }
  }

  MockTest? _currentTest;
  List<TestQuestion> _questions = [];



  Future<void> _loadUserSubjects() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final selected = await FirestoreService.loadUserSubjects(user.uid);
      setState(() {
        _userSubjects = selected;
      });
    }
  }

  void _generateQuestionsForTest(MockTest test) async {
    _questions = [];
    _subjectQuestionIndices.clear();

    try {
      if (test.isCbt) {
        // CBT: Get questions from centralized service
        for (final subject in test.subjects) {
          final questionsPerSubject = subject == 'English' ? 60 : 40;
          final subjectQuestions = await CbtQuestionService.getRandomQuestionsForCbt(
            subject: subject,
            count: questionsPerSubject,
          );
          
          final startIndex = _questions.length;
          _questions.addAll(subjectQuestions);
          _subjectQuestionIndices[subject] = List.generate(
            subjectQuestions.length, 
            (i) => startIndex + i
          );
        }
      } else {
        // Specific subject tests: Get from centralized service
        if (test.title.contains('Science')) {
          // Mix Physics, Chemistry, Biology questions
          final physics = await CbtQuestionService.getRandomQuestionsForCbt(
            subject: 'Physics', 
            count: 7
          );
          final chemistry = await CbtQuestionService.getRandomQuestionsForCbt(
            subject: 'Chemistry', 
            count: 7
          );
          final biology = await CbtQuestionService.getRandomQuestionsForCbt(
            subject: 'Biology', 
            count: 6
          );
          
          _questions = [...physics, ...chemistry, ...biology];
          _subjectQuestionIndices['Physics'] = List.generate(7, (i) => i);
          _subjectQuestionIndices['Chemistry'] = List.generate(7, (i) => i + 7);
          _subjectQuestionIndices['Biology'] = List.generate(6, (i) => i + 14);
        } else {
          // Single subject test
          final subj = test.subjects.first;
          final subjectQuestions = await CbtQuestionService.getRandomQuestionsForCbt(
            subject: subj,
            count: 20,
          );
          _questions = subjectQuestions;
          _subjectQuestionIndices[subj] = List.generate(20, (i) => i);
        }
      }
    } catch (e) {
      print('Error generating questions from Firebase: $e');
      // Fallback to local questions
      _questions = _getLocalQuestionsForSubject(test.subjects.first);
    }
  }

  List<TestQuestion> _getLocalQuestionsForSubject(String subject) {
    // Fallback local questions if Firebase is unavailable
    switch (subject.toLowerCase()) {
      case 'mathematics':
        return _getMathQuestions();
      case 'physics':
        return _getPhysicsQuestions();
      case 'chemistry':
        return _getChemistryQuestions();
      case 'biology':
        return _getBiologyQuestions();
      case 'english':
        return _getEnglishQuestions();
      default:
        return [];
    }
  }

  List<TestQuestion> _getEnglishQuestions() {
    return [
      TestQuestion(
        id: 'eng1',
        question: 'What is the capital of France?',
        options: ['Paris', 'London', 'Berlin', 'Madrid'],
        correctAnswer: 0,
        subject: 'English',
        difficulty: 'Easy',
        explanation: 'Paris is the capital of France.',
      ),
      TestQuestion(
        id: 'eng2',
        question: 'Which word means "to go"?',
        options: ['Voyage', 'Voyager', 'Voyageur', 'Voyager'],
        correctAnswer: 0,
        subject: 'English',
        difficulty: 'Easy',
        explanation: 'Voyage means "to go".',
      ),
      TestQuestion(
        id: 'eng3',
        question: 'What is the plural of "child"?',
        options: ['Children', 'Childs', 'Child', 'Childs'],
        correctAnswer: 0,
        subject: 'English',
        difficulty: 'Easy',
        explanation: 'Children is the plural of "child".',
      ),
      TestQuestion(
        id: 'eng4',
        question: 'Which word means "to be"?',
        options: ['Etre', 'Etre', 'Etre', 'Etre'],
        correctAnswer: 0,
        subject: 'English',
        difficulty: 'Easy',
        explanation: 'Etre means "to be".',
      ),
      TestQuestion(
        id: 'eng5',
        question: 'What is the past tense of "go"?',
        options: ['Went', 'Gone', 'Gone', 'Gone'],
        correctAnswer: 0,
        subject: 'English',
        difficulty: 'Easy',
        explanation: 'Went is the past tense of "go".',
      ),
    ];
  }

  List<TestQuestion> _getMathQuestions() {
    return [
      TestQuestion(
        id: 'math1',
        question: 'What is 2 + 2?',
        options: ['1', '2', '3', '4'],
        correctAnswer: 3,
        subject: 'Mathematics',
        difficulty: 'Easy',
        explanation: '2 + 2 = 4.',
      ),
      TestQuestion(
        id: 'math2',
        question: 'What is 5 x 5?',
        options: ['20', '25', '30', '35'],
        correctAnswer: 1,
        subject: 'Mathematics',
        difficulty: 'Easy',
        explanation: '5 x 5 = 25.',
      ),
      TestQuestion(
        id: 'math3',
        question: 'What is 10 - 3?',
        options: ['5', '6', '7', '8'],
        correctAnswer: 2,
        subject: 'Mathematics',
        difficulty: 'Easy',
        explanation: '10 - 3 = 7.',
      ),
      TestQuestion(
        id: 'math4',
        question: 'What is 10 ÷ 2?',
        options: ['4', '5', '6', '7'],
        correctAnswer: 1,
        subject: 'Mathematics',
        difficulty: 'Easy',
        explanation: '10 ÷ 2 = 5.',
      ),
      TestQuestion(
        id: 'math5',
        question: 'What is 3 x 4?',
        options: ['10', '12', '14', '16'],
        correctAnswer: 1,
        subject: 'Mathematics',
        difficulty: 'Easy',
        explanation: '3 x 4 = 12.',
      ),
    ];
  }

  List<TestQuestion> _getPhysicsQuestions() {
    return [
      TestQuestion(
        id: 'phy1',
        question: 'What is the SI unit of force?',
        options: ['Newton', 'Joule', 'Watt', 'Pascal'],
        correctAnswer: 0,
        subject: 'Physics',
        difficulty: 'Easy',
        explanation: 'Newton is the SI unit of force.',
      ),
      TestQuestion(
        id: 'phy2',
        question: 'What is the SI unit of energy?',
        options: ['Joule', 'Watt', 'Newton', 'Pascal'],
        correctAnswer: 0,
        subject: 'Physics',
        difficulty: 'Easy',
        explanation: 'Joule is the SI unit of energy.',
      ),
      TestQuestion(
        id: 'phy3',
        question: 'What is the SI unit of power?',
        options: ['Watt', 'Newton', 'Joule', 'Pascal'],
        correctAnswer: 0,
        subject: 'Physics',
        difficulty: 'Easy',
        explanation: 'Watt is the SI unit of power.',
      ),
      TestQuestion(
        id: 'phy4',
        question: 'What is the SI unit of pressure?',
        options: ['Pascal', 'Watt', 'Newton', 'Joule'],
        correctAnswer: 0,
        subject: 'Physics',
        difficulty: 'Easy',
        explanation: 'Pascal is the SI unit of pressure.',
      ),
      TestQuestion(
        id: 'phy5',
        question: 'What is the SI unit of work?',
        options: ['Joule', 'Watt', 'Newton', 'Pascal'],
        correctAnswer: 0,
        subject: 'Physics',
        difficulty: 'Easy',
        explanation: 'Joule is the SI unit of work.',
      ),
    ];
  }

  List<TestQuestion> _getChemistryQuestions() {
    return [
      TestQuestion(
        id: 'chem1',
        question: 'What is the chemical symbol for water?',
        options: ['H2O', 'CO2', 'O2', 'H2'],
        correctAnswer: 0,
        subject: 'Chemistry',
        difficulty: 'Easy',
        explanation: 'H2O is the chemical symbol for water.',
      ),
      TestQuestion(
        id: 'chem2',
        question: 'What is the chemical formula for sodium chloride?',
        options: ['NaCl', 'H2O', 'CO2', 'O2'],
        correctAnswer: 0,
        subject: 'Chemistry',
        difficulty: 'Easy',
        explanation: 'NaCl is the chemical formula for sodium chloride.',
      ),
      TestQuestion(
        id: 'chem3',
        question: 'What is the chemical formula for carbon dioxide?',
        options: ['CO2', 'H2O', 'O2', 'H2'],
        correctAnswer: 0,
        subject: 'Chemistry',
        difficulty: 'Easy',
        explanation: 'CO2 is the chemical formula for carbon dioxide.',
      ),
      TestQuestion(
        id: 'chem4',
        question: 'What is the chemical formula for oxygen?',
        options: ['O2', 'H2O', 'CO2', 'H2'],
        correctAnswer: 0,
        subject: 'Chemistry',
        difficulty: 'Easy',
        explanation: 'O2 is the chemical formula for oxygen.',
      ),
      TestQuestion(
        id: 'chem5',
        question: 'What is the chemical formula for hydrogen?',
        options: ['H2O', 'CO2', 'O2', 'H2'],
        correctAnswer: 3,
        subject: 'Chemistry',
        difficulty: 'Easy',
        explanation: 'H2 is the chemical formula for hydrogen.',
      ),
    ];
  }

  List<TestQuestion> _getBiologyQuestions() {
    return [
      TestQuestion(
        id: 'bio1',
        question: 'What is the largest organ in the human body?',
        options: ['Heart', 'Brain', 'Liver', 'Lungs'],
        correctAnswer: 2,
        subject: 'Biology',
        difficulty: 'Easy',
        explanation: 'The liver is the largest organ in the human body.',
      ),
      TestQuestion(
        id: 'bio2',
        question: 'What is the chemical formula for glucose?',
        options: ['C6H12O6', 'H2O', 'CO2', 'O2'],
        correctAnswer: 0,
        subject: 'Biology',
        difficulty: 'Easy',
        explanation: 'C6H12O6 is the chemical formula for glucose.',
      ),
      TestQuestion(
        id: 'bio3',
        question: 'What is the chemical formula for water?',
        options: ['H2O', 'CO2', 'O2', 'H2'],
        correctAnswer: 0,
        subject: 'Biology',
        difficulty: 'Easy',
        explanation: 'H2O is the chemical formula for water.',
      ),
      TestQuestion(
        id: 'bio4',
        question: 'What is the chemical formula for carbon dioxide?',
        options: ['CO2', 'H2O', 'O2', 'H2'],
        correctAnswer: 0,
        subject: 'Biology',
        difficulty: 'Easy',
        explanation: 'CO2 is the chemical formula for carbon dioxide.',
      ),
      TestQuestion(
        id: 'bio5',
        question: 'What is the chemical formula for oxygen?',
        options: ['O2', 'H2O', 'CO2', 'H2'],
        correctAnswer: 0,
        subject: 'Biology',
        difficulty: 'Easy',
        explanation: 'O2 is the chemical formula for oxygen.',
      ),
    ];
  }

  void _startTest(MockTest test) async {
    if (test.isCbt) {
      // CBT: Always prompt for subject selection
      final selected = await Navigator.push<List<String>>(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const SubjectSelectionScreen(isForMockTest: true),
        ),
      );
      if (selected == null ||
          selected.length != 4 ||
          !selected.contains('English')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'You must select 4 subjects (English + 3 others) to start the CBT test.',
              ),
            ),
          );
        }
        return;
      }
      setState(() {
        _userSubjects = selected;
      });
    } else {
      // Specific subject tests: Use pre-configured subjects
      setState(() {
        _userSubjects = test.subjects;
      });
    }

    _generateQuestionsForTest(test);

    // Null safety: check if questions and indices are valid
    if (_questions.isEmpty ||
        _userSubjects.isEmpty ||
        _subjectQuestionIndices.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No questions available for the selected subjects. Please try again.',
            ),
          ),
        );
      }
      return;
    }

    setState(() {
      _currentTest = test;
      _isTestInProgress = true;
      _currentQuestionIndex = 0;
      _currentSubject = _userSubjects.first;
      _timeRemaining = test.duration * 60;
      _selectedAnswers = List.filled(_questions.length, '');
      _answeredQuestions = List.filled(_questions.length, false);
    });
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _isTestInProgress && _timeRemaining > 0) {
        setState(() {
          _timeRemaining--;
        });
        _startTimer();
      } else if (_timeRemaining <= 0) {
        _submitTest();
      }
    });
  }



  void _submitTest() async {
    setState(() {
      _isTestInProgress = false;
    });

    // Calculate per-subject scores
    Map<String, int> correctPerSubject = {};
    Map<String, int> attemptedPerSubject = {};
    for (final subject in _userSubjects) {
      correctPerSubject[subject] = 0;
      attemptedPerSubject[subject] = 0;
    }

    for (int i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      final selected = _selectedAnswers[i];
      final correct = question.options[question.correctAnswer];
      final isCorrect = selected == correct;
      attemptedPerSubject[question.subject] =
          (attemptedPerSubject[question.subject] ?? 0) +
          (selected.isNotEmpty ? 1 : 0);
      if (isCorrect) {
        correctPerSubject[question.subject] =
            (correctPerSubject[question.subject] ?? 0) + 1;
      }
    }

    double totalScore = 0;
    List<Map<String, dynamic>> subjectResults = [];

    if (_currentTest!.isCbt) {
      // CBT grading: 400-point scale
      for (final subject in _userSubjects) {
        int correct = correctPerSubject[subject] ?? 0;
        int attempted = attemptedPerSubject[subject] ?? 0;
        double score;
        if (subject == 'English') {
          score = correct * 1.67;
        } else {
          score = correct * 2.5;
        }
        totalScore += score;
        subjectResults.add({
          'subject': subject,
          'correct': correct,
          'attempted': attempted,
          'score': score,
        });
      }
    } else {
      // Quiz grading: 20-point scale (1 mark per question)
      for (final subject in _userSubjects) {
        int correct = correctPerSubject[subject] ?? 0;
        int attempted = attemptedPerSubject[subject] ?? 0;
        double score = correct.toDouble();
        totalScore += score;
        subjectResults.add({
          'subject': subject,
          'correct': correct,
          'attempted': attempted,
          'score': score,
        });
      }
    }

    // Save/update subject progress
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      for (final subject in _userSubjects) {
        final prev = await FirestoreService.loadSubjectProgress(
          user.uid,
          subject,
        );
        double bestScore = prev != null && prev['bestScore'] != null
            ? prev['bestScore']
            : 0;
        final currentScore = subjectResults.firstWhere(
          (r) => r['subject'] == subject,
        )['score'];
        if (currentScore > bestScore) bestScore = currentScore;
        await FirestoreService.saveSubjectProgress(
          user.uid,
          {subject: bestScore},
        );
      }

      // Save test result
      await FirestoreService.saveMockTestResult(
        user.uid,
        'Mock Test',
        totalScore.toInt(),
        _questions.length,
        Duration(minutes: _timeRemaining),
        subjectResults,
      );
    }

    _showResults(subjectResults, totalScore);
  }

  void _showResults(
    List<Map<String, dynamic>> subjectResults,
    double totalScore,
  ) {
    final isCbt = _currentTest!.isCbt;

    if (isCbt) {
      // CBT test - show dialog with history
      final maxScore = 400;
      final testType = 'CBT Mock Test';

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(
                  totalScore >= 280 ? Icons.emoji_events : Icons.school,
                  color: totalScore >= 280
                      ? AppColors.accentAmber
                      : AppColors.dominantPurple,
                ),
                const SizedBox(width: 8),
                Text('$testType Results'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...subjectResults.map(
                  (r) => Text(
                    '${r['subject']}: ${r['score'].toStringAsFixed(2)} marks (${r['correct']} correct)',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total Score: ${totalScore.toStringAsFixed(2)} / $maxScore',
                ),
                const SizedBox(height: 16),
                if (_cbtHistory.isNotEmpty) ...[
                  const Text(
                    'Last 10 CBT Test Scores:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ..._cbtHistory.asMap().entries.map(
                    (entry) => Text(
                      '${entry.key + 1}. ${entry.value['totalScore'].toStringAsFixed(2)} / 400',
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('Back to Tests'),
              ),
            ],
          );
        },
      );
    } else {
      // Quiz test - navigate to quiz results screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResultsScreen(
            subjectResults: subjectResults,
            totalScore: totalScore,
            testTitle: _currentTest!.title,
          ),
        ),
      );
    }
  }



  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
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
          'Mock Tests',
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20),
          ),
        ),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ResponsiveHelper.responsiveSingleChildScrollView(
        context: context,
        child: Padding(
          padding: ResponsiveHelper.getResponsiveEdgeInsets(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeaderSection(context, isDark),
              
              SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
              
              // Available Tests
              _buildAvailableTestsSection(context, isDark),
              
              SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
              
              // Test History
              _buildTestHistorySection(context, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, bool isDark) {
    return ResponsiveHelper.responsiveCard(
      context: context,
      color: isDark ? const Color(0xFF23243B) : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Practice Tests',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 24),
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context) / 2),
          
          Text(
            'Choose a test to practice and improve your UTME skills',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableTestsSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Tests',
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20),
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        
        SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
        
        ResponsiveHelper.responsiveGridView(
          context: context,
          children: _availableTests.map((test) => _buildTestCard(context, test, isDark)).toList(),
        ),
      ],
    );
  }

  Widget _buildTestCard(BuildContext context, MockTest test, bool isDark) {
    return ResponsiveHelper.responsiveCard(
      context: context,
      color: isDark ? const Color(0xFF23243B) : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.quiz,
                color: AppColors.dominantPurple,
                size: ResponsiveHelper.getResponsiveIconSize(context, 24),
              ),
              
              SizedBox(width: ResponsiveHelper.getResponsivePadding(context) / 2),
              
              Expanded(
                child: Text(
                  test.title,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
          
          Text(
            test.description,
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
              color: AppColors.textSecondary,
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
          
          // Test Details
          Row(
            children: [
              _buildTestDetail(
                context,
                Icons.timer,
                '${test.duration} min',
                isDark,
              ),
              
              SizedBox(width: ResponsiveHelper.getResponsivePadding(context)),
              
              _buildTestDetail(
                context,
                Icons.question_answer,
                '${test.questions} questions',
                isDark,
              ),
              
              SizedBox(width: ResponsiveHelper.getResponsivePadding(context)),
              
              _buildTestDetail(
                context,
                Icons.subject,
                test.subjects.length > 1 ? '${test.subjects.length} subjects' : test.subjects.first,
                isDark,
              ),
            ],
          ),
          
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
          
          // Start Button
          ResponsiveHelper.responsiveButton(
            context: context,
            text: 'Start Test',
            onPressed: () => _startTest(test),
            backgroundColor: AppColors.dominantPurple,
            foregroundColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildTestDetail(BuildContext context, IconData icon, String text, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: ResponsiveHelper.getResponsiveIconSize(context, 16),
          color: AppColors.textSecondary,
        ),
        
        SizedBox(width: ResponsiveHelper.getResponsivePadding(context) / 4),
        
        Text(
          text,
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTestHistorySection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Test History',
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20),
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            
            TextButton(
              onPressed: () {
                setState(() {
                  _showHistory = !_showHistory;
                });
              },
              child: Text(
                _showHistory ? 'Hide' : 'Show',
                style: TextStyle(
                  color: AppColors.dominantPurple,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                ),
              ),
            ),
          ],
        ),
        
        if (_showHistory) ...[
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
          
          Column(
            children: _cbtHistory.map((test) => _buildHistoryCard(context, test, isDark)).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildHistoryCard(BuildContext context, Map<String, dynamic> test, bool isDark) {
    return ResponsiveHelper.responsiveCard(
      context: context,
      color: isDark ? const Color(0xFF23243B) : Colors.white,
      child: Row(
        children: [
          Container(
            width: ResponsiveHelper.getResponsiveIconSize(context, 50),
            height: ResponsiveHelper.getResponsiveIconSize(context, 50),
            decoration: BoxDecoration(
              color: AppColors.dominantPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context)),
            ),
            child: Icon(
              Icons.quiz,
              color: AppColors.dominantPurple,
              size: ResponsiveHelper.getResponsiveIconSize(context, 24),
            ),
          ),
          
          SizedBox(width: ResponsiveHelper.getResponsivePadding(context)),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  test['title'] ?? 'Mock Test',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                
                SizedBox(height: ResponsiveHelper.getResponsivePadding(context) / 4),
                
                Text(
                  'Score: ${test['score'] ?? 0}%',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          Icon(
            Icons.arrow_forward_ios,
            color: AppColors.textSecondary,
            size: ResponsiveHelper.getResponsiveIconSize(context, 16),
          ),
        ],
      ),
    );
  }

  Widget _buildTestInterface() {
    final subjectTabs = _userSubjects;
    if (_currentSubject.isEmpty ||
        !_subjectQuestionIndices.containsKey(_currentSubject) ||
        _subjectQuestionIndices[_currentSubject] == null ||
        _subjectQuestionIndices[_currentSubject]!.isEmpty ||
        _questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mock Test'),
          backgroundColor: AppColors.dominantPurple,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text(
            'No questions available for this test. Please select your subjects and try again.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    final currentIndices = _subjectQuestionIndices[_currentSubject]!;
    final currentIndex = _currentQuestionIndex;
    final currentQuestion = _questions[currentIndices[currentIndex]];
    _subjectAnswered = {
      for (var s in _userSubjects)
        s: _subjectQuestionIndices[s]!
            .where((i) => _selectedAnswers[i].isNotEmpty)
            .length,
    };
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        // Show confirmation dialog before allowing back navigation
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit Test?'),
            content: const Text(
              'Are you sure you want to exit the test? Your progress will be lost.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Exit'),
              ),
            ],
          ),
        );
        if (shouldPop == true) {
          if (mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_currentTest!.title),
          backgroundColor: AppColors.dominantPurple,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false, // Prevent back button
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              tooltip: 'View History',
              onPressed: () async {
                await _loadCbtHistory();
                setState(() => _showHistory = true);
              },
            ),
            IconButton(
              icon: const Icon(Icons.check_circle),
              tooltip: 'Submit',
              onPressed: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: Card(
                      color: Colors.white,
                      margin: EdgeInsets.symmetric(horizontal: 60),
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              'Grading...',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
                final result = await _submitTestAndGetResults();
                if (result != null) {
                  if (mounted) {
                    Navigator.of(context).pop(); // Dismiss loading dialog

                    if (_currentTest!.isCbt) {
                      // CBT test - use CBT results screen with history
                      await _loadCbtHistory(orderByScore: false);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResultsScreen(
                            subjectResults: result['subjectResults'],
                            totalScore: result['totalScore'],
                            cbtHistory: _cbtHistory,
                          ),
                        ),
                      );
                    } else {
                      // Quiz test - use quiz results screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizResultsScreen(
                            subjectResults: result['subjectResults'],
                            totalScore: result['totalScore'],
                            testTitle: _currentTest!.title,
                          ),
                        ),
                      );
                    }
                  }
                }
              },
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _timeRemaining < 300
                    ? Colors.red
                    : AppColors.accentAmber,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _formatTime(_timeRemaining),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            // Subject Tabs (moved out of AppBar)
            Container(
              color: AppColors.dominantPurple,
              child: Row(
                children: subjectTabs
                    .map(
                      (s) => Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _currentSubject = s;
                            _currentQuestionIndex = 0;
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: _currentSubject == s
                                      ? AppColors.accentAmber
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  s,
                                  style: TextStyle(
                                    color: _currentSubject == s
                                        ? AppColors.accentAmber
                                        : Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${_subjectAnswered[s]}/${_subjectQuestionIndices[s]!.length}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            LinearProgressIndicator(
              value:
                  (_currentQuestionIndex + 1) /
                  _subjectQuestionIndices[_currentSubject]!.length,
              backgroundColor: AppColors.borderLight,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.dominantPurple,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${_currentQuestionIndex + 1} of ${_subjectQuestionIndices[_currentSubject]!.length}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    _currentSubject,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.dominantPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.transparent,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentQuestion.question,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 24),
                      ...List.generate(
                        currentQuestion.options.length,
                        (i) => _buildOption(
                          currentQuestion.options[i],
                          i,
                          currentQuestion,
                          currentIndices[currentIndex],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppColors.borderLight)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _currentQuestionIndex > 0
                            ? () => setState(() => _currentQuestionIndex--)
                            : null,
                        child: const Text('Previous'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            _currentQuestionIndex <
                                _subjectQuestionIndices[_currentSubject]!
                                        .length -
                                    1
                            ? () => setState(() => _currentQuestionIndex++)
                            : null,
                        child: const Text('Next'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    String option,
    int index,
    TestQuestion question,
    int globalIndex,
  ) {
    bool isSelected = _selectedAnswers[globalIndex] == option;
    return InkWell(
      onTap: () => setState(() {
        _selectedAnswers[globalIndex] = option;
        _answeredQuestions[globalIndex] = true;
      }),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.dominantPurple
              : AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.dominantPurple
                : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : AppColors.borderLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 16, color: AppColors.dominantPurple)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${String.fromCharCode(65 + index)}. $option',
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadCbtHistory({bool orderByScore = true}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('mock_tests')
          .orderBy(
            orderByScore ? 'totalScore' : 'takenAt',
            descending: !orderByScore,
          )
          .limit(10)
          .get();
      _cbtHistory = query.docs.map((d) => d.data()).toList();
    }
  }

  Future<Map<String, dynamic>?> _submitTestAndGetResults() async {
    setState(() {
      _isTestInProgress = false;
    });
    Map<String, int> correctPerSubject = {};
    Map<String, int> attemptedPerSubject = {};
    for (final subject in _userSubjects) {
      correctPerSubject[subject] = 0;
      attemptedPerSubject[subject] = 0;
    }
    for (int i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      final selected = _selectedAnswers[i];
      final correct = question.options[question.correctAnswer];
      final isCorrect = selected == correct;
      attemptedPerSubject[question.subject] =
          (attemptedPerSubject[question.subject] ?? 0) +
          (selected.isNotEmpty ? 1 : 0);
      if (isCorrect) {
        correctPerSubject[question.subject] =
            (correctPerSubject[question.subject] ?? 0) + 1;
      }
    }
    double totalScore = 0;
    List<Map<String, dynamic>> subjectResults = [];
    if (_currentTest != null && _currentTest!.isCbt) {
      for (final subject in _userSubjects) {
        int correct = correctPerSubject[subject] ?? 0;
        int attempted = attemptedPerSubject[subject] ?? 0;
        double score;
        if (subject == 'English') {
          score = correct * 1.67;
        } else {
          score = correct * 2.5;
        }
        totalScore += score;
        subjectResults.add({
          'subject': subject,
          'correct': correct,
          'attempted': attempted,
          'score': score,
        });
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final prev = await FirestoreService.loadSubjectProgress(
            user.uid,
            subject,
          );
          double bestScore = prev != null && prev['bestScore'] != null
              ? prev['bestScore']
              : 0;
          if (score > bestScore) bestScore = score;
          await FirestoreService.saveSubjectProgress(
            user.uid,
            {subject: bestScore},
          );
        }
      }
    } else {
      for (final subject in _userSubjects) {
        int correct = correctPerSubject[subject] ?? 0;
        int attempted = attemptedPerSubject[subject] ?? 0;
        double score = correct.toDouble();
        totalScore += score;
        subjectResults.add({
          'subject': subject,
          'correct': correct,
          'attempted': attempted,
          'score': score,
        });
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final prev = await FirestoreService.loadSubjectProgress(
            user.uid,
            subject,
          );
          double bestScore = prev != null && prev['bestScore'] != null
              ? prev['bestScore']
              : 0;
          if (score > bestScore) bestScore = score;
          await FirestoreService.saveSubjectProgress(
            user.uid,
            {subject: bestScore},
          );
        }
      }
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirestoreService.saveMockTestResult(
        user.uid,
        'Mock Test',
        totalScore.toInt(),
        _questions.length,
        Duration(minutes: _timeRemaining),
        subjectResults,
      );
    }
    return {'subjectResults': subjectResults, 'totalScore': totalScore};
  }
}

class MockTest {
  final String id;
  final String title;
  final String description;
  final int duration; // in minutes
  final int questions;
  final List<String> subjects;
  final String difficulty;
  final bool isCbt;

  MockTest({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.questions,
    required this.subjects,
    required this.difficulty,
    required this.isCbt,
  });
}

class TestResultsScreen extends StatelessWidget {
  final List<TestQuestion> questions;
  final List<String> selectedAnswers;

  const TestResultsScreen({
    super.key,
    required this.questions,
    required this.selectedAnswers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Results'),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          TestQuestion question = questions[index];
          String selectedAnswer = selectedAnswers[index];
          bool isCorrect =
              selectedAnswer == question.options[question.correctAnswer];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isCorrect ? Icons.check_circle : Icons.cancel,
                        color: isCorrect ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Question ${index + 1}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(question.question),
                  const SizedBox(height: 16),
                  Text(
                    'Your Answer: $selectedAnswer',
                    style: TextStyle(
                      color: isCorrect ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (!isCorrect) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Correct Answer: ${question.options[question.correctAnswer]}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'Explanation: ${question.explanation}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class QuizResultsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> subjectResults;
  final double totalScore;
  final String testTitle;

  const QuizResultsScreen({
    super.key,
    required this.subjectResults,
    required this.totalScore,
    required this.testTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$testTitle Results'),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Total Score Badge
            Card(
              color: AppColors.dominantPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 18,
                ),
                child: Column(
                  children: [
                    Icon(
                      totalScore >= 14 ? Icons.emoji_events : Icons.school,
                      color: totalScore >= 14
                          ? AppColors.accentAmber
                          : Colors.white,
                      size: 36,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total Score',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${totalScore.toStringAsFixed(2)} / 20',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Subject Results
            ...subjectResults.map(
              (r) => Card(
                color: r['score'] >= 14
                    ? AppColors.accentAmber.withOpacity(0.15)
                    : Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: Icon(
                    r['score'] >= 14 ? Icons.check_circle : Icons.school,
                    color: r['score'] >= 14
                        ? AppColors.accentAmber
                        : AppColors.dominantPurple,
                    size: 32,
                  ),
                  title: Text(
                    r['subject'],
                    style: TextStyle(
                      color: AppColors.dominantPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Text(
                          '${r['score'].toStringAsFixed(2)} marks',
                          style: TextStyle(
                            color: r['score'] >= 14
                                ? AppColors.accentAmber
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text('(${r['correct']} correct)'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dominantPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Back to Mock Tests',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> subjectResults;
  final double totalScore;
  final List<Map<String, dynamic>> cbtHistory;
  const ResultsScreen({
    super.key,
    required this.subjectResults,
    required this.totalScore,
    required this.cbtHistory,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UTME Mock Test Results'),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Total Score Badge
            Card(
              color: AppColors.dominantPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 18,
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      color: AppColors.accentAmber,
                      size: 36,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total Score',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${totalScore.toStringAsFixed(2)} / 400',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Subject Results
            ...subjectResults.map(
              (r) => Card(
                color: r['score'] >= 70
                    ? AppColors.accentAmber.withOpacity(0.15)
                    : Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: Icon(
                    r['score'] >= 70 ? Icons.check_circle : Icons.school,
                    color: r['score'] >= 70
                        ? AppColors.accentAmber
                        : AppColors.dominantPurple,
                    size: 32,
                  ),
                  title: Text(
                    r['subject'],
                    style: TextStyle(
                      color: AppColors.dominantPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Text(
                          '${r['score'].toStringAsFixed(2)} marks',
                          style: TextStyle(
                            color: r['score'] >= 70
                                ? AppColors.accentAmber
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text('(${r['correct']} correct)'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // History Section
            if (cbtHistory.isNotEmpty) ...[
              Card(
                color: AppColors.backgroundSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Last 10 Mock Test Scores:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...cbtHistory.asMap().entries.map((entry) {
                        final i = entry.key;
                        final h = entry.value;
                        DateTime? date;
                        if (h['takenAt'] != null) {
                          try {
                            date = h['takenAt'] is DateTime
                                ? h['takenAt']
                                : h['takenAt'].toDate();
                          } catch (_) {}
                        }
                        final dateStr = date != null
                            ? '${date.day.toString().padLeft(2, '0')} ${_monthName(date.month)} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'
                            : '';
                        return Row(
                          children: [
                            Icon(
                              Icons.history,
                              color: AppColors.dominantPurple,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${i + 1}. ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${h['totalScore'].toStringAsFixed(2)} / 400',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (dateStr.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Text(
                                dateStr,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dominantPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Back to Mock Tests',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month];
  }
}
