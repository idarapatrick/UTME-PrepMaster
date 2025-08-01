import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import 'quiz_screen.dart';
import '../../data/course_content_data.dart';

class CourseContentScreen extends StatefulWidget {
  final String subject;
  final String? initialTab;
  const CourseContentScreen({
    super.key,
    required this.subject,
    this.initialTab,
  });

  @override
  State<CourseContentScreen> createState() => _CourseContentScreenState();
}

class _CourseContentScreenState extends State<CourseContentScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _topics = [];
  // Map<String, bool> _completed = {};
  bool _loading = true;
  late TabController _tabController;
  int _selectedIndex = 0;

  static const List<String> _tabs = ['syllabi', 'quizzes'];

  @override
  void initState() {
    super.initState();
    if (widget.initialTab != null) {
      final idx = _tabs.indexOf(widget.initialTab!.toLowerCase());
      if (idx != -1) {
        _selectedIndex = idx;
      }
    }
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: _selectedIndex,
    );
    _loadTopics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getFullSubjectName(String simpleName) {
    // Map simple subject names to full names used in course content data
    switch (simpleName.toLowerCase()) {
      case 'english':
        return 'English Language';
      case 'mathematics':
        return 'Mathematics';
      case 'physics':
        return 'Physics';
      case 'chemistry':
        return 'Chemistry';
      case 'biology':
        return 'Biology';
      case 'economics':
        return 'Economics';
      case 'government':
        return 'Government';
      case 'geography':
        return 'Geography';
      case 'christian religious studies':
      case 'crs':
        return 'Christian Religious Studies (CRS)';
      case 'islamic religious studies':
      case 'irs':
        return 'Islamic Religious Studies (IRS)';
      case 'commerce':
        return 'Commerce';
      case 'literature in english':
        return 'Literature in English';
      default:
        return simpleName; // Return as-is if no mapping found
    }
  }

  Future<void> _loadTopics() async {
    // Load syllabi from course content data
    final fullSubjectName = _getFullSubjectName(widget.subject);

    final subjectData = courseContentData[fullSubjectName];
    if (subjectData != null && subjectData['syllabi'] != null) {
      _topics = List<Map<String, dynamic>>.from(subjectData['syllabi']);
    } else {
      _topics = [];
    }

    setState(() => _loading = false);
  }

  Future<void> _openWebLink(String url) async {
    try {
      // Ensure URL has proper scheme
      String validUrl = url.trim();
      if (!validUrl.startsWith('http://') && !validUrl.startsWith('https://')) {
        validUrl = 'https://$validUrl';
      }

      final uri = Uri.parse(validUrl);

      // Try to launch URL with different modes
      bool launched = false;

      // First try with external application mode
      try {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {}

      // If external failed, try with platform default
      if (!launched) {
        try {
          launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
        } catch (e) {}
      }

      // If still failed, try with in-app web view
      if (!launched) {
        try {
          launched = await launchUrl(uri, mode: LaunchMode.inAppWebView);
        } catch (e) {}
      }

      if (!launched && mounted) {
        // Try to show a dialog with options to copy URL or open in browser
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Unable to Open Link'),
              content: Text(
                'The link could not be opened automatically. Would you like to copy the URL to your clipboard?',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    // Copy URL to clipboard
                    await Clipboard.setData(ClipboardData(text: validUrl));
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('URL copied to clipboard: $validUrl'),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text('Copy URL'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening link: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _resetProgress() {
    setState(() {
      // _completed = {for (var t in _topics) t['id']: false};
    });
  }

  Widget _buildQuizzesTab() {
    final quizzes = _getSubjectQuizzes(widget.subject);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: quizzes.length,
      itemBuilder: (context, index) {
        final quiz = quizzes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.dominantPurple.withValues(alpha: 0.1),
              child: Icon(Icons.quiz, color: AppColors.dominantPurple),
            ),
            title: Text(
              quiz['title'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(quiz['description']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${quiz['questions']} Qs',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizScreen(
                    subject: widget.subject,
                    quizType: quiz['type'],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _getSubjectQuizzes(String subject) {
    final fullSubjectName = _getFullSubjectName(subject);

    final allQuizzes = [
      {
        'title': 'Basic Concepts Quiz',
        'description': 'Test your understanding of fundamental concepts',
        'questions': 10,
        'type': 'basic',
        'subjects': ['Mathematics', 'Physics', 'Chemistry', 'Biology'],
      },
      {
        'title': 'Problem Solving Quiz',
        'description': 'Practice solving complex problems',
        'questions': 15,
        'type': 'problem_solving',
        'subjects': ['Mathematics', 'Physics', 'Chemistry'],
      },
      {
        'title': 'Theory Quiz',
        'description': 'Test your theoretical knowledge',
        'questions': 12,
        'type': 'theory',
        'subjects': ['Physics', 'Chemistry', 'Biology'],
      },
      {
        'title': 'Grammar Quiz',
        'description': 'Test your English grammar skills',
        'questions': 20,
        'type': 'grammar',
        'subjects': ['English Language'],
      },
      {
        'title': 'Comprehension Quiz',
        'description': 'Test your reading comprehension',
        'questions': 15,
        'type': 'comprehension',
        'subjects': ['English Language'],
      },
      {
        'title': 'Literature Quiz',
        'description': 'Test your knowledge of literature',
        'questions': 10,
        'type': 'literature',
        'subjects': ['Literature in English'],
      },
      {
        'title': 'Economic Principles Quiz',
        'description': 'Test your understanding of economic concepts',
        'questions': 12,
        'type': 'economic_principles',
        'subjects': ['Economics'],
      },
      {
        'title': 'Government Systems Quiz',
        'description': 'Test your knowledge of political systems',
        'questions': 15,
        'type': 'government_systems',
        'subjects': ['Government'],
      },
      {
        'title': 'Geography Quiz',
        'description': 'Test your geographical knowledge',
        'questions': 10,
        'type': 'geography',
        'subjects': ['Geography'],
      },
      {
        'title': 'Religious Studies Quiz',
        'description': 'Test your understanding of religious concepts',
        'questions': 12,
        'type': 'religious_studies',
        'subjects': [
          'Christian Religious Studies (CRS)',
          'Islamic Religious Studies (IRS)',
        ],
      },
      {
        'title': 'Business Concepts Quiz',
        'description': 'Test your knowledge of business and commerce',
        'questions': 15,
        'type': 'business_concepts',
        'subjects': ['Commerce'],
      },
    ];

    return allQuizzes
        .where(
          (quiz) =>
              (quiz['subjects'] as List<dynamic>?)?.contains(fullSubjectName) ??
              false,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subject} Course Content'),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Progress',
            onPressed: _resetProgress,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Syllabi'),
            Tab(text: 'Quizzes'),
          ],
          indicatorColor: AppColors.accentAmber,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Syllabi Tab
                _topics.isEmpty
                    ? const Center(
                        child: Text(
                          'No syllabi available for this subject.',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _topics.length,
                        itemBuilder: (context, i) {
                          final topic = _topics[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.dominantPurple
                                    .withValues(alpha: 0.1),
                                child: Icon(
                                  Icons.link,
                                  color: AppColors.dominantPurple,
                                ),
                              ),
                              title: Text(
                                topic['title'] ?? 'Untitled Topic',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  topic['description'] ??
                                      'Click to access content',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.open_in_new,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                ],
                              ),
                              onTap: () {
                                final url = topic['url'];
                                if (url != null && url.toString().isNotEmpty) {
                                  _openWebLink(url.toString());
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'No URL available for this topic',
                                      ),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
                // Quizzes Tab
                _buildQuizzesTab(),
              ],
            ),
    );
  }
}
