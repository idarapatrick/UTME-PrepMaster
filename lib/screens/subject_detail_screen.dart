import 'package:flutter/material.dart';
import '../../data/course_content_data.dart';

class SubjectDetailScreen extends StatefulWidget {
  final String subject;

  const SubjectDetailScreen({super.key, required this.subject});

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subjectContent = courseContentData[widget.subject];

    if (subjectContent == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.subject)),
        body: const Center(child: Text("No content available.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.subject,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Videos'),
            Tab(text: 'Articles'),
            Tab(text: 'Progress'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Videos Tab
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: subjectContent['videos'].length,
            itemBuilder: (context, index) {
              final video = subjectContent['videos'][index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  leading: const Icon(
                    Icons.play_circle_fill,
                    size: 30,
                    color: Colors.deepPurple,
                  ),
                  title: Text(
                    video['title'],
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('Duration: ${video['duration']}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/video-player',
                      arguments: {'title': video['title'], 'url': video['url']},
                    );
                  },
                ),
              );
            },
          ),

          // Articles Tab
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: subjectContent['articles'].length,
            itemBuilder: (context, index) {
              final article = subjectContent['articles'][index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  leading: const Icon(
                    Icons.article_outlined,
                    size: 30,
                    color: Colors.deepPurple,
                  ),
                  title: Text(
                    article['title'],
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/article-viewer',
                      arguments: {
                        'title': article['title'],
                        'content': article['content'],
                      },
                    );
                  },
                ),
              );
            },
          ),

          // Progress Tab
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Your Learning Progress',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                LinearProgressIndicator(
                  value: subjectContent['progress'],
                  minHeight: 14,
                  borderRadius: BorderRadius.circular(10),
                  backgroundColor: Colors.deepPurple[100],
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 16),
                Text(
                  '${(subjectContent['progress'] * 100).toStringAsFixed(0)}% Completed',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
