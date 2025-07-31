import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/user_stats_provider.dart';
import '../theme/app_colors.dart';
import '../../data/services/firestore_service.dart';
import '../../data/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _avatarUrl;
  String? _firstName;
  String? _lastName;
  String? _email;
  String? _phone;

  // Avatar gallery URLs (same as home screen)
  static const List<String> kAvatarGallery = [
    'assets/avatars/avatar1.png',
    'assets/avatars/avatar2.png',
    'assets/avatars/avatar3.png',
    'assets/avatars/avatar4.png',
    'assets/avatars/avatar5.png',
    'assets/avatars/avatar6.png',
    'assets/avatars/avatar7.png',
    'assets/avatars/avatar8.png',
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
        if (profile != null) {
          setState(() {
            _avatarUrl = profile['avatarUrl'];
            _firstName = profile['firstName'];
            _lastName = profile['lastName'];
            _email = profile['email'];
            _phone = profile['phone'];
          });
        }
          } catch (e) {
      // Error fetching user profile
    }
    }
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
              itemCount: kAvatarGallery.length,
              itemBuilder: (context, index) {
                final url = kAvatarGallery[index];
                return GestureDetector(
                  onTap: () async {
                    await _saveAvatarToFirestore(url);
                    setState(() {
                      _avatarUrl = url;
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.grey,
                            ),
                          );
                        },
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

  Future<void> _saveAvatarToFirestore(String avatarUrl) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirestoreService.updateUserProfile(user.uid, {'avatarUrl': avatarUrl});
          } catch (e) {
      // Error saving avatar
    }
    }
  }

  String _getDisplayName() {
    if (_firstName != null && _firstName!.isNotEmpty && _lastName != null && _lastName!.isNotEmpty) {
      return '$_firstName $_lastName';
    } else if (_firstName != null && _firstName!.isNotEmpty) {
      return _firstName!;
    } else if (_lastName != null && _lastName!.isNotEmpty) {
      return _lastName!;
    } else {
      final user = FirebaseAuth.instance.currentUser;
      return user?.displayName ?? 'Guest User';
    }
  }

  String _getDisplayEmail() {
    if (_email != null && _email!.isNotEmpty) {
      return _email!;
    } else {
      final user = FirebaseAuth.instance.currentUser;
      return user?.email ?? 'guest@example.com';
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
        title: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                Icons.person,
                color: Colors.white,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Profile',
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 20
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12, left: 0),
            child: Center(
              child: IconButton(
                icon: const Icon(
                  Icons.settings, 
                  size: 22
                ),
                tooltip: 'Settings',
                onPressed: () => Navigator.pushNamed(context, '/settings'),
                splashRadius: 22,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
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
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          
          // Avatar and Name
          Row(
            children: [
              GestureDetector(
                onTap: _changeAvatar,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      backgroundImage: _avatarUrl != null && _avatarUrl!.isNotEmpty
                          ? AssetImage(_avatarUrl!)
                          : null,
                      child: _avatarUrl == null || _avatarUrl!.isEmpty
                          ? const Icon(
                              Icons.person,
                              color: AppColors.dominantPurple,
                              size: 36,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.accentAmber,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getDisplayName(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getDisplayEmail(),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  await Navigator.pushNamed(context, '/edit-profile');
                  // Refresh profile data when returning from edit profile
                  _fetchUserProfile();
                },
                icon: const Icon(
                  Icons.edit,
                  color: AppColors.dominantPurple,
                  size: 20,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
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
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickStat(
                  context,
                  'Questions',
                  '${userStats?.questionsAnswered ?? 0}',
                  Icons.quiz,
                  AppColors.subjectBlue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickStat(
                  context,
                  'Accuracy',
                  '${(userStats?.accuracyRate ?? 0.0) * 100}%',
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, dynamic userStats, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Your Progress',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Stats cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildStatCard(
                context,
                'Total Study Time',
                '${userStats?.formattedStudyTime ?? '0m'}',
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
    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 2,
      color: isDark ? const Color(0xFF23243B) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Quick Actions',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
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
                'My Library',
                Icons.library_books,
                AppColors.subjectGreen,
                () => Navigator.pushNamed(context, '/my-library'),
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
              _buildMenuItem(
                context,
                'Logout',
                Icons.logout,
                Colors.red,
                () => _logout(context),
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      color: isDark ? const Color(0xFF23243B) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: color,
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: AppColors.textSecondary,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  void _logout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _performLogout(context);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout(BuildContext context) async {
    try {
      final authService = AuthService();
      await authService.signOut();
      
      // Navigate to auth screen
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/auth',
          (route) => false, // Remove all previous routes from the stack
        );
      }
    } catch (e) {
      // Even if there's an error, try to navigate to auth
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/auth',
          (route) => false,
        );
      }
    }
  }
}

