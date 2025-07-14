import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  void initState() {
    super.initState();
    _loadLibrary();
  }

  Future<void> _loadLibrary() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final pdfsSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('library_pdfs')
          .get();
      final notesSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('library_notes')
          .get();
      final linksSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('library_links')
          .get();
      setState(() {
        _pdfs.clear();
        _pdfs.addAll(pdfsSnap.docs.map((d) => d['fileName'] as String));
        _notes.clear();
        _notes.addAll(notesSnap.docs.map((d) => d['note'] as String));
        _links.clear();
        _links.addAll(linksSnap.docs.map((d) => d['link'] as String));
      });
    }
  }

  Future<void> _uploadPdf() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.bytes != null) {
      final file = result.files.single;
      final url = await FirestoreService.uploadFile(
        user.uid,
        'pdfs',
        file.name,
        file.bytes!,
      );
      await FirestoreService.savePdf(user.uid, file.name, url);
      _loadLibrary();
    }
  }

  Future<void> _addNote() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    String? note = await showDialog<String>(
      context: context,
      builder: (context) {
        String temp = '';
        return AlertDialog(
          title: const Text('Add Note'),
          content: TextField(
            autofocus: true,
            onChanged: (v) => temp = v,
            decoration: const InputDecoration(hintText: 'Enter note...'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, temp),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (note != null && note.trim().isNotEmpty) {
      await FirestoreService.saveNote(user.uid, note.trim());
      _loadLibrary();
    }
  }

  Future<void> _addLink() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    String? link = await showDialog<String>(
      context: context,
      builder: (context) {
        String temp = '';
        return AlertDialog(
          title: const Text('Add Link'),
          content: TextField(
            autofocus: true,
            onChanged: (v) => temp = v,
            decoration: const InputDecoration(hintText: 'Paste link...'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, temp),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (link != null && link.trim().isNotEmpty) {
      await FirestoreService.saveLink(user.uid, link.trim());
      _loadLibrary();
    }
  }

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
                onPressed: _uploadPdf,
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
                onPressed: _addNote,
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
                onPressed: _addLink,
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
