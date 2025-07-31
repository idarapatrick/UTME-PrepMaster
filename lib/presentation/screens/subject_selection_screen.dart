import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/services/firestore_service.dart';
import '../theme/app_colors.dart';
import '../widgets/subject_card.dart';

const List<Map<String, dynamic>> utmeSubjects = [
  {
    'name': 'English',
    'icon': Icons.language,
    'color': Colors.red, // Non-science
  },
  {
    'name': 'Mathematics',
    'icon': Icons.calculate,
    'color': Colors.blue, // Science
  },
  {'name': 'Physics', 'icon': Icons.science, 'color': Colors.blue},
  {'name': 'Chemistry', 'icon': Icons.bubble_chart, 'color': Colors.blue},
  {'name': 'Biology', 'icon': Icons.biotech, 'color': Colors.blue},
  {'name': 'Government', 'icon': Icons.account_balance, 'color': Colors.red},
  {'name': 'Economics', 'icon': Icons.trending_up, 'color': Colors.red},
  {'name': 'Geography', 'icon': Icons.public, 'color': Colors.red},
  {
    'name': 'Christian Religious Studies',
    'icon': Icons.church,
    'color': Colors.red,
  },
  {'name': 'Islamic Studies', 'icon': Icons.mosque, 'color': Colors.red},
  {'name': 'Commerce', 'icon': Icons.store, 'color': Colors.red},
];

class SubjectSelectionScreen extends StatefulWidget {
  final bool isForMockTest;
  const SubjectSelectionScreen({super.key, this.isForMockTest = false});

  @override
  State<SubjectSelectionScreen> createState() => _SubjectSelectionScreenState();
}

class _SubjectSelectionScreenState extends State<SubjectSelectionScreen> {
  List<String> _selectedSubjects = ['English'];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadUserSubjects();
  }

  Future<void> _loadUserSubjects() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final subjects = await FirestoreService.loadUserSubjects(user.uid);
      setState(() {
        _selectedSubjects = subjects.isNotEmpty ? subjects : ['English'];
      });
    }
  }

  void _onSubjectTap(String subject) {
    setState(() {
      if (_selectedSubjects.contains(subject)) {
        if (subject != 'English') {
          _selectedSubjects.remove(subject);
        }
      } else {
        if (_selectedSubjects.length < 4) {
          _selectedSubjects.add(subject);
        }
      }
    });
  }

  Future<void> _saveSubjects() async {
    setState(() => _loading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (widget.isForMockTest) {
      // For mock test/quiz, just return the selected subjects
      if (mounted) Navigator.pop(context, _selectedSubjects);
    } else {
      if (user != null) {
        try {
          await FirestoreService.saveUserSubjects(user.uid, _selectedSubjects);
          if (mounted) Navigator.pop(context);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error saving subjects: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select UTME Subjects'),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose up to 4 subjects (English is required):',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 3.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                padding: const EdgeInsets.only(bottom: 8),
                children: utmeSubjects.map((subject) {
                  final name = subject['name'] as String;
                  final icon = subject['icon'] as IconData;
                  final color = subject['color'] as Color;
                  final selected = _selectedSubjects.contains(name);
                  return SubjectCard(
                    name: name,
                    icon: icon,
                    imageUrl: '', // No image in selection, or use a placeholder
                    accentColor: color,
                    progressText: selected ? 'Selected' : null,
                    onTap: () => _onSubjectTap(name),
                    trailing: selected
                        ? const Icon(
                            Icons.check_circle,
                            color: AppColors.dominantPurple,
                            size: 16,
                          )
                        : null,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedSubjects.length == 4 && !_loading
                    ? _saveSubjects
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dominantPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save Subjects'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
