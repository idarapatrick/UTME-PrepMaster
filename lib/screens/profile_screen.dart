import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_colors.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';
import 'edit_profile_screen.dart';
import 'leaderboard_screen.dart';
import 'my_library_screen.dart';

// Add a list of avatar URLs (DiceBear, diverse styles)
const List<Map<String, String>> kAvatars = [
  // Boy avatars
  {
    'url':
        'https://api.dicebear.com/6.x/adventurer/svg?seed=boy1&skinColor=bf8b5a',
    'label': 'Boy 1',
  },
  {
    'url':
        'https://api.dicebear.com/6.x/adventurer/svg?seed=boy2&skinColor=8d5524',
    'label': 'Boy 2',
  },
  {
    'url':
        'https://api.dicebear.com/6.x/adventurer/svg?seed=boy3&skinColor=c68642',
    'label': 'Boy 3',
  },
  // Girl avatars
  {
    'url':
        'https://api.dicebear.com/6.x/adventurer/svg?seed=girl1&skinColor=fd9841',
    'label': 'Girl 1',
  },
  {
    'url':
        'https://api.dicebear.com/6.x/adventurer/svg?seed=girl2&skinColor=ffdbac',
    'label': 'Girl 2',
  },
  {
    'url':
        'https://api.dicebear.com/6.x/adventurer/svg?seed=girl3&skinColor=614335',
    'label': 'Girl 3',
  },
  // Hijabi avatars (using 'micah' style with hijab)
  {
    'url':
        'https://api.dicebear.com/6.x/micah/svg?seed=hijabi1&skinColor=ae5d29&clothing=hijab',
    'label': 'Hijabi 1',
  },
  {
    'url':
        'https://api.dicebear.com/6.x/micah/svg?seed=hijabi2&skinColor=ffdbb4&clothing=hijab',
    'label': 'Hijabi 2',
  },
  {
    'url':
        'https://api.dicebear.com/6.x/micah/svg?seed=hijabi3&skinColor=614335&clothing=hijab',
    'label': 'Hijabi 3',
  },
];

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _avatarUrl = kAvatars[Random().nextInt(kAvatars.length)]['url']!;
  @override
  void initState() {
    super.initState();
    // TODO: Load avatar from Firestore/user profile if available
  }

  void _changeAvatar() async {
    final url = await showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose Your Avatar',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  shrinkWrap: true,
                  children: kAvatars
                      .map(
                        (a) => GestureDetector(
                          onTap: () => Navigator.of(context).pop(a['url']),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _avatarUrl == a['url']
                                    ? AppColors.accentAmber
                                    : Colors.transparent,
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                a['url']!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (url != null && url != _avatarUrl) {
      setState(() => _avatarUrl = url);
      // TODO: Save avatar to Firestore/user profile
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
      ),
      backgroundColor: isDark
          ? const Color(0xFF181A20)
          : AppColors.backgroundPrimary,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _changeAvatar,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.dominantPurple.withOpacity(0.1),
                    backgroundImage: NetworkImage(_avatarUrl),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _changeAvatar,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.accentAmber,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit Profile'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.dominantPurple,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user?.email ?? 'Guest Account',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.dominantPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user?.isAnonymous == true ? 'Guest Account' : 'Registered User',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatCard(Icons.local_fire_department, 'Streak', '7 days'),
                const SizedBox(width: 16),
                _buildStatCard(Icons.emoji_events, 'Badges', '12'),
                const SizedBox(width: 16),
                _buildStatCard(Icons.timer, 'Study Time', '5h'),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  // Badges
                  ListTile(
                    leading: const Icon(
                      Icons.emoji_events,
                      color: AppColors.accentAmber,
                    ),
                    title: const Text(
                      'Badges',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentAmber,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '12',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () => Navigator.pushNamed(context, '/badges'),
                  ),
                  // Leaderboard
                  ListTile(
                    leading: const Icon(
                      Icons.leaderboard,
                      color: AppColors.dominantPurple,
                    ),
                    title: const Text(
                      'Leaderboard',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LeaderboardScreen(),
                      ),
                    ),
                  ),
                  // LifeAt
                  ListTile(
                    leading: const Icon(
                      Icons.music_note,
                      color: AppColors.secondaryGray,
                    ),
                    title: const Text(
                      'LifeAt',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () async {
                      final url = Uri.parse('https://lifeat.io');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.inAppWebView);
                      }
                    },
                  ),
                  // Settings
                  ListTile(
                    leading: const Icon(
                      Icons.settings,
                      color: AppColors.secondaryGray,
                    ),
                    title: const Text(
                      'Settings',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () => Navigator.pushNamed(context, '/settings'),
                  ),
                  // My Library
                  ListTile(
                    leading: const Icon(
                      Icons.library_books,
                      color: AppColors.dominantPurple,
                    ),
                    title: const Text(
                      'My Library',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyLibraryScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 4,
        onTap: (index) {
          // Handle navigation
        },
        selectedItemColor: AppColors.dominantPurple,
        unselectedItemColor: AppColors.secondaryGray,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Leaderboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Library',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? const Color(0xFF23243B) : Colors.white,
        elevation: 12,
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.dominantPurple, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
            Text(value, style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
