import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/services/cbt_question_service.dart';
import '../../theme/app_colors.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic> _questionStats = {};
  List<String> _availableSubjects = [];
  bool _isLoading = true;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadData();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _userRole = userDoc.data()?['role'] ?? 'user';
          });
        }
      }
    } catch (e) {
      // Error checking user role
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final stats = await CbtQuestionService.getQuestionStats();
      final subjects = await CbtQuestionService.getAvailableSubjects();

      setState(() {
        _questionStats = stats;
        _availableSubjects = subjects;
        _isLoading = false;
      });
    } catch (e) {
      // Error loading admin dashboard data
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          IconButton(icon: const Icon(Icons.logout), onPressed: _signOut),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.dominantPurple,
                                child: const Icon(
                                  Icons.admin_panel_settings,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome, Admin!',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    Text(
                                      'Role: ${_userRole ?? 'Unknown'}',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Quick Stats
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'System Overview',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          _buildQuickStats(),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Quick Actions
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Actions',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          _buildQuickActions(),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Subject Management
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Question Management',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          _buildSubjectManagement(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildQuickStats() {
    int totalQuestions = 0;
    int verifiedQuestions = 0;
    int pendingQuestions = 0;

    for (final stats in _questionStats.values) {
      totalQuestions += (stats['total'] ?? 0) as int;
      verifiedQuestions += (stats['verified'] ?? 0) as int;
      pendingQuestions += (stats['pending'] ?? 0) as int;
    }

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Questions',
            totalQuestions.toString(),
            Icons.question_answer,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Verified',
            verifiedQuestions.toString(),
            Icons.verified,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Pending',
            pendingQuestions.toString(),
            Icons.pending,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(
            Icons.upload_file,
            color: AppColors.dominantPurple,
          ),
          title: const Text('Upload Questions'),
          subtitle: const Text('Upload new CBT questions from PDF'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            Navigator.pushNamed(context, '/admin/upload-questions');
          },
        ),
        ListTile(
          leading: const Icon(Icons.verified, color: Colors.green),
          title: const Text('Verify Questions'),
          subtitle: const Text('Review and verify pending questions'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            _showVerifyQuestionsDialog();
          },
        ),
        ListTile(
          leading: const Icon(Icons.analytics, color: Colors.blue),
          title: const Text('View Analytics'),
          subtitle: const Text('Detailed question and user analytics'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            _showAnalyticsDialog();
          },
        ),
        ListTile(
          leading: const Icon(Icons.settings, color: Colors.orange),
          title: const Text('System Settings'),
          subtitle: const Text('Configure CBT test settings'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            _showSettingsDialog();
          },
        ),
      ],
    );
  }

  Widget _buildSubjectManagement() {
    if (_availableSubjects.isEmpty) {
      return const Center(child: Text('No subjects available'));
    }

    return Column(
      children: _availableSubjects.map((subject) {
        final stats = _questionStats[subject] ?? {};
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.dominantPurple,
              child: Text(
                subject[0],
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(subject),
            subtitle: Text(
              '${stats['verified'] ?? 0} verified / ${stats['total'] ?? 0} total questions',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editSubject(subject),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteSubject(subject),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showVerifyQuestionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verify Questions'),
        content: const Text(
          'This feature will be implemented to review and verify pending questions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAnalyticsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Analytics'),
        content: const Text(
          'View detailed analytics about question usage and performance.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('System Settings'),
        content: const Text(
          'Configure CBT test settings and system parameters.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _editSubject(String subject) {
    Navigator.pushNamed(context, '/admin/upload-questions');
  }

  void _deleteSubject(String subject) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete $subject'),
        content: Text(
          'Are you sure you want to delete all questions for $subject? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$subject questions deleted')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      // Sign out from Firebase Auth
      await FirebaseAuth.instance.signOut();

      // Clear all session data from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Navigate to admin auth screen
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/admin/auth',
          (route) => false, // Remove all previous routes from the stack
        );
      }
    } catch (e) {
      // Error signing out
      // Even if there's an error, try to navigate to admin auth
      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/admin/auth', (route) => false);
      }
    }
  }
}
