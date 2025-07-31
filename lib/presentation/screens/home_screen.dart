import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/user_stats_provider.dart';
import '../../data/services/firestore_service.dart';
import '../utils/responsive_helper.dart';
import '../widgets/xp_animation_widget.dart';
import '../widgets/streak_animation_widget.dart';
import 'study_partner_screen.dart';

// Avatar gallery URLs
const List<String> kAvatarGallery = [
  'assets/avatars/avatar1.png',
  'assets/avatars/avatar2.png',
  'assets/avatars/avatar3.png',
  'assets/avatars/avatar4.png',
  'assets/avatars/avatar5.png',
  'assets/avatars/avatar6.png',
  'assets/avatars/avatar7.png',
  'assets/avatars/avatar8.png',
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _userSubjects = [];
  bool _loadingSubjects = true;
  String? _avatarUrl;
  int _streakDays = 0;
  int _badgeCount = 0;
  int _totalXp = 0;
  final int _dailyChallengeXp = 250;
  int _currentCarouselIndex = 0;
  final PageController _carouselController = PageController();
  final Map<String, Map<String, dynamic>> _subjectProgress = {};

  // Animation states
  bool _showXpAnimation = false;
  bool _showStreakAnimation = false;
  int _lastXpEarned = 0;
  int _lastStreakCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserSubjects();
    _loadUserAvatar();
    _loadUserStats();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userStatsProvider = Provider.of<UserStatsProvider>(context, listen: false);
      userStatsProvider.initializeUserStats();
      // Check daily login for streak tracking
      userStatsProvider.checkDailyLogin();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen to user stats changes
    final userStatsProvider = Provider.of<UserStatsProvider>(context);
    if (userStatsProvider.userStats != null) {
      final stats = userStatsProvider.userStats!;
      
      // Update local stats
      setState(() {
        _totalXp = stats.totalXp;
        _streakDays = stats.currentStreak;
        _badgeCount = stats.earnedBadges.length;
      });

      // Handle animations
      if (userStatsProvider.showXpAnimation) {
        setState(() {
          _showXpAnimation = true;
          _lastXpEarned = userStatsProvider.lastXpEarned;
        });
        
        // Hide animation after completion
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _showXpAnimation = false;
            });
            userStatsProvider.hideXpAnimation();
          }
        });
      }

      if (userStatsProvider.showStreakAnimation) {
        setState(() {
          _showStreakAnimation = true;
          _lastStreakCount = userStatsProvider.lastStreakCount;
        });
        
        // Hide animation after completion
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _showStreakAnimation = false;
            });
            userStatsProvider.hideStreakAnimation();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  Future<void> _loadUserSubjects() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final subjects = await FirestoreService.loadUserSubjects(user.uid);
        if (subjects.isNotEmpty) {
          final subjectData = subjects.map((subjectName) {
            return {
              'name': subjectName,
              'icon': _getSubjectIcon(subjectName),
              'color': _getSubjectColor(subjectName),
            };
          }).toList();

          setState(() {
            _userSubjects = subjectData;
            _loadingSubjects = false;
          });

          // Load progress for each subject
          for (final subject in subjectData) {
            await _loadSubjectProgress(user.uid, subject['name'] as String);
          }
        } else {
          setState(() {
            _userSubjects = [];
            _loadingSubjects = false;
          });
        }
      } catch (e) {
        // Error loading subjects
        setState(() {
          _userSubjects = [];
          _loadingSubjects = false;
        });
      }
    } else {
      setState(() {
        _userSubjects = [];
        _loadingSubjects = false;
      });
    }
  }

  Future<void> _loadSubjectProgress(String userId, String subjectName) async {
    try {
      final progress = await FirestoreService.getSubjectProgress(userId, subjectName);
      setState(() {
        _subjectProgress[subjectName] = progress ?? {};
      });
    } catch (e) {
      // Error loading progress for subject
    }
  }

  Future<void> _loadUserStats() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userData = await FirestoreService.getUserProfile(user.uid);
        setState(() {
          _streakDays = userData?['streakDays'] ?? 0;
          _badgeCount = userData?['badgeCount'] ?? 0;
          _totalXp = userData?['totalXp'] ?? 0;
        });
          } catch (e) {
      // Error loading user stats
    }
    }
  }

  IconData _getSubjectIcon(String subjectName) {
    switch (subjectName) {
      case 'English':
        return Icons.language;
      case 'Mathematics':
        return Icons.calculate;
      case 'Physics':
        return Icons.science;
      case 'Chemistry':
        return Icons.bubble_chart;
      case 'Biology':
        return Icons.biotech;
      case 'Government':
        return Icons.account_balance;
      case 'Economics':
        return Icons.trending_up;
      case 'Geography':
        return Icons.public;
      case 'Christian Religious Studies':
        return Icons.church;
      case 'Islamic Studies':
        return Icons.mosque;
      case 'Commerce':
        return Icons.store;
      default:
        return Icons.book;
    }
  }

  Color _getSubjectColor(String subjectName) {
    switch (subjectName) {
      case 'English':
        return AppColors.dominantPurple;
      case 'Mathematics':
      case 'Physics':
      case 'Chemistry':
      case 'Biology':
        return AppColors.subjectBlue;
      case 'Christian Religious Studies':
      case 'Islamic Studies':
        return AppColors.subjectRed;
      default:
        return AppColors.subjectGreen;
    }
  }

  Future<void> _loadUserAvatar() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userData = await FirestoreService.getUserProfile(user.uid);
        setState(() {
          _avatarUrl = userData?['avatarUrl'];
        });
          } catch (e) {
      // Error loading avatar
    }
    }
  }

  Future<void> _setAvatar(String url) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirestoreService.updateUserProfile(user.uid, {'avatarUrl': url});
        setState(() {
          _avatarUrl = url;
        });
          } catch (e) {
      // Error setting avatar
    }
    }
  }

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StudyPartnerScreen()),
        );
        break;
      case 2:
        Navigator.pushNamed(context, '/mock-test');
        break;
      case 3:
        Navigator.pushNamed(context, '/ai-tutor');
        break;
      case 4:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  void _onStatPillTap(String type) {
    switch (type) {
      case 'streak':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_streakDays > 0 
                ? 'You have a $_streakDays day study streak!' 
                : 'Start your study streak today!'),
            backgroundColor: AppColors.accentAmber,
          ),
        );
        break;
      case 'badges':
        Navigator.pushNamed(context, '/badges');
        break;
      case 'xp':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Total XP: $_totalXp'),
            backgroundColor: AppColors.dominantPurple,
          ),
        );
        break;
    }
  }

  void _onTodayChallengeTap() {
    Navigator.pushNamed(context, '/mock-test');
  }

  void _onCarouselPageChanged(int index) {
    setState(() {
      _currentCarouselIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.getBackgroundPrimary(context),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.dominantPurple,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: ResponsiveHelper.getResponsiveHorizontalPadding(context),
          child: Row(
            children: [
              Icon(
                Icons.menu_book_rounded,
                color: Colors.white,
                size: ResponsiveHelper.getResponsiveIconSize(context, 24),
              ),
              SizedBox(width: ResponsiveHelper.isMobile(context) ? 8 : 12),
              Text(
                'UTME PrepMaster',
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20)
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_none, 
              size: ResponsiveHelper.getResponsiveIconSize(context, 22)
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications coming soon!'),
                  backgroundColor: AppColors.dominantPurple,
                ),
              );
            },
          ),
          Padding(
            padding: EdgeInsets.only(
              right: ResponsiveHelper.isMobile(context) ? 12 : 16, 
              left: 0
            ),
            child: GestureDetector(
              onTap: () => _showAvatarGallery(context),
              child: CircleAvatar(
                radius: ResponsiveHelper.getResponsiveIconSize(context, 16),
                backgroundColor: Colors.white,
                backgroundImage: _avatarUrl != null && _avatarUrl!.isNotEmpty
                    ? AssetImage(_avatarUrl!)
                    : null,
                child: _avatarUrl == null || _avatarUrl!.isEmpty
                    ? Icon(
                        Icons.person,
                        color: AppColors.dominantPurple,
                        size: ResponsiveHelper.getResponsiveIconSize(context, 18),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: EdgeInsets.only(
                    top: ResponsiveHelper.getResponsivePadding(context), 
                    bottom: ResponsiveHelper.getResponsivePadding(context) / 2,
                    left: ResponsiveHelper.getResponsivePadding(context),
                    right: ResponsiveHelper.getResponsivePadding(context),
                  ),
                  child: Material(
                    elevation: 3,
                    borderRadius: BorderRadius.circular(14),
                    child: TextField(
                      readOnly: true,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Search functionality coming soon!'),
                            backgroundColor: AppColors.dominantPurple,
                          ),
                        );
                      },
                      style: TextStyle(
                        color: AppColors.getTextPrimary(context), 
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16)
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search subjects, topics, resources...',
                        hintStyle: TextStyle(
                          color: AppColors.getTextSecondary(context),
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                        ),
                        prefixIcon: Icon(
                          Icons.search, 
                          color: AppColors.getTextSecondary(context),
                          size: ResponsiveHelper.getResponsiveIconSize(context, 20),
                        ),
                        filled: true,
                        fillColor: AppColors.getCardColor(context),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: ResponsiveHelper.getResponsiveTextFieldHeight(context) / 3,
                          horizontal: ResponsiveHelper.getResponsivePadding(context),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),

                // Welcome Section
                _buildWelcomeSection(context, user),

                // Carousel Section
                _buildCarouselSection(context),

                // Stats Section
                _buildQuickActionsSection(context),

                // Subject Progress
                _buildSubjectProgressSection(context),

                SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
              ],
            ),
          ),
                     if (_showXpAnimation)
             Positioned(
               top: MediaQuery.of(context).size.height * 0.3,
               left: MediaQuery.of(context).size.width * 0.5 - 50,
               child: XpAnimationWidget(
                 xpEarned: _lastXpEarned,
                 onAnimationComplete: () {
                   setState(() {
                     _showXpAnimation = false;
                   });
                 },
               ),
             ),
           if (_showStreakAnimation)
             Positioned(
               top: MediaQuery.of(context).size.height * 0.4,
               left: MediaQuery.of(context).size.width * 0.5 - 80,
               child: StreakAnimationWidget(
                 streakCount: _lastStreakCount,
                 onAnimationComplete: () {
                   setState(() {
                     _showStreakAnimation = false;
                   });
                 },
               ),
             ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        selectedItemColor: AppColors.dominantPurple,
        unselectedItemColor: AppColors.getTextSecondary(context),
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Study Partner'),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'CBT Tests'),
          BottomNavigationBarItem(icon: Icon(Icons.psychology), label: 'AI Tutor'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.getCardColor(context),
        elevation: 12,
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, User? user) {
    return Padding(
      padding: ResponsiveHelper.getResponsiveHorizontalPadding(context),
      child: Card(
        color: AppColors.getCardColor(context),
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.only(bottom: 14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Morning ☀️',
                style: TextStyle(
                  color: AppColors.getTextSecondary(context),
                  fontWeight: FontWeight.w500,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                user?.displayName ??
                    user?.email?.split('@').first ??
                    'Student',
                style: TextStyle(
                  color: AppColors.getTextPrimary(context),
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    'Popular topics: ',
                    style: TextStyle(
                      color: AppColors.getTextSecondary(context),
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 13),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _userSubjects.isNotEmpty
                          ? _userSubjects
                              .map((s) => s['name'] as String? ?? 'Unknown')
                              .take(4)
                              .join(', ')
                          : 'English (Required)',
                      style: TextStyle(
                        color: AppColors.dominantPurple,
                        fontWeight: FontWeight.w600,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 13),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselSection(BuildContext context) {
    return Padding(
      padding: ResponsiveHelper.getResponsiveHorizontalPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
              color: AppColors.getTextPrimary(context),
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
          SizedBox(
            height: 120,
            child: PageView.builder(
              controller: _carouselController,
              onPageChanged: _onCarouselPageChanged,
              itemCount: 3,
              itemBuilder: (context, index) {
                switch (index) {
                  case 0:
                    return _buildCarouselCard(
                      context: context,
                      title: 'Study Streaks',
                      subtitle: 'Keep your momentum going',
                      imageUrl: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=400&q=80',
                      color: AppColors.accentAmber,
                      onTap: () => Navigator.pushNamed(context, '/profile'),
                    );
                  case 1:
                    return _buildCarouselCard(
                      context: context,
                      title: 'AI Tutor',
                      subtitle: 'Get personalized help',
                      imageUrl: 'https://images.unsplash.com/photo-1677442136019-21780ecad995?auto=format&fit=crop&w=400&q=80',
                      color: AppColors.dominantPurple,
                      onTap: () => Navigator.pushNamed(context, '/ai-tutor'),
                    );
                  case 2:
                    return _buildCarouselCard(
                      context: context,
                      title: 'Study Partner',
                      subtitle: 'Find study buddies',
                      imageUrl: 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?auto=format&fit=crop&w=400&q=80',
                      color: AppColors.subjectBlue,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const StudyPartnerScreen()),
                      ),
                    );
                  default:
                    return const SizedBox.shrink();
                }
              },
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
          // Carousel indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: index == _currentCarouselIndex 
                      ? AppColors.dominantPurple 
                      : AppColors.getTextSecondary(context),
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String imageUrl,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxHeight: 100),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark 
                ? [
                    AppColors.darkCardPrimary,
                    AppColors.darkCardSecondary,
                  ]
                : [
                    color.withValues(alpha: 0.1),
                    color.withValues(alpha: 0.05),
                  ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark 
                ? AppColors.darkBorderLight
                : color.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.image,
                            color: color,
                            size: ResponsiveHelper.getResponsiveIconSize(context, 24),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: AppColors.getTextPrimary(context),
                          fontWeight: FontWeight.bold,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: AppColors.getTextSecondary(context),
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: color,
                  size: ResponsiveHelper.getResponsiveIconSize(context, 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Padding(
      padding: ResponsiveHelper.getResponsiveHorizontalPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Stats',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
              color: AppColors.getTextPrimary(context),
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatPill(
                  icon: Icons.local_fire_department,
                  label: _streakDays > 0 ? '${_streakDays}d Streak' : 'Start Streak',
                  color: AppColors.accentAmber,
                  isDark: Theme.of(context).brightness == Brightness.dark,
                  onTap: () => _onStatPillTap('streak'),
                ),
                const SizedBox(width: 10),
                _buildStatPill(
                  icon: Icons.emoji_events,
                  label: '$_badgeCount Badges',
                  color: AppColors.dominantPurple,
                  isDark: Theme.of(context).brightness == Brightness.dark,
                  onTap: () => _onStatPillTap('badges'),
                ),
                const SizedBox(width: 10),
                _buildStatPill(
                  icon: Icons.star,
                  label: '$_totalXp XP',
                  color: AppColors.subjectBlue,
                  isDark: Theme.of(context).brightness == Brightness.dark,
                  onTap: () => _onStatPillTap('xp'),
                ),
                const SizedBox(width: 16),
                _buildTodayChallengeCard(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayChallengeCard(BuildContext context) {
    return GestureDetector(
      onTap: _onTodayChallengeTap,
      child: Container(
        width: 200,
        height: 100,
        constraints: const BoxConstraints(maxHeight: 100),
        decoration: BoxDecoration(
          color: AppColors.dominantPurple,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Today\'s Challenge',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Complete a mock test for $_dailyChallengeXp XP',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.headphones,
                  color: Colors.white,
                  size: ResponsiveHelper.getResponsiveIconSize(context, 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectProgressSection(BuildContext context) {
    return Padding(
      padding: ResponsiveHelper.getResponsiveHorizontalPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subjects',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
                  color: AppColors.getTextPrimary(context),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/subject-selection')
                    .then((_) => _loadUserSubjects()),
                child: Text(
                  'Edit',
                  style: TextStyle(
                    color: AppColors.dominantPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
          
          _loadingSubjects
              ? Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
                      Text(
                        'Loading your subjects...',
                        style: TextStyle(
                          color: AppColors.getTextSecondary(context),
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                        ),
                      ),
                    ],
                  ),
                )
              : _userSubjects.isEmpty
                  ? _buildEmptySubjectsState(context)
                  : Column(
                      children: _userSubjects.map((subject) {
                        final progress = _subjectProgress[subject['name']];
                        final progressText = progress != null 
                            ? 'Best: ${(progress['bestScore'] ?? 0).toStringAsFixed(1)} | Correct: ${progress['correct'] ?? 0} / ${progress['attempted'] ?? 0}'
                            : 'Progress: 0%';
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: AppColors.getCardColor(context),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: (subject['color'] as Color).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                subject['icon'] ?? Icons.help_outline,
                                color: subject['color'] ?? Colors.grey,
                                size: ResponsiveHelper.getResponsiveIconSize(context, 20),
                              ),
                            ),
                            title: Text(
                              subject['name'] ?? 'Unknown Subject',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                              ),
                            ),
                            subtitle: Text(
                              progressText,
                              style: TextStyle(
                                color: AppColors.getTextSecondary(context),
                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                              ),
                            ),
                            trailing: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/course-content',
                                  arguments: subject['name'] ?? '',
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.dominantPurple,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'View Course',
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
        ],
      ),
    );
  }

  Widget _buildEmptySubjectsState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(
            Icons.subject,
            size: ResponsiveHelper.getResponsiveIconSize(context, 60),
            color: AppColors.getTextTertiary(context),
          ),
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
          Text(
            'Select Your Subjects',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(context),
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context) / 2),
          Text(
            'English is required. Choose 3 additional subjects to get started.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
              color: AppColors.getTextSecondary(context),
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
          SizedBox(
            width: ResponsiveHelper.isMobile(context) ? double.infinity : MediaQuery.of(context).size.width * 0.6,
            height: ResponsiveHelper.getResponsiveButtonHeight(context),
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(
                context,
                '/subject-selection',
              ).then((_) => _loadUserSubjects()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dominantPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsivePadding(context) / 2),
                ),
              ),
              child: Text(
                'Select Subjects',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? color.withValues(alpha: 0.18) : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: ResponsiveHelper.getResponsiveIconSize(context, 20)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAvatarGallery(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Choose Your Avatar',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemCount: kAvatarGallery.length,
                itemBuilder: (context, i) {
                  final url = kAvatarGallery[i];
                  return GestureDetector(
                    onTap: () async {
                      await _setAvatar(url);
                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Avatar updated successfully!'),
                            backgroundColor: AppColors.dominantPurple,
                          ),
                        );
                      }
                    },
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage(url),
                      child: _avatarUrl == url
                          ? Icon(
                              Icons.check_circle,
                              color: AppColors.dominantPurple,
                              size: ResponsiveHelper.getResponsiveIconSize(context, 28),
                            )
                          : null,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
