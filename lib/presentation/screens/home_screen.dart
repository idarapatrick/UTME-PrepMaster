import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/user_stats_provider.dart';
import '../../data/services/firestore_service.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/error_handler_service.dart';
import '../utils/responsive_helper.dart';

import '../widgets/xp_popup_widget.dart';
import '../widgets/streak_animation_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/network_status_widget.dart';
// Demo widgets removed - XP popup now shows automatically when CBT tests are completed
import 'study_partner_screen.dart';
import 'notifications_screen.dart';

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
  String _userName = '';
  int _streakDays = 0;
  int _badgeCount = 0;
  int _totalXp = 0;
  int _currentCarouselIndex = 0;
  final PageController _carouselController = PageController();
  final Map<String, Map<String, dynamic>> _subjectProgress = {};

  // Animation states
  bool _showXpAnimation = false;
  bool _showStreakAnimation = false;
  int _lastXpEarned = 0;
  int _lastStreakCount = 0;

  // Notification states
  int _unreadNotificationCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserSubjects();
    _loadUserAvatar();
    _loadUserProfile(); // Added this to load user profile including name
    _loadUserStats();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userStatsProvider = Provider.of<UserStatsProvider>(
        context,
        listen: false,
      );
      userStatsProvider.initializeUserStats();
      userStatsProvider.checkDailyLogin();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userStatsProvider = Provider.of<UserStatsProvider>(context);
    if (userStatsProvider.userStats != null) {
      final stats = userStatsProvider.userStats!;

      setState(() {
        _totalXp = stats.totalXp;
        _streakDays = stats.currentStreak;
        _badgeCount = stats.earnedBadges.length;
      });

      if (userStatsProvider.showXpAnimation) {
        setState(() {
          _showXpAnimation = true;
          _lastXpEarned = userStatsProvider.lastXpEarned;
        });
        // Don't auto-hide - let the XpPopupWidget handle dismissal with OK button
      }

      if (userStatsProvider.showStreakAnimation) {
        setState(() {
          _showStreakAnimation = true;
          _lastStreakCount = userStatsProvider.lastStreakCount;
        });

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

    // Listen to unread notification count
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      NotificationService.getUnreadNotificationCount(user.uid).listen((count) {
        if (mounted) {
          setState(() {
            _unreadNotificationCount = count;
          });
        }
      });
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
        final subjects = await ErrorHandlerService.executeWithRetry(
          () => FirestoreService.loadUserSubjects(user.uid),
          maxRetries: 3,
        );
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
        setState(() {
          _userSubjects = [];
          _loadingSubjects = false;
        });
        if (mounted) {
          ErrorHandlerService.showErrorSnackBar(
            context,
            ErrorHandlerService.handleException(e),
            onRetry: _loadUserSubjects,
          );
        }
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
      final progress = await FirestoreService.getSubjectProgress(
        userId,
        subjectName,
      );
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

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userData = await FirestoreService.getUserProfile(user.uid);
        setState(() {
          _userName =
              userData?['name'] ??
              userData?['displayName'] ??
              user.displayName ??
              'Student';
          _avatarUrl = userData?['avatarUrl'];
        });
      } catch (e) {
        // Error loading user profile, fallback to user display name or default
        setState(() {
          _userName = user.displayName ?? 'Student';
        });
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
        Navigator.pushNamed(context, '/profile').then((_) {
          // Reload user profile when returning from profile
          _loadUserProfile();
        });
        break;
    }
  }

  void _onStatPillTap(String type) {
    switch (type) {
      case 'streak':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _streakDays > 0
                  ? 'You have a $_streakDays day study streak!'
                  : 'Start your study streak today!',
            ),
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

  void _onCarouselPageChanged(int index) {
    setState(() {
      _currentCarouselIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF181A20)
          : AppColors.backgroundSecondary,
      body: NetworkAwareWidget(
        onRetry: () {
          _loadUserSubjects();
          _loadUserAvatar();
          _loadUserProfile();
          _loadUserStats();
        },
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSearchBar(context),
                        SizedBox(
                          height: ResponsiveHelper.getResponsivePadding(context),
                        ),
                        _buildWelcomeCard(context),
                        SizedBox(
                          height: ResponsiveHelper.getResponsivePadding(context),
                        ),
                        _buildQuickActionsSection(context),
                        SizedBox(
                          height: ResponsiveHelper.getResponsivePadding(context),
                        ),
                        _buildStatsSection(context),
                        SizedBox(
                          height: ResponsiveHelper.getResponsivePadding(context),
                        ),
                        // Demo section removed - XP popup now shows automatically when CBT tests are completed
                        SizedBox(
                          height: ResponsiveHelper.getResponsivePadding(context),
                        ),
                        _buildSubjectsSection(context),
                        SizedBox(
                          height:
                              ResponsiveHelper.getResponsivePadding(context) * 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_showXpAnimation)
              Positioned(
                top: 100,
                left: 0,
                right: 0,
                child: XpPopupWidget(
                  xpEarned: _lastXpEarned,
                  reason: 'cbt_completion',
                  onDismiss: () {
                    setState(() {
                      _showXpAnimation = false;
                    });
                    // Hide the animation in the UserStatsProvider
                    final userStatsProvider = Provider.of<UserStatsProvider>(
                      context,
                      listen: false,
                    );
                    userStatsProvider.hideXpAnimation();
                  },
                ),
              ),
            if (_showStreakAnimation)
              StreakAnimationWidget(
                streakCount: _lastStreakCount,
                onAnimationComplete: () {
                  setState(() {
                    _showStreakAnimation = false;
                  });
                },
              ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppColors.dominantPurple,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      child: Row(
        children: [
          Icon(Icons.menu_book_rounded, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Text(
            'UTME PrepMaster',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                ),
              ),
              if (_unreadNotificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      _unreadNotificationCount > 99
                          ? '99+'
                          : _unreadNotificationCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => _showProfileDropdown(context),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              backgroundImage: _avatarUrl != null
                  ? AssetImage(_avatarUrl!)
                  : null,
              child: _avatarUrl == null
                  ? Icon(Icons.person, color: Colors.white, size: 20)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileDropdown(BuildContext context) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 100,
        80,
        20,
        0,
      ),
      items: [
        PopupMenuItem(
          value: 'edit_profile',
          child: Row(
            children: [
              Icon(Icons.edit, color: AppColors.dominantPurple, size: 20),
              const SizedBox(width: 8),
              Text('Edit Profile'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Text('Logout', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'edit_profile') {
        Navigator.pushNamed(context, '/profile').then((_) {
          // Reload user profile when returning from profile
          if (mounted) {
            _loadUserProfile();
          }
        });
      } else if (value == 'logout') {
        _logout();
      }
    });
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildSearchBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2D3E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Search subjects, topics, resources...',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2D3E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Good Morning ',
                  style: TextStyle(
                    fontSize: 18,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text('☀️', style: TextStyle(fontSize: 18)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _userName.isNotEmpty ? _userName : 'Student',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Popular topics: English, Mathematics, Physics, Biology',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
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
                      imageUrl:
                          'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=400&q=80',
                      color: AppColors.accentAmber,
                      onTap: () => Navigator.pushNamed(context, '/profile'),
                    );
                  case 1:
                    return _buildCarouselCard(
                      context: context,
                      title: 'AI Tutor',
                      subtitle: 'Get personalized help',
                      imageUrl:
                          'https://images.unsplash.com/photo-1677442136019-21780ecad995?auto=format&fit=crop&w=400&q=80',
                      color: AppColors.dominantPurple,
                      onTap: () => Navigator.pushNamed(context, '/ai-tutor'),
                    );
                  case 2:
                    return _buildCarouselCard(
                      context: context,
                      title: 'Study Partner',
                      subtitle: 'Find study buddies',
                      imageUrl:
                          'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?auto=format&fit=crop&w=400&q=80',
                      color: AppColors.subjectBlue,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StudyPartnerScreen(),
                        ),
                      ),
                    );
                  default:
                    return const SizedBox.shrink();
                }
              },
            ),
          ),
          const SizedBox(height: 16),
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
                      : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Stats',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatPill(
                  icon: Icons.local_fire_department,
                  label: _streakDays > 0
                      ? '${_streakDays}d Streak'
                      : 'Start Streak',
                  color: AppColors.accentAmber,
                  isDark: isDark,
                  onTap: () => _onStatPillTap('streak'),
                ),
                const SizedBox(width: 12),
                _buildStatPill(
                  icon: Icons.emoji_events,
                  label: '$_badgeCount Badges',
                  color: AppColors.dominantPurple,
                  isDark: isDark,
                  onTap: () => _onStatPillTap('badges'),
                ),
                const SizedBox(width: 12),
                _buildStatPill(
                  icon: Icons.star,
                  label: '$_totalXp XP',
                  color: AppColors.subjectBlue,
                  isDark: isDark,
                  onTap: () => _onStatPillTap('xp'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Demo section removed - XP popup now shows automatically when CBT tests are completed

  Widget _buildSubjectsSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                  fontSize: 18,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/subject-selection',
                ).then((_) => _loadUserSubjects()),
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
          const SizedBox(height: 16),

          _loadingSubjects
              ? const LoadingCard(
                  message: 'Loading your subjects...',
                  size: 32,
                )
              : _userSubjects.isEmpty
              ? _buildEmptySubjectsState(context)
              : Column(
                  children: _userSubjects.map((subject) {
                    final progress = _subjectProgress[subject['name']];
                    final progressText = progress != null
                        ? 'Progress: ${(progress['bestScore'] ?? 0).toStringAsFixed(1)}%'
                        : 'Progress: 0%';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2A2D3E) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.3 : 0.1,
                            ),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (subject['color'] as Color).withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            subject['icon'] ?? Icons.help_outline,
                            color: subject['color'] ?? Colors.grey,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          subject['name'] ?? 'Unknown Subject',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          progressText,
                          style: TextStyle(
                            color: isDark
                                ? Colors.grey.shade300
                                : Colors.grey.shade600,
                            fontSize: 12,
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
                            style: TextStyle(fontSize: 12),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(
            Icons.subject,
            size: 60,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
          ),
          const SizedBox(height: 16),
          Text(
            'Select Your Subjects',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'English is required. Choose 3 additional subjects to get started.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(
                context,
                '/subject-selection',
              ).then((_) => _loadUserSubjects()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dominantPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Select Subjects',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
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
                  ? [const Color(0xFF2A2D3E), const Color(0xFF1F2028)]
                  : [Colors.white, Colors.grey.shade50],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
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
                          child: Icon(Icons.image, color: color, size: 24),
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
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: isDark
                              ? Colors.grey.shade300
                              : Colors.grey.shade600,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: color, size: 14),
              ],
            ),
          ),
        ),
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
          color: color.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onNavTap,
      selectedItemColor: AppColors.dominantPurple,
      unselectedItemColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Study Partner',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'CBT Tests'),
        BottomNavigationBarItem(
          icon: Icon(Icons.psychology),
          label: 'AI Tutor',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      type: BottomNavigationBarType.fixed,
      backgroundColor: isDark ? const Color(0xFF2A2D3E) : Colors.white,
      elevation: 12,
    );
  }
}
