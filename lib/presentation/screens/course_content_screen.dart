import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import 'quiz_screen.dart';
import '../../data/course_content_data.dart';

class CourseContentScreen extends StatefulWidget {
  final String subject;
  final String? initialTab;
  const CourseContentScreen({super.key, required this.subject, this.initialTab});

  @override
  State<CourseContentScreen> createState() => _CourseContentScreenState();
}

class _CourseContentScreenState extends State<CourseContentScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _topics = [];
  Map<String, bool> _completed = {};
  bool _loading = true;
  late TabController _tabController;
  int _selectedIndex = 0;

  static const List<String> _tabs = [
    'syllabi',
    'quizzes',
  ];

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

  Future<void> _loadTopics() async {
    // Load syllabi from course content data
    final subjectData = courseContentData[widget.subject];
    if (subjectData != null && subjectData['syllabi'] != null) {
      _topics = List<Map<String, dynamic>>.from(subjectData['syllabi']);
    } else {
      _topics = [];
    }
    
    setState(() => _loading = false);
  }

  Future<void> _openWebLink(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open link: $url'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening link: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _resetProgress() {
    setState(() {
      _completed = {for (var t in _topics) t['id']: false};
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
              backgroundColor: AppColors.dominantPurple.withOpacity(0.1),
              child: Icon(
                Icons.quiz,
                color: AppColors.dominantPurple,
              ),
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
        'subjects': ['English'],
      },
      {
        'title': 'Comprehension Quiz',
        'description': 'Test your reading comprehension',
        'questions': 15,
        'type': 'comprehension',
        'subjects': ['English'],
      },
      {
        'title': 'Literature Quiz',
        'description': 'Test your knowledge of literature',
        'questions': 10,
        'type': 'literature',
        'subjects': ['English'],
      },
    ];

    return allQuizzes.where((quiz) => (quiz['subjects'] as List<dynamic>?)?.contains(subject) ?? false).toList();
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
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Syllabi Tab
                _topics.isEmpty
                    ? const Center(child: Text('No syllabi available for this subject.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _topics.length,
                        itemBuilder: (context, i) {
                          final topic = _topics[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.dominantPurple.withOpacity(0.1),
                                child: Icon(
                                  Icons.link,
                                  color: AppColors.dominantPurple,
                                ),
                              ),
                              title: Text(
                                topic['title'],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                topic['description'] ?? 'Click to access content',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
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
                                print('Opening URL: ${topic['url']}');
                                _openWebLink(topic['url']);
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