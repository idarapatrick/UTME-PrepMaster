import 'package:flutter/material.dart';
import 'dart:math';
import '../theme/app_colors.dart';
import '../../data/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
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
import '../screens/test_results_screen.dart'; // Added import for TestResultsScreen
import '../widgets/leaderboard_notification.dart'; // Added import for LeaderboardNotification

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

  String _currentSubject = '';

  // CBT Test State
  bool _showSubjectSelection = false;
  final List<String> _selectedSubjects = [
    'English',
  ]; // English is always selected
  List<String> _availableSubjects = [];
  List<TestQuestion> _questions = [];
  bool _isCbt = false; // Added to track if it's a CBT test
  Map<String, List<int>> _subjectQuestionRanges = {};
  // NEW: Track which questions belong to which subject
  List<String> _questionSubjects = [];

  @override
  void initState() {
    super.initState();
    _loadUserSubjects();
    _loadAvailableSubjects();
  }

  void _loadAvailableSubjects() {
    final subjects = <String>[];

    // Check which subjects have questions
    if (mathematicsQuestions.isNotEmpty) subjects.add('Mathematics');
    if (physicsQuestions.isNotEmpty) subjects.add('Physics');
    if (chemistryQuestions.isNotEmpty) subjects.add('Chemistry');
    if (biologyQuestions.isNotEmpty) subjects.add('Biology');
    if (englishQuestions.isNotEmpty) subjects.add('English');
    if (governmentQuestions.isNotEmpty) subjects.add('Government');
    if (economicsQuestions.isNotEmpty) subjects.add('Economics');
    if (geographyQuestions.isNotEmpty) subjects.add('Geography');
    if (commerceQuestions.isNotEmpty) subjects.add('Commerce');
    if (crsQuestions.isNotEmpty) subjects.add('Christian Religious Studies');
    if (islamicStudiesQuestions.isNotEmpty) subjects.add('Islamic Studies');

    setState(() {
      _availableSubjects = subjects;
    });
  }

  Future<void> _loadUserSubjects() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirestoreService.loadUserSubjects(user.uid);
        // User subjects loaded but not used in this screen
      } catch (e) {
        // Error loading user subjects
      }
    }
  }

  List<TestQuestion> _getLocalQuestionsForSubject(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
        return mathematicsQuestions;
      case 'physics':
        return physicsQuestions;
      case 'chemistry':
        return chemistryQuestions;
      case 'biology':
        return biologyQuestions;
      case 'english':
        return englishQuestions;
      case 'government':
        return governmentQuestions;
      case 'economics':
        return economicsQuestions;
      case 'geography':
        return geographyQuestions;
      case 'commerce':
        return commerceQuestions;
      case 'christian religious studies':
        return crsQuestions;
      case 'islamic studies':
        return islamicStudiesQuestions;
      default:
        return [];
    }
  }

  void _showCbtSubjectSelection() {
    setState(() {
      _showSubjectSelection = true;
    });
  }

  void _toggleSubject(String subject) {
    if (subject == 'English') return; // English cannot be unselected

    setState(() {
      if (_selectedSubjects.contains(subject)) {
        if (_selectedSubjects.length > 1) {
          // Keep at least English
          _selectedSubjects.remove(subject);
        }
      } else {
        if (_selectedSubjects.length < 4) {
          // Max 4 subjects (English + 3 others)
          _selectedSubjects.add(subject);
        }
      }
    });
  }

  void _startCbtTest() async {
    if (_selectedSubjects.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select exactly 3 additional subjects (English is already selected)',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Award 20 XP for starting CBT test
    try {
      final userStatsProvider = Provider.of<UserStatsProvider>(
        context,
        listen: false,
      );
      for (final subject in _selectedSubjects) {
        await userStatsProvider.startCbtTest(subject);
      }
    } catch (e) {
      // Error awarding XP, but continue with test
    }

    setState(() {
      _showSubjectSelection = false;
      _isTestInProgress = true;
      _currentQuestionIndex = 0;
      _timeRemaining = 120 * 60; // 120 minutes
      _questions = [];
      _selectedAnswers = [];
      _answeredQuestions = [];
      _isCbt = true; // Set to true for CBT
    });

    _loadCbtQuestions();
  }

  void _loadCbtQuestions() {
    final allQuestions = <TestQuestion>[];
    final subjectQuestionRanges = <String, List<int>>{};
    final questionSubjects = <String>[]; // Track subject for each question
    int currentIndex = 0;

    for (final subject in _selectedSubjects) {
      final subjectQuestions = _getLocalQuestionsForSubject(subject);
      if (subjectQuestions.isNotEmpty) {
        // Shuffle questions and take required number
        final shuffled = List<TestQuestion>.from(subjectQuestions);
        shuffled.shuffle();

        int questionCount;
        if (subject == 'English') {
          questionCount = 60; // Take 60 questions for English
        } else {
          questionCount = 40; // Take 40 questions for other subjects
        }

        final selectedQuestions = shuffled.take(questionCount).toList();
        allQuestions.addAll(selectedQuestions);

        // Store the range of indices for this subject
        final subjectIndices = List<int>.generate(
          questionCount,
          (i) => currentIndex + i,
        );
        subjectQuestionRanges[subject] = subjectIndices;
        
        // Track which subject each question belongs to
        for (int i = 0; i < questionCount; i++) {
          questionSubjects.add(subject);
        }
        
        currentIndex += questionCount;
      }
    }

    setState(() {
      _questions = allQuestions;
      _selectedAnswers = List.filled(allQuestions.length, '');
      _answeredQuestions = List.filled(allQuestions.length, false);
      _subjectQuestionRanges = subjectQuestionRanges;
      _questionSubjects = questionSubjects; // Store the subject mapping
    });

    _startTimer();
  }

  void _startQuiz(String subject) {
    final subjectQuestions = _getLocalQuestionsForSubject(subject);
    if (subjectQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No questions available for $subject'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Take 10 random questions
    final shuffled = List<TestQuestion>.from(subjectQuestions);
    shuffled.shuffle();
    final quizQuestions = shuffled.take(10).toList();

    setState(() {
      _isTestInProgress = true;
      _currentQuestionIndex = 0;
      _timeRemaining = 20 * 60; // 20 minutes
      _questions = quizQuestions;
      _selectedAnswers = List.filled(quizQuestions.length, '');
      _answeredQuestions = List.filled(quizQuestions.length, false);
      _currentSubject = subject;
      _isCbt = false; // Set to false for quiz
      _questionSubjects = List.filled(quizQuestions.length, subject); // All questions are from the same subject
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

  void _selectAnswer(String answer) {
    if (!_isTestInProgress) return;

    setState(() {
      _selectedAnswers[_currentQuestionIndex] = answer;
      _answeredQuestions[_currentQuestionIndex] = true;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  // Get current subject for the current question
  String _getCurrentSubject() {
    if (_questionSubjects.isNotEmpty && _currentQuestionIndex < _questionSubjects.length) {
      return _questionSubjects[_currentQuestionIndex];
    }
    return _currentSubject;
  }

  // Get current question number within the current subject
  int _getCurrentQuestionInSubject() {
    final currentSubject = _getCurrentSubject();
    if (currentSubject.isNotEmpty && _subjectQuestionRanges.containsKey(currentSubject)) {
      final subjectQuestions = _subjectQuestionRanges[currentSubject]!;
      final currentIndexInSubject = subjectQuestions.indexOf(
        _currentQuestionIndex,
      );
      return currentIndexInSubject + 1;
    }
    return _currentQuestionIndex + 1;
  }

  // Get total questions in the current subject
  int _getTotalQuestionsInSubject() {
    final currentSubject = _getCurrentSubject();
    if (currentSubject.isNotEmpty && _subjectQuestionRanges.containsKey(currentSubject)) {
      return _subjectQuestionRanges[currentSubject]!.length;
    }
    return _questions.length;
  }

  // Get next question in the same subject
  void _nextQuestionInSubject() {
    final currentSubject = _getCurrentSubject();
    if (currentSubject.isNotEmpty) {
      final subjectQuestions = _subjectQuestionRanges[currentSubject]!;
      final currentIndexInSubject = subjectQuestions.indexOf(
        _currentQuestionIndex,
      );

      if (currentIndexInSubject < subjectQuestions.length - 1) {
        // Move to next question in same subject
        setState(() {
          _currentQuestionIndex = subjectQuestions[currentIndexInSubject + 1];
        });
      } else {
        // Move to first question of next subject
        final subjects = _subjectQuestionRanges.keys.toList();
        final currentSubjectIndex = subjects.indexOf(currentSubject);
        if (currentSubjectIndex < subjects.length - 1) {
          final nextSubject = subjects[currentSubjectIndex + 1];
          final nextSubjectQuestions = _subjectQuestionRanges[nextSubject]!;
          setState(() {
            _currentQuestionIndex = nextSubjectQuestions.first;
          });
        }
      }
    }
  }

  // Get previous question in the same subject
  void _previousQuestionInSubject() {
    final currentSubject = _getCurrentSubject();
    if (currentSubject.isNotEmpty) {
      final subjectQuestions = _subjectQuestionRanges[currentSubject]!;
      final currentIndexInSubject = subjectQuestions.indexOf(
        _currentQuestionIndex,
      );

      if (currentIndexInSubject > 0) {
        // Move to previous question in same subject
        setState(() {
          _currentQuestionIndex = subjectQuestions[currentIndexInSubject - 1];
        });
      } else {
        // Move to last question of previous subject
        final subjects = _subjectQuestionRanges.keys.toList();
        final currentSubjectIndex = subjects.indexOf(currentSubject);
        if (currentSubjectIndex > 0) {
          final previousSubject = subjects[currentSubjectIndex - 1];
          final previousSubjectQuestions =
              _subjectQuestionRanges[previousSubject]!;
          setState(() {
            _currentQuestionIndex = previousSubjectQuestions.last;
          });
        }
      }
    }
  }

  void _submitTest() async {
    setState(() {
      _isTestInProgress = false;
    });

    final correctAnswers = _calculateCorrectAnswers();
    final isCbt = _currentSubject.isEmpty; // If no specific subject, it's CBT

    double score;
    if (isCbt) {
      // CBT: graded over 400
      score = (correctAnswers / _questions.length) * 400;
    } else {
      // Quiz: graded over 20 (2 marks per question)
      score = correctAnswers * 2.0;
    }

    // Save results
    final user = FirebaseAuth.instance.currentUser;
    Map<String, dynamic>? leaderboardResult;
    if (user != null) {
      try {
        if (isCbt) {
      

          // Save to leaderboard
          leaderboardResult = await FirestoreService.saveCbtResult(
            user.uid,
            'cbt_test',
            score.toInt(),
            correctAnswers,
            _questions.length,
            120 * 60 - _timeRemaining,
          );


          // Update user stats with new comprehensive tracking and show XP popup
          if (mounted) {
            final userStatsProvider = Provider.of<UserStatsProvider>(
              context,
              listen: false,
            );
            await userStatsProvider.completeCbtTestWithPopup(
              subjectId: _currentSubject,
              totalQuestions: _questions.length,
              correctAnswers: correctAnswers,
              timeSpentMinutes:
                  (120 * 60 - _timeRemaining) ~/ 60, // Convert seconds to minutes
              score: score.toInt(),
            );
          }
        } else {
          await FirestoreService.saveQuizResult(
            user.uid,
            _currentSubject,
            score.toInt(),
            _questions.length,
            Duration(seconds: 20 * 60 - _timeRemaining),
          );

          // Update user stats for quiz completion
          if (mounted) {
            final userStatsProvider = Provider.of<UserStatsProvider>(
              context,
              listen: false,
            );
            await userStatsProvider.completeQuizWithNewSystem(
              subjectId: _currentSubject,
              totalQuestions: _questions.length,
              correctAnswers: correctAnswers,
              timeSpentMinutes:
                  (20 * 60 - _timeRemaining) ~/ 60, // Convert seconds to minutes
            );
          }
        }
      } catch (e) {

        // Error saving results
      }
    }

    // Show results
    if (mounted) {
      _showResults(correctAnswers, score, isCbt, leaderboardResult);
    }
  }

  int _calculateCorrectAnswers() {
    int correct = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_selectedAnswers[i] ==
          _questions[i].options[_questions[i].correctAnswer]) {
        correct++;
      }
    }
    return correct;
  }

  void _showResults(
    int correctAnswers,
    double score,
    bool isCbt,
    Map<String, dynamic>? leaderboardResult,
  ) async {
    // Show grading screen first
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.dominantPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 16),
              const Text(
                'Grading...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please wait while we calculate your results',
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );

    // Simulate grading time (2-4 seconds)
    await Future.delayed(
      Duration(seconds: 2 + (DateTime.now().millisecond % 3)),
    );

    // Close grading dialog
    if (mounted) {
      Navigator.of(context).pop();
    }

    // Show leaderboard notification if user made it to top 20
    if (mounted &&
        leaderboardResult != null &&
        leaderboardResult['inTop20'] == true) {

      _showLeaderboardNotification(
        leaderboardResult['rank'] as int,
        leaderboardResult['score'] as int,
      );
    } else {

    }

    // Navigate to results screen
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TestResultsScreen(
            correctAnswers: correctAnswers,
            totalQuestions: _questions.length,
            score: score,
            isCbt: isCbt,
            selectedSubjects: _selectedSubjects,
            timeElapsed: isCbt
                ? 120 * 60 - _timeRemaining
                : 20 * 60 - _timeRemaining,
            subjectScores: _calculateSubjectScores(),
          ),
        ),
      );
    }
  }

  void _showLeaderboardNotification(int rank, int score) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: LeaderboardNotification(
          rank: rank,
          score: score,
          onDismiss: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Map<String, double> _calculateSubjectScores() {
    if (!_isCbt) return {};

    final Map<String, double> subjectScores = {};
    final Map<String, int> subjectCorrect = {};
    final Map<String, int> subjectTotal = {};

    for (int i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      final subject = _getQuestionSubject(i);

      if (subject != null) {
        subjectTotal[subject] = (subjectTotal[subject] ?? 0) + 1;
        if (_selectedAnswers[i] == question.options[question.correctAnswer]) {
          subjectCorrect[subject] = (subjectCorrect[subject] ?? 0) + 1;
        }
      }
    }

    for (final subject in subjectTotal.keys) {
      final correct = subjectCorrect[subject] ?? 0;
      final total = subjectTotal[subject] ?? 1;
      subjectScores[subject] = (correct / total) * 100;
    }

    return subjectScores;
  }

  String? _getQuestionSubject(int questionIndex) {
    // Use the stored subject mapping instead of the faulty calculation
    if (questionIndex < _questionSubjects.length) {
      return _questionSubjects[questionIndex];
    }
    return null;
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isTestInProgress) {
      return _buildTestInterface();
    }

    if (_showSubjectSelection) {
      return _buildSubjectSelectionInterface();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mock Tests'),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Tests',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // CBT Test Option
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                title: const Text('CBT Test'),
                subtitle: const Text(
                  '180 questions (60 English + 40 each from 3 subjects), 120 minutes, graded over 400',
                ),
                trailing: ElevatedButton(
                  onPressed: _showCbtSubjectSelection,
                  child: const Text('Start CBT'),
                ),
              ),
            ),

            const Text(
              'Subject Quizzes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '10 random questions, 20 minutes, graded over 20',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                itemCount: _availableSubjects.length,
                itemBuilder: (context, index) {
                  final subject = _availableSubjects[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(subject),
                      subtitle: Text('10 questions, 20 minutes'),
                      trailing: ElevatedButton(
                        onPressed: () => _startQuiz(subject),
                        child: const Text('Start Quiz'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectSelectionInterface() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Subjects for CBT'),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _showSubjectSelection = false;
            });
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select 3 additional subjects (English is already selected)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Selected subjects
            Wrap(
              spacing: 8,
              children: _selectedSubjects.map((subject) {
                final isEnglish = subject == 'English';
                return Chip(
                  label: Text(subject),
                  backgroundColor: isEnglish
                      ? Colors.grey
                      : AppColors.dominantPurple,
                  deleteIcon: isEnglish ? null : const Icon(Icons.close),
                  onDeleted: isEnglish ? null : () => _toggleSubject(subject),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),
            const Text(
              'Available Subjects',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                itemCount: _availableSubjects.length,
                itemBuilder: (context, index) {
                  final subject = _availableSubjects[index];
                  final isSelected = _selectedSubjects.contains(subject);
                  final isEnglish = subject == 'English';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(subject),
                      subtitle: Text(isEnglish ? 'Compulsory' : 'Optional'),
                      trailing: isEnglish
                          ? const Icon(Icons.lock, color: Colors.grey)
                          : Checkbox(
                              value: isSelected,
                              onChanged: (value) => _toggleSubject(subject),
                            ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedSubjects.length == 4 ? _startCbtTest : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dominantPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Start CBT Test'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestInterface() {
    if (_questions.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;
    final isCbt = _currentSubject.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(isCbt ? 'CBT Test' : '$_currentSubject Quiz'),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Exit Test?'),
                content: const Text(
                  'Are you sure you want to exit? Your progress will be lost.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _isTestInProgress = false;
                        _showSubjectSelection = false;
                      });
                    },
                    child: const Text('Exit'),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          // Professional Timer Container
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  _formatTime(_timeRemaining),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Calculator Button
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: _showCalculator,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentAmber,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calculate,
                  color: Colors.white,
                  size: 20,
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
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.dominantPurple),
          ),

          // Subject Tabs (only for CBT)
          if (isCbt) _buildSubjectTabs(),

          // Question counter
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isCbt
                      ? '${_getCurrentSubject()} - Question ${_getCurrentQuestionInSubject()} of ${_getTotalQuestionsInSubject()}'
                      : 'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
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
                    final isSelected =
                        _selectedAnswers[_currentQuestionIndex] == option;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () => _selectAnswer(option),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.dominantPurple
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.dominantPurple
                                  : Colors.grey[300]!,
                            ),
                          ),
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 16,
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
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
                // Previous button
                ElevatedButton(
                  onPressed: _isCbt
                      ? _previousQuestionInSubject
                      : (_currentQuestionIndex > 0 ? _previousQuestion : null),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Previous'),
                ),

                // Submit button (always available)
                ElevatedButton(
                  onPressed: _submitTest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Submit'),
                ),

                // Next button
                ElevatedButton(
                  onPressed: _isCbt
                      ? _nextQuestionInSubject
                      : (_currentQuestionIndex < _questions.length - 1
                            ? _nextQuestion
                            : null),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dominantPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectTabs() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _subjectQuestionRanges.length,
        itemBuilder: (context, index) {
          final subject = _subjectQuestionRanges.keys.elementAt(index);
          final questionIndices = _subjectQuestionRanges[subject]!;
          final isCurrentSubject = questionIndices.contains(
            _currentQuestionIndex,
          );

          // Calculate progress for this subject
          final answeredInSubject = questionIndices
              .where((index) => _answeredQuestions[index])
              .length;
          final totalInSubject = questionIndices.length;

          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: ElevatedButton(
              onPressed: () {
                // Jump to first unanswered question of this subject, or first question if all answered
                final firstUnansweredIndex = questionIndices.firstWhere(
                  (index) => !_answeredQuestions[index],
                  orElse: () => questionIndices.first,
                );
                setState(() {
                  _currentQuestionIndex = firstUnansweredIndex;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isCurrentSubject
                    ? AppColors.dominantPurple
                    : Colors.grey[200],
                foregroundColor: isCurrentSubject ? Colors.white : Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    subject,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isCurrentSubject
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  Text(
                    '$answeredInSubject/$totalInSubject',
                    style: TextStyle(
                      fontSize: 10,
                      color: isCurrentSubject ? Colors.white70 : Colors.black54,
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

  void _showCalculator() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CalculatorWidget(),
    );
  }
}

class CalculatorWidget extends StatefulWidget {
  const CalculatorWidget({super.key});

  @override
  State<CalculatorWidget> createState() => _CalculatorWidgetState();
}

class _CalculatorWidgetState extends State<CalculatorWidget> {
  String _display = '0';
  String _operation = '';
  double _firstNumber = 0;
  bool _isNewNumber = true;

  void _onNumberPressed(String number) {
    setState(() {
      if (_isNewNumber) {
        _display = number;
        _isNewNumber = false;
      } else {
        _display = _display + number;
      }
    });
  }

  void _onOperationPressed(String operation) {
    setState(() {
      _firstNumber = double.parse(_display);
      _operation = operation;
      _isNewNumber = true;
    });
  }

  void _calculate() {
    if (_operation.isEmpty) return;

    final secondNumber = double.parse(_display);
    double result = 0;

    switch (_operation) {
      case '+':
        result = _firstNumber + secondNumber;
        break;
      case '-':
        result = _firstNumber - secondNumber;
        break;
      case '×':
        result = _firstNumber * secondNumber;
        break;
      case '÷':
        result = _firstNumber / secondNumber;
        break;
      case 'log':
        result = log(secondNumber) / ln10;
        break;
      case 'ln':
        result = log(secondNumber);
        break;
      case 'sin':
        result = sin(secondNumber * pi / 180);
        break;
      case 'cos':
        result = cos(secondNumber * pi / 180);
        break;
      case 'tan':
        result = tan(secondNumber * pi / 180);
        break;
    }

    setState(() {
      _display = result.toString();
      _operation = '';
      _isNewNumber = true;
    });
  }

  void _clear() {
    setState(() {
      _display = '0';
      _operation = '';
      _firstNumber = 0;
      _isNewNumber = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _operation.isNotEmpty ? '$_firstNumber $_operation' : '',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                Text(
                  _display,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Calculator buttons
          Expanded(
            child: GridView.count(
              crossAxisCount: 4,
              padding: const EdgeInsets.all(16),
              children: [
                // Scientific functions
                _buildButton('C', Colors.red, _clear),
                _buildButton(
                  'log',
                  Colors.orange,
                  () => _onOperationPressed('log'),
                ),
                _buildButton(
                  'ln',
                  Colors.orange,
                  () => _onOperationPressed('ln'),
                ),
                _buildButton(
                  '÷',
                  Colors.orange,
                  () => _onOperationPressed('÷'),
                ),

                _buildButton(
                  'sin',
                  Colors.orange,
                  () => _onOperationPressed('sin'),
                ),
                _buildButton(
                  'cos',
                  Colors.orange,
                  () => _onOperationPressed('cos'),
                ),
                _buildButton(
                  'tan',
                  Colors.orange,
                  () => _onOperationPressed('tan'),
                ),
                _buildButton(
                  '×',
                  Colors.orange,
                  () => _onOperationPressed('×'),
                ),

                // Numbers and basic operations
                _buildButton(
                  '7',
                  Colors.grey[300]!,
                  () => _onNumberPressed('7'),
                ),
                _buildButton(
                  '8',
                  Colors.grey[300]!,
                  () => _onNumberPressed('8'),
                ),
                _buildButton(
                  '9',
                  Colors.grey[300]!,
                  () => _onNumberPressed('9'),
                ),
                _buildButton(
                  '-',
                  Colors.orange,
                  () => _onOperationPressed('-'),
                ),

                _buildButton(
                  '4',
                  Colors.grey[300]!,
                  () => _onNumberPressed('4'),
                ),
                _buildButton(
                  '5',
                  Colors.grey[300]!,
                  () => _onNumberPressed('5'),
                ),
                _buildButton(
                  '6',
                  Colors.grey[300]!,
                  () => _onNumberPressed('6'),
                ),
                _buildButton(
                  '+',
                  Colors.orange,
                  () => _onOperationPressed('+'),
                ),

                _buildButton(
                  '1',
                  Colors.grey[300]!,
                  () => _onNumberPressed('1'),
                ),
                _buildButton(
                  '2',
                  Colors.grey[300]!,
                  () => _onNumberPressed('2'),
                ),
                _buildButton(
                  '3',
                  Colors.grey[300]!,
                  () => _onNumberPressed('3'),
                ),
                _buildButton('=', Colors.green, _calculate, isLarge: true),

                _buildButton(
                  '0',
                  Colors.grey[300]!,
                  () => _onNumberPressed('0'),
                  isLarge: true,
                ),
                _buildButton(
                  '.',
                  Colors.grey[300]!,
                  () => _onNumberPressed('.'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    String text,
    Color color,
    VoidCallback onPressed, {
    bool isLarge = false,
  }) {
    return Container(
      margin: const EdgeInsets.all(4),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
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