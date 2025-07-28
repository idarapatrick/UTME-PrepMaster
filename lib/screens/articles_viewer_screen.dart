import 'package:flutter/material.dart';

class ArticleViewerScreen extends StatelessWidget {
  final String title;
  final String content;

  const ArticleViewerScreen({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(
            content,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ),
      ),
    );
  }
}
