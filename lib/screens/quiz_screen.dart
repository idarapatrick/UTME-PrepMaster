import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../theme/app_colors.dart';

class QuizScreen extends StatefulWidget {
  final String subject;
  const QuizScreen({super.key, required this.subject});

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

  void _generateQuestions() {
    _questions = List.generate(
      10,
      (i) => _QuizQuestion(
        id: '${widget.subject}_$i',
        question: 'Sample ${widget.subject} Quiz Question ${i + 1}',
        options: ['A', 'B', 'C', 'D'],
        correctAnswer: 0,
        explanation: 'Explanation for ${widget.subject} Q${i + 1}',
      ),
    );
    setState(() => _loading = false);
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
      await FirestoreService.saveQuizResult(
        userId: user.uid,
        subject: widget.subject,
        correct: correct,
        attempted: attempted,
        score: score,
      );
      final prev = await FirestoreService.loadSubjectProgress(
        user.uid,
        widget.subject,
      );
      double bestScore = prev != null && prev['bestScore'] != null
          ? prev['bestScore']
          : 0;
      if (score > bestScore) {
        await FirestoreService.saveSubjectProgress(
          userId: user.uid,
          subject: widget.subject,
          attempted: attempted,
          correct: correct,
          bestScore: score,
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
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_finished) {
      return const Scaffold(
        body: Center(child: Text('Quiz finished.')), // Should not be visible
      );
    }
    final q = _questions[_currentQuestionIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subject} Quiz'),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_paused ? Icons.play_arrow : Icons.pause),
            tooltip: _paused ? 'Resume' : 'Pause',
            onPressed: _paused ? _resumeQuiz : _pauseQuiz,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                _formatTime(_timeElapsed),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _questions.length,
            backgroundColor: AppColors.borderLight,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.dominantPurple),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  widget.subject,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.dominantPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    q.question,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...List.generate(
                    q.options.length,
                    (i) => _buildOption(q.options[i], i, q),
                  ),
                ],
              ),
            ),
          ),
          Container(
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
                        ? _previousQuestion
                        : null,
                    child: const Text('Previous'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentQuestionIndex < _questions.length - 1
                        ? _nextQuestion
                        : _submitQuiz,
                    child: Text(
                      _currentQuestionIndex < _questions.length - 1
                          ? 'Next'
                          : 'Submit',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(String option, int index, _QuizQuestion question) {
    bool isSelected = _selectedAnswers[_currentQuestionIndex] == option;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: _paused ? null : () => _selectAnswer(option),
        borderRadius: BorderRadius.circular(12),
        child: Container(
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
                    ? Icon(
                        Icons.check,
                        size: 16,
                        color: AppColors.dominantPurple,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${String.fromCharCode(65 + index)}. $option',
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
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
