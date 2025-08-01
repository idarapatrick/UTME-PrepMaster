import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';

class LinksScreen extends StatefulWidget {
  const LinksScreen({super.key});

  @override
  State<LinksScreen> createState() => _LinksScreenState();
}

class _LinksScreenState extends State<LinksScreen> {
  List<Map<String, dynamic>> _links = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLinks();
  }

  Future<void> _loadLinks() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final linksSnap = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('library_links')
            .orderBy('createdAt', descending: true)
            .get();

        setState(() {
          _links = linksSnap.docs
              .map((d) => {'id': d.id, ...d.data()})
              .toList();
          _isLoading = false;
        });

        // Add sample links if no links exist
        if (_links.isEmpty) {
          await _addSampleLinks();
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      // Handle error gracefully
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading links: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      // Add sample links on error
      await _addSampleLinks();
    }
  }

  Future<void> _addSampleLinks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final sampleLinks = [
      {
        'title': 'JAMB Official Website',
        'link': 'https://www.jamb.gov.ng',
        'description': 'Official JAMB website for registration and information',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Khan Academy',
        'link': 'https://www.khanacademy.org',
        'description': 'Free educational resources for all subjects',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Coursera',
        'link': 'https://www.coursera.org',
        'description': 'Online courses from top universities',
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    try {
      final batch = FirebaseFirestore.instance.batch();
      for (final link in sampleLinks) {
        final docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('library_links')
            .doc();
        batch.set(docRef, link);
      }
      await batch.commit();

      // Reload links
      await _loadLinks();
    } catch (e) {
      // Error adding sample links
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding sample links: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _addLink() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    Map<String, String>? result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        String title = '';
        String link = '';
        String description = '';

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.link, color: AppColors.dominantPurple),
              const SizedBox(width: 8),
              const Text('Add Study Link'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
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
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('library_links')
            .add({
              'title': result['title']?.trim() ?? 'Untitled',
              'link': result['link']?.trim() ?? '',
              'description': result['description']?.trim() ?? '',
              'createdAt': FieldValue.serverTimestamp(),
            });
        await _loadLinks();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Link added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding link: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
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
      try {
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
        await _loadLinks();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Link updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating link: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('library_links')
            .doc(docId)
            .delete();
        await _loadLinks();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Link deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting link: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _openLink(String url) async {
    try {
      
      final uri = Uri.parse(url);
      final canLaunch = await canLaunchUrl(uri);
      

      if (canLaunch) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );

        

        if (!launched) {

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to open: $url'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } else {

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open: $url'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening link: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceAll('www.', '');
    } catch (e) {
      return url.length > 30 ? '${url.substring(0, 30)}...' : url;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Links'),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: AppColors.getBackgroundPrimary(context),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header with stats
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.all(16),
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
                      Icon(Icons.link, color: Colors.white, size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Study Links',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              '${_links.length} Links',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Links table
                Expanded(
                  child: _links.isEmpty
                      ? _buildEmptyState(context, isDark)
                      : _buildLinksTable(context, isDark),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addLink,
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLinksTable(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getBorderLight(context)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.dominantPurple.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Title',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.dominantPurple,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Link',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.dominantPurple,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Description',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.dominantPurple,
                    ),
                  ),
                ),
                const SizedBox(width: 40), // Space for actions
              ],
            ),
          ),
          // Rows
          Expanded(
            child: ListView.builder(
              itemCount: _links.length,
              itemBuilder: (context, index) {
                final link = _links[index];
                return _buildLinkRow(context, isDark, link);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkRow(
    BuildContext context,
    bool isDark,
    Map<String, dynamic> link,
  ) {
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
                  decoration: BoxDecoration(
                    color: AppColors.dominantPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.dominantPurple.withValues(alpha: 0.3),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
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

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.link,
            size: 80,
            color: AppColors.getTextSecondary(context),
          ),
          const SizedBox(height: 24),
          Text(
            'No Links Yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Save important study resources and links here',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.getTextSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}
