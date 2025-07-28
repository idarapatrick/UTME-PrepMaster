import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

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

  static const List<String> _tabs = [
    'syllabus',
    'videos',
    'articles',
    'resources',
  ];

  @override
  void initState() {
    super.initState();
    int initialIndex = 0;
    if (widget.initialTab != null) {
      final idx = _tabs.indexOf(widget.initialTab!.toLowerCase());
      if (idx != -1) initialIndex = idx;
    }
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: initialIndex,
    );
    _loadTopics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTopics() async {
    // For demo, generate 10 topics per subject
    _topics = List.generate(
      10,
      (i) => {
        'id': '${widget.subject}_topic_$i',
        'title': '${widget.subject} Topic ${i + 1}',
      },
    );
    // Simulate loading progress from Firestore (not implemented in detail)
    // final user = FirebaseAuth.instance.currentUser;
    // if (user != null) {
    //   // You can extend this to load per-topic progress from Firestore
    //   // For now, mark all as not completed
    //   _completed = {for (var t in _topics) t['id']: false};
    // }
    setState(() => _loading = false);
  }

  void _toggleTopic(String topicId) {
    setState(() {
      _completed[topicId] = !(_completed[topicId] ?? false);
    });
  }

  void _resetProgress() {
    setState(() {
      _completed = {for (var t in _topics) t['id']: false};
    });
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
            Tab(text: 'Syllabus'),
            Tab(text: 'Videos'),
            Tab(text: 'Articles'),
            Tab(text: 'Resources'),
          ],
          indicatorColor: AppColors.accentAmber,
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Syllabus Tab
                _topics.isEmpty
                    ? const Center(child: Text('Not started yet.'))
                    : ListView.builder(
                        itemCount: _topics.length,
                        itemBuilder: (context, i) {
                          final t = _topics[i];
                          final done = _completed[t['id']] ?? false;
                          return ListTile(
                            leading: Icon(
                              done
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: done
                                  ? AppColors.accentAmber
                                  : AppColors.borderLight,
                            ),
                            title: Text(t['title']),
                            trailing: IconButton(
                              icon: Icon(done ? Icons.undo : Icons.check),
                              onPressed: () => _toggleTopic(t['id']),
                            ),
                          );
                        },
                      ),
                // Videos Tab
                const Center(child: Text('Videos coming soon!')),
                // Articles Tab
                const Center(child: Text('Articles coming soon!')),
                // Resources Tab
                const Center(child: Text('Resources coming soon!')),
              ],
            ),
    );
  }
}
