import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../providers/user_stats_provider.dart';
import '../../data/services/firestore_service.dart';
import '../../data/utme_subjects.dart';
import '../widgets/achievement_badge.dart';
import '../widgets/streak_animation_widget.dart';
import '../widgets/xp_animation_widget.dart';
import '../utils/responsive_helper.dart';
import '../widgets/subject_card.dart';
import '../widgets/badge_animation_widget.dart';
import 'profile_screen.dart';
import 'course_content_screen.dart';
import 'life_at_info_screen.dart';
import 'study_partner_screen.dart';

const List<Map<String, dynamic>> kUtmeSubjects = [
  {
    'name': 'English',
    'icon': Icons.language,
    'color': AppColors.dominantPurple,
  },
  {
    'name': 'Mathematics',
    'icon': Icons.calculate,
    'color': AppColors.subjectBlue,
  },
  {'name': 'Physics', 'icon': Icons.science, 'color': AppColors.subjectBlue},
  {
    'name': 'Chemistry',
    'icon': Icons.bubble_chart,
    'color': AppColors.subjectBlue,
  },
  {'name': 'Biology', 'icon': Icons.biotech, 'color': AppColors.subjectBlue},
  {
    'name': 'Literature-in-English',
    'icon': Icons.menu_book,
    'color': AppColors.subjectRed,
  },
  {
    'name': 'Government',
    'icon': Icons.account_balance,
    'color': AppColors.subjectGreen,
  },
  {
    'name': 'Economics',
    'icon': Icons.trending_up,
    'color': AppColors.subjectGreen,
  },
  {
    'name': 'Accounting',
    'icon': Icons.receipt_long,
    'color': AppColors.subjectGreen,
  },
  {
    'name': 'Marketing',
    'icon': Icons.campaign,
    'color': AppColors.subjectGreen,
  },
  {'name': 'Geography', 'icon': Icons.public, 'color': AppColors.subjectGreen},
  {
    'name': 'Computer Studies',
    'icon': Icons.computer,
    'color': AppColors.subjectBlue,
  },
  {
    'name': 'Christian Religious Studies',
    'icon': Icons.church,
    'color': AppColors.subjectRed,
  },
  {
    'name': 'Islamic Studies',
    'icon': Icons.mosque,
    'color': AppColors.subjectRed,
  },
  {
    'name': 'Agricultural Science',
    'icon': Icons.agriculture,
    'color': AppColors.subjectGreen,
  },
  {'name': 'Commerce', 'icon': Icons.store, 'color': AppColors.subjectGreen},
  {'name': 'History', 'icon': Icons.history_edu, 'color': AppColors.subjectRed},
];

// Add a map of subject name to image URL at the top:
const Map<String, String> kSubjectImages = {
  'English':
      'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=400&q=80',
  'Mathematics':
      'https://images.unsplash.com/photo-1509228468518-180dd4864904?auto=format&fit=crop&w=400&q=80',
  'Physics':
      'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=400&q=80',
  'Chemistry':
      'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
  'Biology':
      'https://images.unsplash.com/photo-1464983953574-0892a716854b?auto=format&fit=crop&w=400&q=80',
  'Literature-in-English':
      'https://images.unsplash.com/photo-1516979187457-637abb4f9353?auto=format&fit=crop&w=400&q=80',
  'Government':
      'https://images.unsplash.com/photo-1503676382389-4809596d5290?auto=format&fit=crop&w=400&q=80',
  'Economics':
      'https://images.unsplash.com/photo-1464983953574-0892a716854b?auto=format&fit=crop&w=400&q=80',
  'Accounting':
      'https://images.unsplash.com/photo-1515168833906-d2a3b82b1a48?auto=format&fit=crop&w=400&q=80',
  'Marketing':
      'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
  'Geography':
      'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
  'Computer Studies':
      'https://images.unsplash.com/photo-1519389950473-47ba0277781c?auto=format&fit=crop&w=400&q=80',
  'Christian Religious Studies':
      'https://images.unsplash.com/photo-1465101178521-c1a9136a3b99?auto=format&fit=crop&w=400&q=80',
  'Islamic Studies':
      'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
  'Agricultural Science':
      'https://images.unsplash.com/photo-1464983953574-0892a716854b?auto=format&fit=crop&w=400&q=80',
  'Commerce':
      'https://images.unsplash.com/photo-1515168833906-d2a3b82b1a48?auto=format&fit=crop&w=400&q=80',
  'History':
      'https://images.unsplash.com/photo-1516979187457-637abb4f9353?auto=format&fit=crop&w=400&q=80',
};

