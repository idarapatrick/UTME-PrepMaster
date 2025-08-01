import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'pdf_viewer_screen.dart';
import 'notes_screen.dart';
import 'links_screen.dart';

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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.edit, color: AppColors.dominantPurple),
              const SizedBox(width: 8),
              const Text('Edit Note'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                controller: TextEditingController(text: currentNote),
                onChanged: (v) => temp = v,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Write your study note...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.dominantPurple),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, temp),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dominantPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (note != null && note.trim().isNotEmpty) {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Library'),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: AppColors.getBackgroundPrimary(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with stats
            _buildHeader(context),
            const SizedBox(height: 24),

            // PDFs Section
            _buildPdfSection(context),
            const SizedBox(height: 24),

            // Notes Section
            _buildNotesSection(context),
            const SizedBox(height: 24),

            // Links Section
            _buildLinksSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.dominantPurple,
            AppColors.dominantPurple.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.library_books, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Library',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_pdfDocs.length} PDFs • ${_noteDocs.length} Notes • ${_linkDocs.length} Links',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Literature PDFs',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.getTextPrimary(context),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.dominantPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'UTME 2025',
                style: TextStyle(
                  color: AppColors.dominantPurple,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Default UTME Literature PDF
        Card(
          color: AppColors.getCardColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accentAmber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.picture_as_pdf,
                color: AppColors.accentAmber,
                size: 24,
              ),
            ),
            title: Text(
              'Last Days at Forcados High School',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.getTextPrimary(context),
              ),
            ),
            subtitle: Text(
              'UTME 2025 Literature Text',
              style: TextStyle(
                color: AppColors.getTextSecondary(context),
                fontSize: 12,
              ),
            ),
            trailing: IconButton(
              icon: Icon(Icons.download, color: AppColors.dominantPurple),
              onPressed: () {
                _openPdf('assets/pdfs/last_days_at_forcados_high_school.pdf');
              },
            ),
          ),
        ),

        if (_pdfDocs.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Additional PDFs',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          ..._pdfDocs.map(
            (pdf) => Card(
              color: AppColors.getCardColor(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accentAmber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.picture_as_pdf,
                    color: AppColors.accentAmber,
                    size: 24,
                  ),
                ),
                title: Text(
                  pdf['fileName'],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextPrimary(context),
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: AppColors.errorRed),
                  onPressed: () => _deletePdf(pdf['id']),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNotesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Study Notes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.getTextPrimary(context),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotesScreen()),
                );
              },
              child: Text(
                'View All',
                style: TextStyle(
                  color: AppColors.dominantPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (_noteDocs.isEmpty)
          _buildNotesCard(context)
        else
          Column(
            children: [
              // Show only first 2 notes as preview
              ..._noteDocs.take(2).map((note) => _buildNoteCard(context, note)),
              if (_noteDocs.length > 2)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotesScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'View ${_noteDocs.length - 2} more notes',
                        style: TextStyle(
                          color: AppColors.dominantPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildNotesCard(BuildContext context) {
    return Card(
      color: AppColors.getCardColor(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotesScreen()),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.note_add,
                size: 48,
                color: AppColors.getTextSecondary(context),
              ),
              const SizedBox(height: 16),
              Text(
                'No Notes Yet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start taking notes to keep track of important information',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.getTextSecondary(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, Map<String, dynamic> note) {
    final noteText = note['note'] as String;
    final timestamp = note['timestamp'] as Timestamp?;
    final timeString = timestamp != null
        ? _formatTime(timestamp.toDate())
        : 'Now';

    // Generate a color based on note content with better contrast
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = [
      isDark ? Colors.amber.shade700 : Colors.amber.shade100,
      isDark ? Colors.green.shade700 : Colors.green.shade100,
      isDark ? Colors.blue.shade700 : Colors.blue.shade100,
      isDark ? Colors.purple.shade700 : Colors.purple.shade100,
      isDark ? Colors.orange.shade700 : Colors.orange.shade100,
      isDark ? Colors.pink.shade700 : Colors.pink.shade100,
    ];
    final colorIndex = noteText.length % colors.length;
    final cardColor = colors[colorIndex];

    // Determine text color based on background luminance
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final secondaryTextColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _editNote(note['id'], note['note']),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.sticky_note_2, color: textColor, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      timeString,
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: secondaryTextColor,
                      size: 18,
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editNote(note['id'], note['note']);
                      } else if (value == 'delete') {
                        _deleteNote(note['id']);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit,
                              size: 16,
                              color: AppColors.getTextPrimary(context),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Edit',
                              style: TextStyle(
                                color: AppColors.getTextPrimary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete,
                              size: 16,
                              color: AppColors.errorRed,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Delete',
                              style: TextStyle(color: AppColors.errorRed),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Text(
                  noteText,
                  style: TextStyle(color: textColor, fontSize: 14, height: 1.4),
                  maxLines: 8,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLinksSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Study Links',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.getTextPrimary(context),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LinksScreen()),
                );
              },
              child: Text(
                'View All',
                style: TextStyle(
                  color: AppColors.dominantPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (_linkDocs.isEmpty)
          _buildLinksCard(context)
        else
          Column(
            children: [
              // Show only first 2 links as preview
              ..._linkDocs.take(2).map((link) => _buildLinkRow(context, link)),
              if (_linkDocs.length > 2)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LinksScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'View ${_linkDocs.length - 2} more links',
                        style: TextStyle(
                          color: AppColors.dominantPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildLinksCard(BuildContext context) {
    return Card(
      color: AppColors.getCardColor(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LinksScreen()),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.link,
                size: 48,
                color: AppColors.getTextSecondary(context),
              ),
              const SizedBox(height: 16),
              Text(
                'No Links Yet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Save important study resources and links here',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.getTextSecondary(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLinkRow(BuildContext context, Map<String, dynamic> link) {
    final title = link['title'] ?? 'Untitled';
    final url = link['link'] ?? '';
    final description = link['description'] ?? '';
    final domain = _extractDomain(url);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.getBorderLight(context)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextPrimary(context),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: InkWell(
                onTap: () => _openLink(url),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.dominantPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.dominantPurple.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    domain,
                    style: TextStyle(
                      color: AppColors.dominantPurple,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                description,
                style: TextStyle(
                  color: AppColors.getTextSecondary(context),
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: AppColors.getTextSecondary(context),
                size: 18,
              ),
              onSelected: (value) {
                if (value == 'edit') {
                  _editLink(link['id'], link);
                } else if (value == 'delete') {
                  _deleteLink(link['id']);
                } else if (value == 'open') {
                  _openLink(url);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'open',
                  child: Row(
                    children: [
                      Icon(
                        Icons.open_in_new,
                        size: 16,
                        color: AppColors.getTextPrimary(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Open',
                        style: TextStyle(
                          color: AppColors.getTextPrimary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit,
                        size: 16,
                        color: AppColors.getTextPrimary(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Edit',
                        style: TextStyle(
                          color: AppColors.getTextPrimary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 16, color: AppColors.errorRed),
                      const SizedBox(width: 8),
                      Text(
                        'Delete',
                        style: TextStyle(color: AppColors.errorRed),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getBorderLight(context), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: AppColors.getTextSecondary(context)),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.getTextSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  String _extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceAll('www.', '');
    } catch (e) {
      return url.length > 30 ? '${url.substring(0, 30)}...' : url;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open: $url')));
    }
  }

  Future<void> _editLink(String docId, Map<String, dynamic> currentLink) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    Map<String, String>? result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        String title = currentLink['title'] ?? '';
        String link = currentLink['link'] ?? '';
        String description = currentLink['description'] ?? '';

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.edit, color: AppColors.dominantPurple),
              const SizedBox(width: 8),
              const Text('Edit Link'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                controller: TextEditingController(text: title),
                onChanged: (v) => title = v,
                decoration: InputDecoration(
                  hintText: 'Link title...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.dominantPurple),
                  ),
                  prefixIcon: Icon(Icons.title, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: TextEditingController(text: link),
                onChanged: (v) => link = v,
                decoration: InputDecoration(
                  hintText: 'Paste study resource link...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.dominantPurple),
                  ),
                  prefixIcon: Icon(Icons.link, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: TextEditingController(text: description),
                onChanged: (v) => description = v,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Link description...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.dominantPurple),
                  ),
                  prefixIcon: Icon(
                    Icons.description,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, {
                'title': title,
                'link': link,
                'description': description,
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dominantPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != null && result['link']?.trim().isNotEmpty == true) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('library_links')
          .doc(docId)
          .update({
            'title': result['title']?.trim() ?? 'Untitled',
            'link': result['link']?.trim() ?? '',
            'description': result['description']?.trim() ?? '',
          });
      _loadLibrary();
    }
  }

  Future<void> _openPdf(String assetPath) async {
    try {
      print('Opening PDF with path: $assetPath'); // Debug print
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerScreen(
            pdfPath: assetPath,
            title: 'Last Days at Forcados High School',
          ),
        ),
      );
    } catch (e) {
      print('Error in _openPdf: $e'); // Debug print
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error opening PDF: $e')));
    }
  }
}
