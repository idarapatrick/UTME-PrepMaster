import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/achievement_badge.dart';
import '../widgets/rank_badge.dart';
import '../theme/app_colors.dart';
import '../../data/services/firestore_service.dart';
import '../providers/user_stats_provider.dart';
import '../../domain/models/user_stats_model.dart';
import '../utils/responsive_helper.dart';

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
      final userStatsProvider = Provider.of<UserStatsProvider>(context, listen: false);
      final results = await Future.wait([
        userStatsProvider.getLeaderboard(limit: 50),
        FirestoreService.fetchCbtLeaderboard(),
      ]);
      setState(() {
        _xpLeaderboard = (results[0] as List<UserStats>).map((stats) => <String, dynamic>{
          'name': stats.userId, // We'll need to get user names from profiles
          'xp': stats.totalXp,
          'avatar': 'https://api.dicebear.com/7.x/adventurer/svg?seed=${stats.userId}',
        }).toList();
        _cbtLeaderboard = results[1] as List<Map<String, dynamic>>;
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
    final bgColor = isDark
        ? const Color(0xFF181A20)
        : AppColors.backgroundPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Leaderboard',
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20),
          ),
        ),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ResponsiveHelper.responsiveSingleChildScrollView(
        context: context,
        child: Padding(
          padding: ResponsiveHelper.getResponsiveEdgeInsets(context),
          child: Column(
            children: [
              // Header Section
              _buildHeaderSection(context, isDark),
              
              SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
              
              // Top 3 Podium
              _buildPodiumSection(context, isDark),
              
              SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
              
              // Leaderboard List
              _buildLeaderboardList(context, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, bool isDark) {
    return ResponsiveHelper.responsiveCard(
      context: context,
      color: isDark ? const Color(0xFF23243B) : Colors.white,
      child: Column(
        children: [
          Icon(
            Icons.emoji_events,
            size: ResponsiveHelper.getResponsiveIconSize(context, 48),
            color: AppColors.accentAmber,
          ),
          
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
          
          Text(
            'Top Performers',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 24),
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context) / 2),
          
          Text(
            'See how you rank among other students',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top 3',
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20),
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        
        SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 2nd Place
            if (_xpLeaderboard.length > 1)
              Expanded(
                child: _buildPodiumCard(
                  context,
                  _xpLeaderboard[1],
                  2,
                  AppColors.subjectBlue,
                  isDark,
                ),
              ),
            
            // 1st Place
            if (_xpLeaderboard.isNotEmpty)
              Expanded(
                flex: 2,
                child: _buildPodiumCard(
                  context,
                  _xpLeaderboard[0],
                  1,
                  AppColors.accentAmber,
                  isDark,
                ),
              ),
            
            // 3rd Place
            if (_xpLeaderboard.length > 2)
              Expanded(
                child: _buildPodiumCard(
                  context,
                  _xpLeaderboard[2],
                  3,
                  AppColors.subjectGreen,
                  isDark,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildPodiumCard(BuildContext context, Map<String, dynamic> user, int position, Color color, bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getResponsivePadding(context) / 4),
      child: Column(
        children: [
          // Position Badge
          Container(
            width: ResponsiveHelper.getResponsiveIconSize(context, 40),
            height: ResponsiveHelper.getResponsiveIconSize(context, 40),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$position',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
                ),
              ),
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context) / 2),
          
          // Avatar
          CircleAvatar(
            radius: ResponsiveHelper.getResponsiveIconSize(context, position == 1 ? 35 : 25),
            backgroundColor: color.withValues(alpha: 0.1),
            child: Text(
              user['name']?.substring(0, 1).toUpperCase() ?? 'U',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, position == 1 ? 20 : 16),
              ),
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context) / 2),
          
          // Name
          Text(
            user['name'] ?? 'Unknown',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, position == 1 ? 16 : 14),
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context) / 4),
          
          // Score
          Text(
            '${user['xp'] ?? 0} XP',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, position == 1 ? 18 : 14),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Rankings',
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20),
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        
        SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
        
        Column(
          children: _xpLeaderboard.asMap().entries.map((entry) {
            final index = entry.key;
            final user = entry.value;
            return _buildLeaderboardItem(context, user, index + 1, isDark);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(BuildContext context, Map<String, dynamic> user, int rank, bool isDark) {
    final isTop3 = rank <= 3;
    final color = rank == 1 
        ? AppColors.accentAmber 
        : rank == 2 
            ? AppColors.subjectBlue 
            : rank == 3 
                ? AppColors.subjectGreen 
                : AppColors.textSecondary;
    
    return ResponsiveHelper.responsiveCard(
      context: context,
      color: isDark ? const Color(0xFF23243B) : Colors.white,
      child: Row(
        children: [
          // Rank
          Container(
            width: ResponsiveHelper.getResponsiveIconSize(context, 40),
            height: ResponsiveHelper.getResponsiveIconSize(context, 40),
            decoration: BoxDecoration(
              color: isTop3 ? color : AppColors.textTertiary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  color: isTop3 ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                ),
              ),
            ),
          ),
          
          SizedBox(width: ResponsiveHelper.getResponsivePadding(context)),
          
          // Avatar
          CircleAvatar(
            radius: ResponsiveHelper.getResponsiveIconSize(context, 20),
            backgroundColor: color.withValues(alpha: 0.1),
            child: Text(
              user['name']?.substring(0, 1).toUpperCase() ?? 'U',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
              ),
            ),
          ),
          
          SizedBox(width: ResponsiveHelper.getResponsivePadding(context)),
          
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'] ?? 'Unknown',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                
                SizedBox(height: ResponsiveHelper.getResponsivePadding(context) / 4),
                
                Text(
                  '${user['achievements']?.join(', ') ?? 'No Achievements'}',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${user['xp'] ?? 0}',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              
              Text(
                'XP',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
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
                _xpLeaderboard = await FirestoreService.fetchXpLeaderboard();
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
              ? AppColors.dominantPurple.withValues(alpha: 0.1)
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
                color: Colors.grey.withValues(alpha: 0.1),
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