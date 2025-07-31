import 'package:flutter/material.dart';
import '../../../data/course_content_data.dart';

class ProgressTrackingScreen extends StatelessWidget {
  const ProgressTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subjects = courseContentData.keys.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Progress Tracking')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.separated(
          itemCount: subjects.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final subject = subjects[index];
            final progress =
                (courseContentData[subject]['progress'] ?? 0.0) as double;

            return Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.grey[300],
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(height: 6),
                    Text('${(progress * 100).toStringAsFixed(0)}% completed'),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
