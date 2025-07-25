import 'package:flutter/material.dart';
import '../models/study_partner.dart';
import '../theme/app_colors.dart';
import 'chat_screen.dart';

class MatchedPartnersScreen extends StatelessWidget {
  final List<StudyPartner> matchedPartners = [
    StudyPartner(
      id: '1',
      name: 'Alice M.',
      subject: StudyPartnerSubject.literature,
      goal: 'Revise past papers',
      interests: ['Genetics', 'Evolution'],
      status: StudyPartnerStatus.matched,
    ),
    StudyPartner(
      id: '2',
      name: 'Daniel K.',
      subject: StudyPartnerSubject.biology,
      goal: 'Debate key topics',
      interests: ['World Wars', 'African History'],
      status: StudyPartnerStatus.matched,
    ),
  ];

  Color getSubjectColor(StudyPartnerSubject subject) {
    switch (subject) {
      case StudyPartnerSubject.biology:
      case StudyPartnerSubject.mathematics:
        return AppColors.subjectBlue;
      case StudyPartnerSubject.chemistry:
        return AppColors.subjectGreen;
      case StudyPartnerSubject.science:
        return AppColors.subjectRed;
      default:
        return AppColors.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.dominantPurple,
        title: const Text(
          'Matched Study Partners',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: matchedPartners.isEmpty
          ? const Center(
              child: Text(
                'No matched partners yet.',
                style: TextStyle(color: AppColors.textTertiary),
              ),
            )
          : ListView.builder(
              itemCount: matchedPartners.length,
              itemBuilder: (context, index) {
                final partner = matchedPartners[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: AppColors.borderLight),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: getSubjectColor(partner.subject),
                      child: Text(
                        partner.name[0],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      partner.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Subject: ${partner.subject.name}',
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Goal: ${partner.goal}',
                          style: const TextStyle(color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.chat, color: AppColors.dominantPurple),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(partner: partner),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
