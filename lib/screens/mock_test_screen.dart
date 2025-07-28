import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/subject_selection_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../questions/english_questions.dart';
import '../questions/mathematics_questions.dart';
import '../questions/physics_questions.dart';
import '../questions/chemistry_questions.dart';
import '../questions/biology_questions.dart';
import '../models/test_question.dart';

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

  final List<MockTest> _availableTests = [
    MockTest(
      id: '1',
      title: 'CBT Mock Test',
      description: 'Complete UTME simulation with subject selection',
      duration: 120, // 2 hours
      questions: 180,
      subjects: ['English', 'Mathematics', 'Physics', 'Chemistry'],
      difficulty: 'Advanced',
      isCbt: true,
    ),
    MockTest(
      id: '2',
      title: 'Mathematics Test',
      description: 'Mathematics practice test (20 questions)',
      duration: 30, // 30 minutes
      questions: 20,
      subjects: ['Mathematics'],
      difficulty: 'Intermediate',
      isCbt: false,
    ),
    MockTest(
      id: '3',
      title: 'English Language Test',
      description: 'English language assessment (20 questions)',
      duration: 25, // 25 minutes
      questions: 20,
      subjects: ['English'],
      difficulty: 'Intermediate',
      isCbt: false,
    ),
    MockTest(
      id: '4',
      title: 'Science Test',
      description: 'Physics, Chemistry, and Biology combined (20 questions)',
      duration: 35, // 35 minutes
      questions: 20,
      subjects: ['Physics', 'Chemistry', 'Biology'],
      difficulty: 'Advanced',
      isCbt: false,
    ),
  ];

  MockTest? _currentTest;
  List<TestQuestion> _questions = [];

  @override
  void initState() {
    super.initState();
    _loadUserSubjects();
  }

  Future<void> _loadUserSubjects() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final selected = await FirestoreService.loadUserSubjects(user.uid);
      setState(() {
        _userSubjects = selected;
      });
    }
  }

  void _generateQuestionsForTest(MockTest test) {
    _questions = [];
    _subjectQuestionIndices.clear();

    if (test.isCbt) {
      // CBT: Pull 60 English, 40 each from other 3 subjects
      final eng = englishQuestions.take(60).toList();
      final others = <TestQuestion>[];
      for (final subj in _userSubjects.where((s) => s != 'English')) {
        final list = _getQuestionsForSubject(subj).take(40).toList();
        others.addAll(list);
      }
      _questions = [...eng, ...others];
      // Set up indices for subject tabs
      int idx = 0;
      for (final subj in _userSubjects) {
        final count = subj == 'English' ? 60 : 40;
        _subjectQuestionIndices[subj] = List.generate(count, (i) => idx + i);
        idx += count;
      }
    } else {
      // Specific subject tests: 20 questions each
      if (test.title == 'Science Test') {
        // Mix Physics, Chemistry, Biology questions
        final physics = physicsQuestions.take(7).toList();
        final chemistry = chemistryQuestions.take(7).toList();
        final biology = _getQuestionsForSubject('Biology').take(6).toList();
        _questions = [...physics, ...chemistry, ...biology];
        _subjectQuestionIndices['Physics'] = List.generate(7, (i) => i);
        _subjectQuestionIndices['Chemistry'] = List.generate(7, (i) => i + 7);
        _subjectQuestionIndices['Biology'] = List.generate(6, (i) => i + 14);
      } else {
        // Single subject test: 20 questions
        final subj = test.subjects.first;
        _questions = _getQuestionsForSubject(subj).take(20).toList();
        _subjectQuestionIndices[subj] = List.generate(20, (i) => i);
      }
    }
  }

  List<TestQuestion> _getQuestionsForSubject(String subject) {
    List<TestQuestion> questions;
    switch (subject) {
      case 'English':
        questions = englishQuestions;
        break;
      case 'Mathematics':
        questions = mathematicsQuestions;
        break;
      case 'Physics':
        questions = physicsQuestions;
        break;
      case 'Chemistry':
        questions = chemistryQuestions;
        break;
      case 'Biology':
        questions = biologyQuestions;
        break;
      default:
        questions = [];
        break;
    }
    return questions;
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
    if (_isTestInProgress && _currentTest != null) {
      return _buildTestInterface();
    }

    if (_showHistory) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mock Test History'),
          backgroundColor: AppColors.dominantPurple,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() => _showHistory = false),
          ),
        ),
        body: ListView.builder(
          itemCount: _cbtHistory.length,
          itemBuilder: (context, i) {
            final h = _cbtHistory[i];
            return ListTile(
              leading: CircleAvatar(child: Text('${i + 1}')),
              title: Text('Score: ${h['totalScore'].toStringAsFixed(2)} / 400'),
              subtitle: Text(
                'Taken: ${h['takenAt'] != null ? h['takenAt'].toDate().toString() : ''}',
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mock Tests'),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.dominantPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.dominantPurple.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.quiz, size: 48, color: AppColors.dominantPurple),
                const SizedBox(height: 16),
                Text(
                  'Mock Tests',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Practice with realistic UTME-style questions',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Available Tests
          Text(
            'Available Tests',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          ..._availableTests.map((test) => _buildTestCard(test)),
        ],
      ),
    );
  }

  Widget _buildTestCard(MockTest test) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: ListTile(
        leading: Icon(Icons.quiz, color: AppColors.dominantPurple, size: 32),
        title: Text(
          test.title,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          test.description,
          style: TextStyle(
            color: isDark ? Colors.white70 : AppColors.textSecondary,
          ),
        ),
        trailing: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Starting ${test.title}...'),
                duration: const Duration(seconds: 1),
              ),
            );

            try {
              _startTest(test);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error starting test: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.dominantPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text('Start'),
        ),
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
