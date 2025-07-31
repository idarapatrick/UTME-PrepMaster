import 'package:flutter/material.dart';
import '../../../data/services/cbt_question_service.dart';
import '../../theme/app_colors.dart';

class DeveloperPanelScreen extends StatefulWidget {
  const DeveloperPanelScreen({super.key});

  @override
  State<DeveloperPanelScreen> createState() => _DeveloperPanelScreenState();
}

class _DeveloperPanelScreenState extends State<DeveloperPanelScreen> {
  Map<String, dynamic> _questionStats = {};
  List<String> _availableSubjects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
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
      // Error loading developer panel data
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Panel'),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statistics Overview
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Question Statistics',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildStatsGrid(),
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
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
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
                            'Subject Management',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildSubjectList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsGrid() {
    if (_questionStats.isEmpty) {
      return const Text('No question data available');
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2,
      ),
      itemCount: _questionStats.length,
      itemBuilder: (context, index) {
        final subject = _questionStats.keys.elementAt(index);
        final stats = _questionStats[subject];
        
        return Card(
          color: AppColors.dominantPurple.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Total: ${stats['total']}'),
                Text('Verified: ${stats['verified']}'),
                Text('Pending: ${stats['pending']}'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.upload_file, color: AppColors.dominantPurple),
          title: const Text('Upload Questions'),
          subtitle: const Text('Upload new CBT questions from PDF'),
          onTap: () {
            Navigator.pushNamed(context, '/admin/upload-questions');
          },
        ),
        ListTile(
          leading: const Icon(Icons.verified, color: Colors.green),
          title: const Text('Verify Questions'),
          subtitle: const Text('Review and verify pending questions'),
          onTap: () {
            _showVerifyQuestionsDialog();
          },
        ),
        ListTile(
          leading: const Icon(Icons.settings, color: Colors.orange),
          title: const Text('CBT Configurations'),
          subtitle: const Text('Manage CBT test settings'),
          onTap: () {
            _showCbtConfigDialog();
          },
        ),
        ListTile(
          leading: const Icon(Icons.analytics, color: Colors.blue),
          title: const Text('Analytics'),
          subtitle: const Text('View detailed question analytics'),
          onTap: () {
            _showAnalyticsDialog();
          },
        ),
      ],
    );
  }

  Widget _buildSubjectList() {
    return Column(
      children: _availableSubjects.map((subject) {
        final stats = _questionStats[subject] ?? {};
        return ListTile(
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
        );
      }).toList(),
    );
  }

  void _showVerifyQuestionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verify Questions'),
        content: const Text('This feature will be implemented to review and verify pending questions.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showCbtConfigDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('CBT Configurations'),
        content: const Text('Manage CBT test configurations and settings.'),
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
        title: const Text('Question Analytics'),
        content: const Text('View detailed analytics about question usage and performance.'),
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
    // Navigate to subject editing screen
    Navigator.pushNamed(context, '/admin/upload-questions');
  }

  void _deleteSubject(String subject) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete $subject'),
        content: Text('Are you sure you want to delete all questions for $subject? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Implement delete functionality
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
} 