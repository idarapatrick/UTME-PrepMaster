import 'package:flutter/material.dart';
import '../models/study_partner.dart';
import '../theme/app_colors.dart';
import 'chat_screen.dart';
import '../services/firestore_service.dart';


class MatchedPartnersScreen extends StatefulWidget {
  @override
  _MatchedPartnersScreenState createState() => _MatchedPartnersScreenState();
}

class _MatchedPartnersScreenState extends State<MatchedPartnersScreen> {
  
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<StudyPartner>> _matchedPartnersFuture;
  
  Color getSubjectColor(String subject) {
  switch (subject.toLowerCase()) {
    case 'math':
      return Colors.blue;
    case 'english':
      return Colors.green;
    case 'physics':
      return Colors.deepPurple;
    case 'chemistry':
      return Colors.orange;
    default:
      return Colors.grey;
  }
}


  @override
  void initState() {
    super.initState();
    _matchedPartnersFuture = _firestoreService. getMatchedPartners();
  }

  Color getBackgroundColor(bool isAccepted) {
  if (isAccepted) {
    return Colors.green;
  } else {
    return Colors.red;
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
      body: FutureBuilder<List<StudyPartner>>(
        future: _matchedPartnersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error loading matched partners'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No matched partners yet.',
                style: TextStyle(color: AppColors.textTertiary),
              ),
            );
          }

          final matchedPartners = snapshot.data!;

          return ListView.builder(
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
                    backgroundColor:getSubjectColor(partner.subject.name),
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
                        'Subject: ${partner.subjectText}',
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
          );
        },
      ),
    );
  }
}
