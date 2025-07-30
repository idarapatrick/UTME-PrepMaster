import 'package:flutter/material.dart';
<<<<<<< HEAD:lib/screens/study_partner_screen.dart
import '../models/study_partner.dart';
import '../theme/app_colors.dart';
import 'chat_screen.dart';

class StudyPartnerScreen extends StatefulWidget {
  const StudyPartnerScreen({Key? key}) : super(key: key);

  @override
  _StudyPartnerScreenState createState() => _StudyPartnerScreenState();
}

class _StudyPartnerScreenState extends State<StudyPartnerScreen> {
  List<StudyPartner> availablePartners = [
    StudyPartner(
      id: 'uid1',
      name: 'Alice',
      subject: StudyPartnerSubject.science,
      goal: 'Improve Physics',
      interests: ['Quantum', 'Math'],
      status: StudyPartnerStatus.pending,
    ),
    StudyPartner(
      id: 'uid2',
      name: 'Ben',
      subject: StudyPartnerSubject.science,
      goal: 'Master History',
      interests: ['Ancient', 'War'],
      status: StudyPartnerStatus.pending,
    ),
  ];

  void acceptMatch(StudyPartner partner) {
    setState(() {
      partner.status = StudyPartnerStatus.matched;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(partner: partner),
      ),
    );
  }

  void rejectMatch(StudyPartner partner) {
    setState(() {
      availablePartners.remove(partner);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        title: const Text('Find a Study Partner'),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        children: availablePartners.map((partner) {
          return buildPartnerCard(partner);
        }).toList(),
      ),
    );
  }

  Widget buildPartnerCard(StudyPartner partner) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.backgroundPrimary,
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(partner.name,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text('Subject: ${partner.subject.name}',
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Text('Goal: ${partner.goal}',
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: partner.interests.map((i) {
                return Chip(
                  label: Text(i),
                  backgroundColor: AppColors.backgroundTertiary,
                  labelStyle: const TextStyle(color: AppColors.textTertiary),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () => acceptMatch(partner),
                  icon: const Icon(Icons.check),
                  label: const Text("Accept"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => rejectMatch(partner),
                  icon: const Icon(Icons.close),
                  label: const Text("Reject"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                )
              ],
            )
=======
import '../theme/app_colors.dart';

class StudyPartnerScreen extends StatelessWidget {
  const StudyPartnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Partner'),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
      ),
      backgroundColor: isDark
          ? const Color(0xFF181A20)
          : AppColors.backgroundPrimary,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state illustration
            Icon(
              Icons.people_outline,
              size: 80,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 24),
            Text(
              'No Study Partner Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You haven\'t been matched with a study partner yet. Study partners are automatically matched based on your subjects and study schedule.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            // Feature cards
            Card(
              color: isDark ? const Color(0xFF23243B) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: AppColors.dominantPurple,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Smart Matching',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We match you with study partners who share similar subjects and study goals.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: isDark ? const Color(0xFF23243B) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: AppColors.dominantPurple,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Study Together',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Schedule study sessions, share notes, and motivate each other to achieve your goals.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement study partner matching logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Study partner matching coming soon!'),
                    ),
                  );
                },
                icon: const Icon(Icons.person_add),
                label: const Text('Find Study Partner'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dominantPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
>>>>>>> 563132adc050a79d9fc922ee7d7b66b8f2079e18:lib/presentation/screens/study_partner_screen.dart
          ],
        ),
      ),
    );
  }
<<<<<<< HEAD:lib/screens/study_partner_screen.dart
}
=======
} 
>>>>>>> 563132adc050a79d9fc922ee7d7b66b8f2079e18:lib/presentation/screens/study_partner_screen.dart
