import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_colors.dart';
import '../../data/services/firestore_service.dart';
import '../utils/responsive_helper.dart';

class TestResultsScreen extends StatefulWidget {
  final int correctAnswers;
  final int totalQuestions;
  final double score;
  final bool isCbt;
  final List<String> selectedSubjects;
  final int timeElapsed;
  final Map<String, double> subjectScores;

  const TestResultsScreen({
    super.key,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.score,
    required this.isCbt,
    required this.selectedSubjects,
    required this.timeElapsed,
    required this.subjectScores,
  });

  @override
  State<TestResultsScreen> createState() => _TestResultsScreenState();
}

class _TestResultsScreenState extends State<TestResultsScreen> {
  List<Map<String, dynamic>> _cbtHistory = [];
  bool _loadingHistory = true;

  @override
  void initState() {
    super.initState();
    if (widget.isCbt) {
      _loadCbtHistory();
    }
  }

  Future<void> _loadCbtHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final history = await FirestoreService.getCbtHistory(user.uid);
        setState(() {
          _cbtHistory = history;
          _loadingHistory = false;
        });
      } catch (e) {
        // Error loading CBT history
        setState(() {
          _loadingHistory = false;
        });
      }
    }
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  String _getScoreGrade(double score, double maxScore) {
    final percentage = (score / maxScore) * 100;
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B+';
    if (percentage >= 60) return 'B';
    if (percentage >= 50) return 'C';
    if (percentage >= 40) return 'D';
    return 'F';
  }

  Color _getScoreColor(double score, double maxScore) {
    final percentage = (score / maxScore) * 100;
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final maxScore = widget.isCbt ? 400.0 : 20.0;
    final testType = widget.isCbt ? 'CBT Test' : 'Quiz';
    final grade = _getScoreGrade(widget.score, maxScore);
    final scoreColor = _getScoreColor(widget.score, maxScore);

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        title: Text('$testType Results'),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Score Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      testType,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          18,
                        ),
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: scoreColor.withValues(alpha: 0.1),
                        border: Border.all(color: scoreColor, width: 3),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.score.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
                                      context,
                                      24,
                                    ),
                                fontWeight: FontWeight.bold,
                                color: scoreColor,
                              ),
                            ),
                            Text(
                              '/ $maxScore',
                              style: TextStyle(
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
                                      context,
                                      14,
                                    ),
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Grade: $grade',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          20,
                        ),
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.correctAnswers} out of ${widget.totalQuestions} correct',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          16,
                        ),
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Time: ${_formatTime(widget.timeElapsed)}',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          14,
                        ),
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Subject Breakdown (for CBT only)
            if (widget.isCbt && widget.subjectScores.isNotEmpty) ...[
              Text(
                'Subject Breakdown',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: widget.subjectScores.entries.map((entry) {
                      final subject = entry.key;
                      final score = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                subject,
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                        context,
                                        16,
                                      ),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: LinearProgressIndicator(
                                value: score / 100,
                                backgroundColor: AppColors.textTertiary
                                    .withValues(alpha: 0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getScoreColor(score, 100),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${score.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
                                      context,
                                      14,
                                    ),
                                fontWeight: FontWeight.bold,
                                color: _getScoreColor(score, 100),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // CBT History (for CBT only)
            if (widget.isCbt) ...[
              Text(
                'Recent CBT Tests',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              if (_loadingHistory)
                const Center(child: CircularProgressIndicator())
              else if (_cbtHistory.isEmpty)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No previous CBT tests found',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
              else
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: _cbtHistory.take(5).map((test) {
                        final score = test['score'] ?? 0;
                        final date = test['date'] != null
                            ? DateTime.parse(test['date'])
                            : DateTime.now();
                        final grade = _getScoreGrade(score.toDouble(), 400);
                        final scoreColor = _getScoreColor(
                          score.toDouble(),
                          400,
                        );

                        return ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: scoreColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                grade,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: scoreColor,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            'Score: $score/400',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${date.day}/${date.month}/${date.year}',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          trailing: Text(
                            '${test['correctAnswers'] ?? 0}/${test['totalQuestions'] ?? 0}',
                            style: TextStyle(color: AppColors.textTertiary),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
            ],

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home',
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.dominantPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Return to Home',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/leaderboard');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.dominantPurple,
                      side: const BorderSide(color: AppColors.dominantPurple),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'View Leaderboard',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
