import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../theme/app_colors.dart';
import '../../data/services/firestore_service.dart';
import '../utils/responsive_helper.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<Map<String, dynamic>> _leaderboard = [];
  bool _loading = true;
  String _selectedFilter = 'all'; // 'all', 'this_week', 'this_month'
  StreamSubscription<QuerySnapshot>? _leaderboardSubscription;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
    _setupRealtimeUpdates();
  }

  @override
  void dispose() {
    _leaderboardSubscription?.cancel();
    super.dispose();
  }

  void _setupRealtimeUpdates() {
    print('Setting up real-time updates...'); // Debug print
    // Listen to changes in user documents for real-time updates
    _leaderboardSubscription = FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .listen((snapshot) {
          print(
            'Firestore update detected, refreshing leaderboard...',
          ); // Debug print
          // Refresh leaderboard when data changes
          _loadLeaderboard();
        });
  }

  Future<void> _loadLeaderboard() async {
    print('=== LOADING LEADERBOARD ==='); // Debug print
    print('Filter: $_selectedFilter'); // Debug print

    setState(() {
      _loading = true;
    });

    try {
      final leaderboard = await FirestoreService.getCbtLeaderboard(
        _selectedFilter,
      );
      print('Leaderboard loaded: ${leaderboard.length} entries'); // Debug print
      print('Leaderboard data: $leaderboard'); // Debug print

      setState(() {
        _leaderboard = leaderboard;
        _loading = false;
      });
    } catch (e) {
      print('Error loading leaderboard: $e'); // Debug print
      setState(() {
        _loading = false;
      });
    }
  }

  String _getFilterTitle() {
    switch (_selectedFilter) {
      case 'this_week':
        return 'This Week';
      case 'this_month':
        return 'This Month';
      default:
        return 'All Time';
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber; // Gold
      case 2:
        return Colors.grey[400]!; // Silver
      case 3:
        return Colors.brown[300]!; // Bronze
      default:
        return AppColors.dominantPurple;
    }
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.emoji_events;
      case 2:
        return Icons.emoji_events;
      case 3:
        return Icons.emoji_events;
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF181A20)
          : AppColors.backgroundSecondary,
      appBar: AppBar(
        title: const Text('CBT Leaderboard'),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
        actions: [
          // Test button for debugging
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                // Test leaderboard data functionality removed
                _loadLeaderboard();
              }
            },
            tooltip: 'Test Leaderboard Data',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
              _loadLeaderboard();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Time')),
              const PopupMenuItem(value: 'this_week', child: Text('This Week')),
              const PopupMenuItem(
                value: 'this_month',
                child: Text('This Month'),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_getFilterTitle()),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.dominantPurple,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'Top CBT Scorers',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getFilterTitle(),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // Leaderboard
          Expanded(
            child: _loading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark ? Colors.white : AppColors.dominantPurple,
                      ),
                    ),
                  )
                : _leaderboard.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.leaderboard,
                          size: ResponsiveHelper.getResponsiveIconSize(
                            context,
                            60,
                          ),
                          color: isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.textTertiary,
                        ),
                        SizedBox(
                          height: ResponsiveHelper.getResponsivePadding(
                            context,
                          ),
                        ),
                        Text(
                          'No scores yet',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              18,
                            ),
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(
                          height:
                              ResponsiveHelper.getResponsivePadding(context) /
                              2,
                        ),
                        Text(
                          'Be the first to take a CBT test!',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              14,
                            ),
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _leaderboard.length,
                    itemBuilder: (context, index) {
                      final entry = _leaderboard[index];
                      final rank = index + 1;
                      // Convert score to int, handling both double and int types
                      final score = (entry['score'] is double)
                          ? (entry['score'] as double).toInt()
                          : (entry['score'] as int? ?? 0);
                      final displayName = entry['displayName'] ?? 'Anonymous';
                      final date = entry['date'] != null
                          ? DateTime.parse(entry['date'])
                          : DateTime.now();
                      final isCurrentUser =
                          entry['userId'] ==
                          FirebaseAuth.instance.currentUser?.uid;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: isCurrentUser ? 4 : 2,
                        color: isDark
                            ? (isCurrentUser
                                  ? AppColors.dominantPurple.withValues(
                                      alpha: 0.2,
                                    )
                                  : const Color(0xFF2A2D3E))
                            : (isCurrentUser
                                  ? AppColors.dominantPurple.withValues(
                                      alpha: 0.1,
                                    )
                                  : Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: isCurrentUser
                              ? BorderSide(
                                  color: AppColors.dominantPurple,
                                  width: 2,
                                )
                              : BorderSide.none,
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: _getRankColor(rank).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: _getRankColor(rank),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                _getRankIcon(rank),
                                color: _getRankColor(rank),
                                size: ResponsiveHelper.getResponsiveIconSize(
                                  context,
                                  24,
                                ),
                              ),
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(
                                '#$rank',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _getRankColor(rank),
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                        context,
                                        16,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  displayName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        ResponsiveHelper.getResponsiveFontSize(
                                          context,
                                          16,
                                        ),
                                    color: isCurrentUser
                                        ? AppColors.dominantPurple
                                        : (isDark
                                              ? Colors.white
                                              : AppColors.textPrimary),
                                  ),
                                ),
                              ),
                              if (isCurrentUser)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.dominantPurple,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'YOU (#$rank)',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Text(
                            '${date.day}/${date.month}/${date.year}',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context,
                                12,
                              ),
                            ),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '$score/400',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                        context,
                                        18,
                                      ),
                                  color: _getScoreColor(score),
                                ),
                              ),
                              Text(
                                '${(score / 400.0 * 100.0).toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary,
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                        context,
                                        12,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    final percentage = (score / 400.0) * 100.0;
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }
}
