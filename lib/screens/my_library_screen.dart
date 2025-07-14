import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MyLibraryScreen extends StatefulWidget {
  const MyLibraryScreen({Key? key}) : super(key: key);

  @override
  State<MyLibraryScreen> createState() => _MyLibraryScreenState();
}

class _MyLibraryScreenState extends State<MyLibraryScreen> {
  final List<String> _pdfs = [];
  final List<String> _notes = [];
  final List<String> _links = [];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Library'),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
      ),
      backgroundColor: isDark
          ? const Color(0xFF181A20)
          : AppColors.backgroundPrimary,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // PDFs
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PDFs',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              IconButton(
                icon: const Icon(
                  Icons.upload_file,
                  color: AppColors.dominantPurple,
                ),
                onPressed: () {
                  // TODO: Implement PDF upload
                },
              ),
            ],
          ),
          if (_pdfs.isEmpty)
            const Text(
              'No PDFs uploaded yet.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ..._pdfs.map(
            (pdf) => ListTile(
              leading: const Icon(
                Icons.picture_as_pdf,
                color: AppColors.accentAmber,
              ),
              title: Text(pdf),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: AppColors.errorRed),
                onPressed: () {},
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Notes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Notes',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              IconButton(
                icon: const Icon(
                  Icons.note_add,
                  color: AppColors.dominantPurple,
                ),
                onPressed: () {
                  // TODO: Implement add note
                },
              ),
            ],
          ),
          if (_notes.isEmpty)
            const Text(
              'No notes yet.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ..._notes.map(
            (note) => ListTile(
              leading: const Icon(
                Icons.sticky_note_2,
                color: AppColors.secondaryGray,
              ),
              title: Text(note),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: AppColors.errorRed),
                onPressed: () {},
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Links
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Links',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              IconButton(
                icon: const Icon(Icons.link, color: AppColors.dominantPurple),
                onPressed: () {
                  // TODO: Implement add link
                },
              ),
            ],
          ),
          if (_links.isEmpty)
            const Text(
              'No links saved yet.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ..._links.map(
            (link) => ListTile(
              leading: const Icon(Icons.link, color: AppColors.accentAmber),
              title: Text(link),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: AppColors.errorRed),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}
