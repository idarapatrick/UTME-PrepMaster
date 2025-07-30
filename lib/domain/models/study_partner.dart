import 'package:flutter/material.dart';

enum StudyPartnerStatus { available, studying, idle }

class StudyPartner {
  final String id;
  final String name;
  final String subject; 
  final String subjectText;
  final String goal;
  final StudyPartnerStatus status;

  StudyPartner({
    required this.id,
    required this.name,
    required this.subject, 
    required this.subjectText,
    required this.goal,
    required this.status,
  });

  String get statusText {
    switch (status) {
      case StudyPartnerStatus.available:
        return 'Available';
      case StudyPartnerStatus.studying:
        return 'Studying';
      case StudyPartnerStatus.idle:
      default:
        return 'Idle';
    }
  }

  factory StudyPartner.fromMap(Map<String, dynamic> map, String id) {
    return StudyPartner(
      id: id,
      name: map['name'] ?? '',
      subject: map['subject'] ?? '', // <-- Add this mapping
      subjectText: map['subjectText'] ?? '',
      goal: map['goal'] ?? '',
      status: _parseStatus(map['status']),
    );
  }

  static StudyPartnerStatus _parseStatus(String? status) {
    switch (status) {
      case 'available':
        return StudyPartnerStatus.available;
      case 'studying':
        return StudyPartnerStatus.studying;
      case 'idle':
      default:
        return StudyPartnerStatus.idle;
    }
  }
}
