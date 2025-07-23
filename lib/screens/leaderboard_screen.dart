import 'package:flutter/material.dart';
import 'package:utme_prep_master/widgets/achievement_badge.dart';
import 'package:utme_prep_master/widgets/rank_badge.dart';
import '../theme/app_colors.dart';
import '../services/firestore_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _xpPeriods = ['24h', 'Weekly', 'Monthly'];
  int _xpPeriodIndex = 0;
  List<Map<String, dynamic>> _xpLeaderboard = [];
  List<Map<String, dynamic>> _cbtLeaderboard = [];
  bool _loadingXp = true;
  bool _loadingCbt = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchLeaderboards();
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
        // Reset scroll position when tab changes
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _fetchLeaderboards() async {
    setState(() {
      _loadingXp = true;
      _loadingCbt = true;
    });
    try {
      final results = await Future.wait([
        FirestoreService.fetchXpLeaderboard(_xpPeriods[_xpPeriodIndex]),
        FirestoreService.fetchCbtLeaderboard(),
      ]);
      setState(() {
        _xpLeaderboard = results[0];
        _cbtLeaderboard = results[1];
      });
    } finally {
      setState(() {
        _loadingXp = false;
        _loadingCbt = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final backgroundColor = isDark ? const Color(0xFF181A20) : AppColors.backgroundPrimary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accentAmber,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'XP Earned'),
            Tab(text: 'CBT High Scores'),
          ],
        ),
      ),
      backgroundColor: backgroundColor,
      body: RefreshIndicator(
        onRefresh: _fetchLeaderboards,
        color: AppColors.dominantPurple,
        backgroundColor: backgroundColor,
        child: TabBarView(
          controller: _tabController,
          children: [
            // XP Leaderboard
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Top Learners',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      _buildPeriodSelector(isDark),
                    ],
                  ),
                ),
                _buildXpSummaryCard(isDark),
                Expanded(
                  child: _loadingXp
                      ? const Center(child: CircularProgressIndicator())
                      : _buildXpLeaderboard(isDark),
                ),
              ],
            ),
            // CBT High Scores Leaderboard
            _loadingCbt
                ? const Center(child: CircularProgressIndicator())
                : _buildCbtLeaderboard(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(bool isDark) {
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_xpPeriods.length, (index) {
            return GestureDetector(
              onTap: () async {
                setState(() => _xpPeriodIndex = index);
                setState(() => _loadingXp = true);
                _xpLeaderboard = await FirestoreService.fetchXpLeaderboard(
                  _xpPeriods[_xpPeriodIndex],
                );
                setState(() => _loadingXp = false);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _xpPeriodIndex == index
                      ? AppColors.dominantPurple
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _xpPeriods[index],
                  style: TextStyle(
                    color: _xpPeriodIndex == index ? Colors.white : textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildXpSummaryCard(bool isDark) {
    final currentUserRank = _xpLeaderboard.indexWhere(
      (user) => user['isCurrentUser'] == true,
    );
    final currentUserXp = currentUserRank >= 0
        ? _xpLeaderboard[currentUserRank]['xp'] ?? 0
        : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        color: isDark ? Colors.grey[800] : Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Your Rank',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentUserRank >= 0 ? '#${currentUserRank + 1}' : '-',
                      style: TextStyle(
                        color: AppColors.dominantPurple,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey[300],
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Your XP',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$currentUserXp',
                      style: TextStyle(
                        color: AppColors.dominantPurple,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildXpLeaderboard(bool isDark) {
  return ListView.separated(
    controller: _scrollController,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    itemCount: _xpLeaderboard.isNotEmpty ? _xpLeaderboard.length : 10,
    separatorBuilder: (context, index) => const SizedBox(height: 8),
    itemBuilder: (context, index) {
      final user = _xpLeaderboard.isNotEmpty
          ? _xpLeaderboard[index]
          : {
              'displayName': 'User ${index + 1}',
              'xp': (10000 - index * 500),
              'isCurrentUser': false,
              'achievements': <String>[],
            };

      // Convert achievements to List<String>
     final achievements = (user['achievements'] as List?)?.map((e) => e.toString()).toList() ?? <String>[];

      return _UserCard(
        rank: index + 1,
        name: user['displayName'] ?? 'User',
        value: '${user['xp']} XP',
        isCurrentUser: user['isCurrentUser'] ?? false,
        achievements: achievements,
        isDark: isDark,
        onTap: () => _showUserProfile(user),
      );
    },
  );
}

Widget _buildCbtLeaderboard(bool isDark) {
  return ListView.separated(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    itemCount: _cbtLeaderboard.isNotEmpty ? _cbtLeaderboard.length : 10,
    separatorBuilder: (context, index) => const SizedBox(height: 8),
    itemBuilder: (context, index) {
      final user = _cbtLeaderboard.isNotEmpty
          ? _cbtLeaderboard[index]
          : {
              'displayName': 'User ${index + 1}',
              'totalScore': (400 - index * 10),
              'isCurrentUser': false,
              'achievements': <String>[],
            };

      // Convert achievements to List<String>
      final achievements = (user['achievements'] as List<dynamic>?)
          ?.map((a) => a.toString())
          .toList() ?? <String>[];

      return _UserCard(
        rank: index + 1,
        name: user['displayName'] ?? 'User',
        value: '${user['totalScore']} marks',
        isCurrentUser: user['isCurrentUser'] ?? false,
        achievements: achievements,
        isDark: isDark,
        onTap: () => _showUserProfile(user),
      );
    },
  );
}

  void _showUserProfile(Map<String, dynamic> user) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      // Convert achievements to List<String>
      final achievements = (user['achievements'] as List<dynamic>?)
          ?.map((a) => a.toString())
          .toList() ?? <String>[];

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ... (other profile widgets)
            if (achievements.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Achievements',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: achievements
                        .map((achievement) => AchievementBadge(
                              achievement: achievement,
                              size: 40,
                            ))
                        .toList(),
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dominantPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _UserCard extends StatelessWidget {
  final int rank;
  final String name;
  final String value;
  final bool isCurrentUser;
  final List<String> achievements; // Keep as List<String>
  final bool isDark;
  final VoidCallback onTap;

  const _UserCard({
    required this.rank,
    required this.name,
    required this.value,
    required this.isCurrentUser,
    required this.achievements,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isCurrentUser
              ? AppColors.dominantPurple.withOpacity(0.1)
              : isDark
                  ? Colors.grey[800]
                  : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isCurrentUser
              ? Border.all(color: AppColors.dominantPurple, width: 1)
              : null,
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              RankBadge(rank: rank),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (achievements.isNotEmpty)
                SizedBox(
                  width: 60,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: AchievementBadge(
                      achievement: achievements.first,
                      size: 24,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}