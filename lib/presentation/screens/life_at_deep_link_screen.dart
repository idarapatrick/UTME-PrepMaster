import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';

class LifeAtDeepLinkScreen extends StatelessWidget {
  const LifeAtDeepLinkScreen({super.key});

  Future<void> _openLifeAt(String feature) async {
    String url;

    switch (feature) {
      case 'pomodoro':
        url = 'https://lifeat.io/pomodoro';
        break;
      case 'focus':
        url = 'https://lifeat.io/focus';
        break;
      case 'study':
        url = 'https://lifeat.io/study';
        break;
      case 'music':
        url = 'https://lifeat.io/music';
        break;
      default:
        url = 'https://lifeat.io/';
    }

    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: const Text(
          'LifeAt Integration',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.dominantPurple,
                    AppColors.dominantPurple.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.dominantPurple.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(Icons.open_in_new, size: 60, color: Colors.white),
                  const SizedBox(height: 16),
                  const Text(
                    'Open LifeAt in Browser',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Access LifeAt features directly in your device\'s browser',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Feature Cards
            _buildFeatureCard(
              context,
              'Pomodoro Timer',
              'Focus with 25/5 minute cycles',
              Icons.timer,
              () => _openLifeAt('pomodoro'),
            ),

            const SizedBox(height: 16),

            _buildFeatureCard(
              context,
              'Focus Mode',
              'Distraction-free study environment',
              Icons.psychology,
              () => _openLifeAt('focus'),
            ),

            const SizedBox(height: 16),

            _buildFeatureCard(
              context,
              'Study Rooms',
              'Virtual study spaces with others',
              Icons.people,
              () => _openLifeAt('study'),
            ),

            const SizedBox(height: 16),

            _buildFeatureCard(
              context,
              'Background Music',
              'Curated focus playlists',
              Icons.music_note,
              () => _openLifeAt('music'),
            ),

            const SizedBox(height: 16),

            _buildFeatureCard(
              context,
              'LifeAt Home',
              'Open main LifeAt platform',
              Icons.home,
              () => _openLifeAt('home'),
            ),

            const SizedBox(height: 24),

            // Info Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.dominantPurple,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'How it works:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Tap any feature to open LifeAt in your browser\n'
                    '• Use your device\'s native browser for best performance\n'
                    '• No in-app browser issues or media codec problems\n'
                    '• Full access to all LifeAt features',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.dominantPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.dominantPurple, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textTertiary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
