import 'package:flutter/material.dart';
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
          ],
        ),
      ),
    );
  }
}