const List<String> kAvatarGallery = [
  // DiceBear Avatars (boy, girl, hijabi, various skin tones)
  'https://api.dicebear.com/7.x/adventurer/svg?seed=boy1',
  'https://api.dicebear.com/7.x/adventurer/svg?seed=boy2',
  'https://api.dicebear.com/7.x/adventurer/svg?seed=boy3',
  'https://api.dicebear.com/7.x/adventurer/svg?seed=girl1',
  'https://api.dicebear.com/7.x/adventurer/svg?seed=girl2',
  'https://api.dicebear.com/7.x/adventurer/svg?seed=hijabi1',
  'https://api.dicebear.com/7.x/adventurer/svg?seed=hijabi2',
  'https://api.dicebear.com/7.x/adventurer/svg?seed=boy4',
  'https://api.dicebear.com/7.x/adventurer/svg?seed=girl3',
  'https://api.dicebear.com/7.x/adventurer/svg?seed=boy5',
  'https://api.dicebear.com/7.x/adventurer/svg?seed=girl4',
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int _carouselIndex = 0;
  List<Map<String, dynamic>> _userSubjects = [];
  bool _loadingSubjects = true;
  Map<String, Map<String, dynamic>> _subjectProgress = {};
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUserSubjects();
    _loadAvatar();
    // Initialize user stats
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userStatsProvider = Provider.of<UserStatsProvider>(context, listen: false);
      userStatsProvider.initializeUserStats();
    });
  }

  Future<void> _loadUserSubjects() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final selected = await FirestoreService.loadUserSubjects(user.uid);
      final progress = <String, Map<String, dynamic>>{};
      for (final subject in selected) {
        final data = await FirestoreService.loadSubjectProgress(user.uid, subject);
        if (data != null) progress[subject] = data;
      }
      setState(() {
        _userSubjects = kUtmeSubjects
            .where((s) => selected.contains(s['name']))
            .toList();
        _subjectProgress = progress;
        _loadingSubjects = false;
      });
    } else {
      setState(() => _loadingSubjects = false);
    }
  }

  Future<void> _loadAvatar() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirestoreService.getUserProfile(user.uid);
      setState(() {
        _avatarUrl = doc?['photoUrl'] as String?;
      });
    }
  }

  Future<void> _setAvatar(String url) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirestoreService.updateUserProfile(user.uid, {'avatarUrl': url});
      setState(() {
        _avatarUrl = url;
      });
    }
  }

  final List<Map<String, String>> _carouselItems = [
    {
      'title': "Today's CBT Challenge",
      'subtitle': 'Complete a mock CBT test for 250 XP',
      'image':
          'https://images.unsplash.com/photo-1513258496099-48168024aec0?auto=format&fit=crop&w=600&q=80',
    },
    {
      'title': 'LifeAt Study',
      'subtitle': 'Focus with Pomodoro timer & background music',
      'image':
          'https://images.unsplash.com/photo-1503676382389-4809596d5290?auto=format&fit=crop&w=600&q=80',
    },
    {
      'title': 'AI Tutor',
      'subtitle': 'Get instant help with tough questions.',
      'image':
          'https://images.unsplash.com/photo-1503676382389-4809596d5290?auto=format&fit=crop&w=600&q=80',
    },
  ];

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        // Already on home screen
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
    }
  }

  void _onCarouselItemTap(int index) {
    switch (index) {
      case 0: // Today's Challenge
        Navigator.pushNamed(context, '/mock-test');
        break;
      case 1: // LifeAt Study
        print('DEBUG: LifeAt carousel item tapped');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LifeAtInfoScreen()),
        );
        break;
      case 2: // AI Tutor
        Navigator.pushNamed(context, '/ai-tutor');
        break;
    }
  }

  Widget mainProgressCard(Color cardColor, Color textColor) {
    final mainSubject = _userSubjects.isNotEmpty ? _userSubjects.first : null;
    if (mainSubject == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mainSubject['name'],
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'UTME Subject',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          value:
                              _subjectProgress[mainSubject['name']] != null &&
                                  (_subjectProgress[mainSubject['name']]!['attempted'] ??
                                          0) >
                                      0
                              ? (_subjectProgress[mainSubject['name']]!['attempted'] /
                                    (mainSubject['name'] == 'English'
                                        ? 60
                                        : 40))
                              : 0,
                          strokeWidth: 6,
                          backgroundColor: AppColors.borderLight,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.dominantPurple,
                          ),
                        ),
                      ),
                      Text(
                        _subjectProgress[mainSubject['name']] != null &&
                                (_subjectProgress[mainSubject['name']]!['attempted'] ??
                                        0) >
                                    0
                            ? '${((_subjectProgress[mainSubject['name']]!['attempted'] / (mainSubject['name'] == 'English' ? 60 : 40)) * 100).toStringAsFixed(0)}%'
                            : '0%',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CourseContentScreen(
                              subject: mainSubject['name'],
                            ),
                          ),
                        ).then((_) => _loadUserSubjects());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentAmber,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Continue Learning'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        await FirestoreService.saveSubjectProgress(
                          user.uid,
                          {mainSubject['name']: 0.0},
                        );
                        setState(
                          () => _subjectProgress[mainSubject['name']] = {
                            'attempted': 0,
                            'correct': 0,
                            'bestScore': 0,
                          },
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.dominantPurple,
                      side: const BorderSide(color: AppColors.dominantPurple),
                    ),
                    child: const Text('Reset Progress'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? const Color(0xFF181A20)
        : AppColors.backgroundSecondary;
    final cardColor = Colors.white;
    
    // Get user stats provider
    final userStatsProvider = Provider.of<UserStatsProvider>(context);
    final userStats = userStatsProvider.userStats;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.dominantPurple,
        titleSpacing: 0,
        automaticallyImplyLeading: false, // Prevent back arrow from showing
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
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.isMobile(context) ? 4 : 8
            ),
            child: Center(
              child: IconButton(
                icon: Icon(
                  Icons.notifications_none, 
                  size: ResponsiveHelper.getResponsiveIconSize(context, 22)
                ),
                tooltip: 'Notifications',
                onPressed: () {},
                splashRadius: ResponsiveHelper.getResponsiveIconSize(context, 22),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              right: ResponsiveHelper.isMobile(context) ? 12 : 16, 
              left: 0
            ),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  _showAvatarGallery(context);
                },
                child: CircleAvatar(
                  radius: ResponsiveHelper.getResponsiveIconSize(context, 16),
                  backgroundColor: Colors.white,
                  backgroundImage: _avatarUrl != null && _avatarUrl!.isNotEmpty
                      ? NetworkImage(_avatarUrl!)
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
          ),
        ],
      ),
      body: ResponsiveHelper.responsiveSingleChildScrollView(
        context: context,
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: EdgeInsets.only(
                top: ResponsiveHelper.getResponsivePadding(context), 
                bottom: ResponsiveHelper.getResponsivePadding(context) / 2
              ),
              child: Material(
                elevation: 3,
                borderRadius: BorderRadius.circular(14),
                child: TextField(
                  readOnly: true,
                  onTap: () {},
                  style: TextStyle(
                    color: AppColors.textPrimary, 
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16)
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search subjects, topics, resources...',
                    hintStyle: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                    ),
                    prefixIcon: Icon(
                      Icons.search, 
                      color: AppColors.textTertiary,
                      size: ResponsiveHelper.getResponsiveIconSize(context, 20),
                    ),
                    filled: true,
                    fillColor: Colors.white,
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
            _buildWelcomeSection(context, user, userStats, isDark),

            // Quick Actions
            _buildQuickActionsSection(context, isDark),

            // Subject Progress
            _buildSubjectProgressSection(context, isDark),

            // Recent Activity
            _buildRecentActivitySection(context, isDark),

            // Bottom spacing
            SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
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

  Widget _buildWelcomeSection(BuildContext context, User? user, dynamic userStats, bool isDark) {
    return Padding(
      padding: ResponsiveHelper.getResponsiveHorizontalPadding(context),
      child: Card(
        color: Colors.white,
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
                  color: AppColors.textSecondary,
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
                  color: AppColors.textPrimary,
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
                      color: AppColors.textSecondary,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 13),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _userSubjects.isNotEmpty
                          ? _userSubjects
                              .map((s) => s['name'])
                              .take(4)
                              .join(', ')
                          : 'Use of English',
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

  Widget _buildQuickActionsSection(BuildContext context, bool isDark) {
    return Padding(
      padding: ResponsiveHelper.getResponsiveHorizontalPadding(context),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildStatPill(
              icon: Icons.local_fire_department,
              label: '7d Streak',
              color: AppColors.accentAmber,
              isDark: false,
            ),
            const SizedBox(width: 10),
            _buildStatPill(
              icon: Icons.emoji_events,
              label: 'Badges',
              color: AppColors.dominantPurple,
              isDark: false,
            ),
            const SizedBox(width: 10),
            _buildStatPill(
              icon: Icons.flag,
              label: 'Daily Challenge',
              color: AppColors.secondaryGray,
              isDark: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectProgressSection(BuildContext context, bool isDark) {
    return Padding(
      padding: ResponsiveHelper.getResponsiveHorizontalPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Subjects',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
          
          // Subjects grid
          _loadingSubjects
              ? const Center(child: CircularProgressIndicator())
              : _userSubjects.isEmpty
                  ? _buildEmptySubjectsState(context, isDark)
                  : ResponsiveHelper.responsiveGridView(
                      context: context,
                      children: _userSubjects.map((subject) {
                        return SubjectCard(
                          name: subject['name'] as String,
                          icon: subject['icon'] as IconData,
                          imageUrl: subject['imageUrl'] as String,
                          accentColor: subject['color'] as Color,
                          progressText: _getSubjectProgressText(subject['name'] as String),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/course-content',
                              arguments: subject['name'],
                            );
                          },
                        );
                      }).toList(),
                    ),
        ],
      ),
    );
  }

  Widget _buildEmptySubjectsState(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(
            Icons.subject,
            size: ResponsiveHelper.getResponsiveIconSize(context, 60),
            color: AppColors.textTertiary,
          ),
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
          Text(
            'No subjects selected yet!',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context) / 2),
          Text(
            'Tap "Edit" above or "Select Subjects" to get started.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
              color: AppColors.textSecondary,
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

  String _getSubjectProgressText(String subjectName) {
    final progress = _subjectProgress[subjectName];
    if (progress != null) {
      return 'Best: ${(progress['bestScore'] ?? 0).toStringAsFixed(1)} | Correct: ${progress['correct'] ?? 0} / ${progress['attempted'] ?? 0}';
    }
    return 'Progress: 0%';
  }

  Widget _buildRecentActivitySection(BuildContext context, bool isDark) {
    return Padding(
      padding: ResponsiveHelper.getResponsiveHorizontalPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
              color: isDark
                  ? Colors.white
                  : AppColors.textPrimary, // High contrast for dark mode
            ),
          ),
          const SizedBox(height: 10),
          // Placeholder for recent activity items
          // This section would typically display achievements, streaks, etc.
          // For now, it's just a placeholder.
          // In a real app, you'd fetch and display actual activity data.
          // Example:
          // _buildRecentActivityItem(
          //   icon: Icons.emoji_events,
          //   label: 'New Badge Earned: ${userStatsProvider.lastBadgeEarned}',
          //   color: AppColors.dominantPurple,
          //   isDark: isDark,
          // ),
          // _buildRecentActivityItem(
          //   icon: Icons.trending_up,
          //   label: 'Streak: ${userStatsProvider.lastStreakCount}',
          //   color: AppColors.accentAmber,
          //   isDark: isDark,
          // ),
          // _buildRecentActivityItem(
          //   icon: Icons.lightbulb_outline,
          //   label: 'XP Earned: ${userStatsProvider.lastXpEarned}',
          //   color: AppColors.subjectBlue,
          //   isDark: isDark,
          // ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityItem({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: ResponsiveHelper.getResponsiveIconSize(context, 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
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
  }) {
    return Container(
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
                      }
                    },
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      backgroundImage: NetworkImage(url),
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
  
  // Animation overlays
  Widget _buildAnimationOverlays() {
    final userStatsProvider = Provider.of<UserStatsProvider>(context);
    
    return Stack(
      children: [
        // XP Animation
        if (userStatsProvider.showXpAnimation)
          Positioned.fill(
            child: XpAnimationWidget(
              xpEarned: userStatsProvider.lastXpEarned,
              onAnimationComplete: () {
                userStatsProvider.hideXpAnimation();
              },
            ),
          ),
        
        // Streak Animation
        if (userStatsProvider.showStreakAnimation)
          Positioned.fill(
            child: StreakAnimationWidget(
              streakCount: userStatsProvider.lastStreakCount,
              onAnimationComplete: () {
                userStatsProvider.hideStreakAnimation();
              },
            ),
          ),
        
        // Badge Animation
        if (userStatsProvider.showBadgeAnimation && userStatsProvider.lastBadgeEarned != null)
          Positioned.fill(
            child: BadgeAnimationWidget(
              badgeName: userStatsProvider.lastBadgeEarned!,
              onAnimationComplete: () {
                userStatsProvider.hideBadgeAnimation();
              },
            ),
          ),
      ],
    );
  }
}
