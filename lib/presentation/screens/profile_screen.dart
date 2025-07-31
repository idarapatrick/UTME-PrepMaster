import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/user_stats_provider.dart';
import '../theme/app_colors.dart';
import '../../data/services/firestore_service.dart';
import '../utils/responsive_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _avatarAsset = 'assets/avatars/avatar1.png';
  bool _loading = true;

  // Avatar options
  static const List<Map<String, String>> kAvatars = [
    {'asset': 'assets/avatars/avatar1.png'},
    {'asset': 'assets/avatars/avatar2.png'},
    {'asset': 'assets/avatars/avatar3.png'},
    {'asset': 'assets/avatars/avatar4.png'},
    {'asset': 'assets/avatars/avatar5.png'},
    {'asset': 'assets/avatars/avatar6.png'},
    {'asset': 'assets/avatars/avatar7.png'},
    {'asset': 'assets/avatars/avatar8.png'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final profile = await FirestoreService.getUserProfile(user.uid);
        if (profile != null && profile['avatarUrl'] != null) {
          setState(() {
            _avatarAsset = profile['avatarUrl'];
          });
        }
      } catch (e) {
        print('Error fetching user profile: $e');
      }
    }
    setState(() {
      _loading = false;
    });
  }

  void _changeAvatar() {
    _showAvatarGallery(context);
  }

  void _showAvatarGallery(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Avatar'),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: kAvatars.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _avatarAsset = kAvatars[index]['asset']!;
                    });
                    _saveAvatarToFirestore(kAvatars[index]['asset']!);
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _avatarAsset == kAvatars[index]['asset']
                            ? AppColors.dominantPurple
                            : Colors.grey.shade300,
                        width: _avatarAsset == kAvatars[index]['asset'] ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        kAvatars[index]['asset']!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveAvatarToFirestore(String avatarPath) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirestoreService.updateUserProfile(user.uid, {'avatarUrl': avatarPath});
      } catch (e) {
        print('Error saving avatar: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? const Color(0xFF181A20)
        : AppColors.backgroundSecondary;
    
    // Get user stats provider
    final userStatsProvider = Provider.of<UserStatsProvider>(context);
    final userStats = userStatsProvider.userStats;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.dominantPurple,
        titleSpacing: 0,
        title: Padding(
          padding: ResponsiveHelper.getResponsiveHorizontalPadding(context),
          child: Row(
            children: [
              Icon(
                Icons.person,
                color: Colors.white,
                size: ResponsiveHelper.getResponsiveIconSize(context, 24),
              ),
              SizedBox(width: ResponsiveHelper.isMobile(context) ? 8 : 12),
              Text(
                'Profile',
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20)
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(
              right: ResponsiveHelper.isMobile(context) ? 12 : 16, 
              left: 0
            ),
            child: Center(
              child: IconButton(
                icon: Icon(
                  Icons.settings, 
                  size: ResponsiveHelper.getResponsiveIconSize(context, 22)
                ),
                tooltip: 'Settings',
                onPressed: () => Navigator.pushNamed(context, '/settings'),
                splashRadius: ResponsiveHelper.getResponsiveIconSize(context, 22),
              ),
            ),
          ),
        ],
      ),
      body: ResponsiveHelper.responsiveSingleChildScrollView(
        context: context,
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(context, user, userStats, isDark),
            
            // Stats Section
            _buildStatsSection(context, userStats, isDark),
            
            // Menu Items
            _buildMenuItems(context, isDark),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 4, // Profile tab
        onTap: (index) {
          switch (index) {
            case 0:
              // Navigate to home without replacement to maintain proper navigation stack
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/study-partner');
              break;
            case 2:
              Navigator.pushNamed(context, '/mock-test');
              break;
            case 3:
              Navigator.pushNamed(context, '/ai-tutor');
              break;
            case 4:
              // Already on profile
              break;
          }
        },
        selectedItemColor: AppColors.dominantPurple,
        unselectedItemColor: AppColors.secondaryGray,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Study Partner'),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'CBT Tests'),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology),
            label: 'AI Tutor',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? const Color(0xFF23243B) : Colors.white,
        elevation: 12,
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, User? user, dynamic userStats, bool isDark) {
    return Padding(
      padding: ResponsiveHelper.getResponsiveHorizontalPadding(context),
      child: Column(
        children: [
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
          
          // Avatar and Name
          Row(
            children: [
              GestureDetector(
                onTap: _changeAvatar,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: ResponsiveHelper.getResponsiveIconSize(context, 40),
                      backgroundColor: AppColors.dominantPurple.withValues(alpha: 0.1),
                      backgroundImage: _avatarAsset != null && _avatarAsset!.isNotEmpty
                          ? AssetImage(_avatarAsset!)
                          : null,
                      child: _avatarAsset == null || _avatarAsset!.isEmpty
                          ? Icon(
                              Icons.person,
                              color: AppColors.dominantPurple,
                              size: ResponsiveHelper.getResponsiveIconSize(context, 40),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context) / 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentAmber,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: ResponsiveHelper.getResponsiveIconSize(context, 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: ResponsiveHelper.getResponsivePadding(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? 'Guest User',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20),
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: ResponsiveHelper.getResponsivePadding(context) / 4),
                    Text(
                      user?.email ?? 'guest@example.com',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pushNamed(context, '/edit-profile'),
                icon: Icon(
                  Icons.edit,
                  color: AppColors.dominantPurple,
                  size: ResponsiveHelper.getResponsiveIconSize(context, 20),
                ),
              ),
            ],
          ),
          
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
          
          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildQuickStat(
                  context,
                  'XP',
                  '${userStats?.totalXp ?? 0}',
                  Icons.star,
                  AppColors.accentAmber,
                ),
              ),
              SizedBox(width: ResponsiveHelper.getResponsivePadding(context)),
              Expanded(
                child: _buildQuickStat(
                  context,
                  'Questions',
                  '${userStats?.questionsAnswered ?? 0}',
                  Icons.quiz,
                  AppColors.subjectBlue,
                ),
              ),
              SizedBox(width: ResponsiveHelper.getResponsivePadding(context)),
              Expanded(
                child: _buildQuickStat(
                  context,
                  'Accuracy',
                  '${((userStats?.accuracyRate ?? 0.0) * 100).toStringAsFixed(1)}%',
                  Icons.trending_up,
                  AppColors.subjectGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: ResponsiveHelper.getResponsiveIconSize(context, 20),
          ),
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context) / 2),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, dynamic userStats, bool isDark) {
    return Padding(
      padding: ResponsiveHelper.getResponsiveHorizontalPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
          Text(
            'Your Progress',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
          
          // Stats cards
          ResponsiveHelper.responsiveGridView(
            context: context,
            children: [
              _buildStatCard(
                context,
                'Total Study Time',
                userStats?.formattedStudyTime ?? '0m',
                Icons.timer,
                AppColors.dominantPurple,
                isDark,
              ),
              _buildStatCard(
                context,
                'Questions Answered',
                '${userStats?.questionsAnswered ?? 0}',
                Icons.quiz,
                AppColors.subjectBlue,
                isDark,
              ),
              _buildStatCard(
                context,
                'Correct Answers',
                '${userStats?.correctAnswers ?? 0}',
                Icons.check_circle,
                AppColors.accentAmber,
                isDark,
              ),
              _buildStatCard(
                context,
                'Accuracy',
                '${((userStats?.accuracyRate ?? 0.0) * 100).toStringAsFixed(1)}%',
                Icons.trending_up,
                AppColors.subjectGreen,
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color, bool isDark) {
    return ResponsiveHelper.responsiveCard(
      context: context,
      color: isDark ? const Color(0xFF23243B) : Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: ResponsiveHelper.getResponsiveIconSize(context, 32),
          ),
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context) / 2),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context) / 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context, bool isDark) {
    return Padding(
      padding: ResponsiveHelper.getResponsiveHorizontalPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
          Text(
            'Quick Actions',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
          
          // Menu items
          Column(
            children: [
              _buildMenuItem(
                context,
                'Edit Profile',
                Icons.edit,
                AppColors.dominantPurple,
                () => Navigator.pushNamed(context, '/edit-profile'),
                isDark,
              ),
              _buildMenuItem(
                context,
                'Leaderboard',
                Icons.leaderboard,
                AppColors.accentAmber,
                () => Navigator.pushNamed(context, '/leaderboard'),
                isDark,
              ),
              _buildMenuItem(
                context,
                'Badges',
                Icons.emoji_events,
                AppColors.subjectGreen,
                () => Navigator.pushNamed(context, '/badges'),
                isDark,
              ),
              _buildMenuItem(
                context,
                'Settings',
                Icons.settings,
                AppColors.subjectBlue,
                () => Navigator.pushNamed(context, '/settings'),
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap, bool isDark) {
    return ResponsiveHelper.responsiveCard(
      context: context,
      color: isDark ? const Color(0xFF23243B) : Colors.white,
      child: ListTile(
        leading: Icon(
          icon,
          color: color,
          size: ResponsiveHelper.getResponsiveIconSize(context, 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: AppColors.textSecondary,
          size: ResponsiveHelper.getResponsiveIconSize(context, 16),
        ),
        onTap: onTap,
      ),
    );
  }
}

