import 'package:flutter/material.dart';
import '../../domain/models/study_partner.dart';
import '../theme/app_colors.dart';

class PartnerCard extends StatelessWidget {
  final StudyPartner partner;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const PartnerCard({
    Key? key,
    required this.partner,
    required this.onAccept,
    required this.onReject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.subjectBlue,
          child: Icon(
            Icons.person,
            color: Colors.white,
          ),
        ),
        title: Text(
          partner.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(partner.status),
                shape: BoxShape.circle,
              ),
            ),
            Text(
              partner.statusText,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(width: 10),
            Text(
              partner.subjectText,
              style: TextStyle(color: AppColors.textTertiary),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.check_circle, color: Colors.green),
              onPressed: onAccept,
              tooltip: "Accept",
            ),
            IconButton(
              icon: Icon(Icons.cancel, color: Colors.red),
              onPressed: onReject,
              tooltip: "Reject",
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(StudyPartnerStatus status) {
    switch (status) {
      case StudyPartnerStatus.available:
        return Colors.green;
      case StudyPartnerStatus.studying:
        return Colors.orange;
      case StudyPartnerStatus.idle:
      default:
        return Colors.grey;
    }
  }
}
