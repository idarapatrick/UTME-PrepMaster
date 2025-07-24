import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'dart:typed_data';
import '../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyLibraryScreen extends StatefulWidget {
  const MyLibraryScreen({super.key});

  @override
  State<MyLibraryScreen> createState() => _MyLibraryScreenState();
}

class _MyLibraryScreenState extends State<MyLibraryScreen> {
  final List<String> _pdfs = [];
  final List<String> _notes = [];
  final List<String> _links = [];
  final List<Map<String, dynamic>> _pdfDocs = [];
  final List<Map<String, dynamic>> _noteDocs = [];
  final List<Map<String, dynamic>> _linkDocs = [];

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
        _pdfDocs.clear();
        _pdfs.addAll(pdfsSnap.docs.map((d) => d['fileName'] as String));
        _pdfDocs.addAll(pdfsSnap.docs.map((d) => {'id': d.id, ...d.data()}));
        _notes.clear();
        _noteDocs.clear();
        _notes.addAll(notesSnap.docs.map((d) => d['note'] as String));
        _noteDocs.addAll(notesSnap.docs.map((d) => {'id': d.id, ...d.data()}));
        _links.clear();
        _linkDocs.clear();
        _links.addAll(linksSnap.docs.map((d) => d['link'] as String));
        _linkDocs.addAll(linksSnap.docs.map((d) => {'id': d.id, ...d.data()}));
      });
    }
  }

  // Remove _uploadPdf and PDF upload logic

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
    if (note.trim().isNotEmpty) {
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
    if (link.trim().isNotEmpty) {
      await FirestoreService.saveLink(user.uid, link.trim());
      _loadLibrary();
    }
  }

  Future<void> _deletePdf(String docId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete PDF'),
        content: const Text('Are you sure you want to delete this PDF?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('library_pdfs')
          .doc(docId)
          .get();
      final data = doc.data();
      await doc.reference.delete();
      _loadLibrary();
      if (data != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('PDF deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('library_pdfs')
                    .doc(docId)
                    .set(data);
                _loadLibrary();
              },
            ),
          ),
        );
      }
    }
  }

  Future<void> _deleteNote(String docId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('library_notes')
          .doc(docId)
          .get();
      final data = doc.data();
      await doc.reference.delete();
      _loadLibrary();
      if (data != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Note deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('library_notes')
                    .doc(docId)
                    .set(data);
                _loadLibrary();
              },
            ),
          ),
        );
      }
    }
  }

  Future<void> _editNote(String docId, String currentNote) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    String? note = await showDialog<String>(
      context: context,
      builder: (context) {
        String temp = currentNote;
        return AlertDialog(
          title: const Text('Edit Note'),
          content: TextField(
            autofocus: true,
            controller: TextEditingController(text: currentNote),
            onChanged: (v) => temp = v,
            decoration: const InputDecoration(hintText: 'Edit note...'),
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
    if (note.trim().isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('library_notes')
          .doc(docId)
          .update({'note': note.trim()});
      _loadLibrary();
    }
  }

  Future<void> _deleteLink(String docId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Link'),
        content: const Text('Are you sure you want to delete this link?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('library_links')
          .doc(docId)
          .get();
      final data = doc.data();
      await doc.reference.delete();
      _loadLibrary();
      if (data != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Link deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('library_links')
                    .doc(docId)
                    .set(data);
                _loadLibrary();
              },
            ),
          ),
        );
      }
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
            ],
          ),
          const Text(
            'PDF upload is not supported in this build.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          if (_pdfs.isEmpty)
            const Text(
              'No PDFs uploaded yet.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ..._pdfDocs.map(
            (pdf) => ListTile(
              leading: const Icon(
                Icons.picture_as_pdf,
                color: AppColors.accentAmber,
              ),
              title: Text(pdf['fileName']),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: AppColors.errorRed),
                onPressed: () => _deletePdf(pdf['id']),
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
          ..._noteDocs.map(
            (note) => ListTile(
              leading: const Icon(
                Icons.sticky_note_2,
                color: AppColors.secondaryGray,
              ),
              title: Text(note['note']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.edit,
                      color: AppColors.dominantPurple,
                    ),
                    onPressed: () => _editNote(note['id'], note['note']),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.errorRed),
                    onPressed: () => _deleteNote(note['id']),
                  ),
                ],
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
          ..._linkDocs.map(
            (link) => ListTile(
              leading: const Icon(Icons.link, color: AppColors.accentAmber),
              title: Text(link['link']),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: AppColors.errorRed),
                onPressed: () => _deleteLink(link['id']),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
