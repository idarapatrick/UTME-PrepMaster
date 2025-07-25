import 'package:flutter/material.dart';

enum StudyPartnerStatus {
  pending,
  matched,
  rejected,
  available, 
  idle,
  studying,
}
enum StudyPartnerSubject {
  science,
  literature,
  government,
  biology,
  chemistry,
  mathematics,
  economics,
}

class StudyPartner {
  final String id;
  final String name;
  final StudyPartnerStatus status;
  final StudyPartnerSubject subject;
  final String goal;
  final List<String> interests;

  StudyPartner({
    required this.id,
    required this.name,
    required this.status,
    required this.subject,
    required this.goal,
    required this.interests,
  });

  // For UI display
  String get statusText {
    switch (status) {
  case StudyPartnerStatus.available:
    return 'Available';
  case StudyPartnerStatus.matched:
    return 'Matched';
  case StudyPartnerStatus.rejected:
    return 'Rejected';
  case StudyPartnerStatus.pending:   
    return 'Pending';
     case StudyPartnerStatus.idle:   
    return 'Pending';
     case StudyPartnerStatus.studying:   
    return 'Pending';
  // OR use default:
  // default:
  //   return 'Unknown status';
}
  }

  // You can map subjects to nice text or colors here too
  String get subjectText {
    switch (subject) {
      case StudyPartnerSubject.science:
        return 'Science';
      case StudyPartnerSubject.literature:
        return 'Literature';
      case StudyPartnerSubject.government:
        return 'Government';
      case StudyPartnerSubject.biology:
        return 'Biology';
      case StudyPartnerSubject.chemistry:
        return 'Chemistry';
      case StudyPartnerSubject.mathematics:
        return 'Mathematics';
      case StudyPartnerSubject.economics:
        return 'Economics';
    }
  }

  Color get subjectColor {
    switch (subject) {
      case StudyPartnerSubject.science:
      case StudyPartnerSubject.chemistry:
      case StudyPartnerSubject.biology:
        return const Color(0xFF2563EB); // Blue
      case StudyPartnerSubject.government:
      case StudyPartnerSubject.economics:
        return const Color(0xFF22C55E); // Green
      case StudyPartnerSubject.literature:
        return const Color(0xFFEF4444); // Red
      case StudyPartnerSubject.mathematics:
        return const Color(0xFFF59E0B); // Amber
    }
  }
}
