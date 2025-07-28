import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_colors.dart';
import '../services/firestore_service.dart';
import '../widgets/subject_card.dart';
import 'profile_screen.dart';
import 'course_content_screen.dart';

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
      'title': "Today's Challenge",
      'subtitle': 'Complete a mock test for 250 XP',
      'image':
          'https://images.unsplash.com/photo-1513258496099-48168024aec0?auto=format&fit=crop&w=600&q=80',
    },
    {
      'title': 'Tip of the Day',
      'subtitle': 'Practice makes perfect. Try a mock test!',
      'image':
          'https://images.unsplash.com/photo-1464983953574-0892a716854b?auto=format&fit=crop&w=600&q=80',
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
        break;
      case 1:
        Navigator.pushNamed(context, '/explore');
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

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.dominantPurple,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 16), // Add left padding
          child: Row(
            children: [
              const Icon(
                Icons.menu_book_rounded,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'UTME PrepMaster',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Center(
              child: IconButton(
                icon: const Icon(Icons.notifications_none, size: 22),
                tooltip: 'Notifications',
                onPressed: () {},
                splashRadius: 22,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12, left: 0),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  _showAvatarGallery(context);
                },
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white,
                  backgroundImage: _avatarUrl != null && _avatarUrl!.isNotEmpty
                      ? NetworkImage(_avatarUrl!)
                      : null,
                  child: _avatarUrl == null || _avatarUrl!.isEmpty
                      ? Icon(
                          Icons.person,
                          color: AppColors.dominantPurple,
                          size: 18,
                        )
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.only(top: 18, bottom: 12),
            child: Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(14),
              child: TextField(
                readOnly: true,
                onTap: () {},
                style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Search subjects, topics, resources...',
                  hintStyle: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 16,
                  ),
                  prefixIcon: Icon(Icons.search, color: AppColors.textTertiary),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 0,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          // Greeting and user info card (compact, white background)
          Card(
            color: cardColor,
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
                      fontSize: 14,
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
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        'Popular topics: ',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
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
                            fontSize: 13,
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
          // Stat pills row (compact, rounded, spaced)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
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
          ),
          // Carousel card (white background, compact)
          SizedBox(
            height: 120,
            child: PageView.builder(
              itemCount: _carouselItems.length,
              controller: PageController(viewportFraction: 0.92),
              onPageChanged: (i) => setState(() => _carouselIndex = i),
              itemBuilder: (context, index) {
                final item = _carouselItems[index];
                return Card(
                  color: cardColor,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(14),
                        ),
                        child: Image.network(
                          item['image']!,
                          width: 90,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title']!,
                                style: TextStyle(
                                  color: AppColors.dominantPurple,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item['subtitle']!,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Carousel indicators
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _carouselItems.length,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _carouselIndex == i
                        ? AppColors.dominantPurple
                        : AppColors.textTertiary.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ),
          // Subjects section
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subjects',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark
                        ? Colors.white
                        : AppColors.textPrimary, // High contrast for dark mode
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/subject-selection',
                  ).then((_) => _loadUserSubjects()),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size(0, 0),
                  ),
                  child: Text(
                    'Edit',
                    style: TextStyle(
                      color: AppColors.dominantPurple,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _loadingSubjects
              ? const Center(child: CircularProgressIndicator())
              : _userSubjects.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      '/subject-selection',
                    ).then((_) => _loadUserSubjects()),
                    child: const Text('Select Subjects'),
                  ),
                )
              : Column(
                  children: _userSubjects.map((subject) {
                    final name = subject['name'] as String;
                    final icon = subject['icon'] as IconData;
                    final color = subject['color'] as Color;
                    final imageUrl =
                        kSubjectImages[name] ?? kSubjectImages['English']!;
                    final progress = _subjectProgress[name];
                    final progressText = progress != null
                        ? 'Best:   a0${(progress['bestScore'] ?? 0).toStringAsFixed(1)} | Correct: ${progress['correct'] ?? 0} / ${progress['attempted'] ?? 0}'
                        : 'Progress: 0%';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SubjectCard(
                        name: name,
                        icon: icon,
                        imageUrl: imageUrl,
                        accentColor: color,
                        progressText: progressText,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CourseContentScreen(subject: name),
                            ),
                          ).then((_) => _loadUserSubjects());
                        },
                        trailing: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CourseContentScreen(subject: name),
                              ),
                            ).then((_) => _loadUserSubjects());
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : AppColors.dominantPurple,
                            side: BorderSide(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : AppColors.dominantPurple,
                            ),
                            minimumSize: const Size(0, 32),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 0,
                            ),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'View Course',
                            style: TextStyle(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : AppColors.dominantPurple,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
          const SizedBox(height: 18),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        selectedItemColor: AppColors.dominantPurple,
        unselectedItemColor: AppColors.secondaryGray,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Mock Test'),
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
                              size: 28,
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
