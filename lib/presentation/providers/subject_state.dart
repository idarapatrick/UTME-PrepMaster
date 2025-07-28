import 'package:flutter/material.dart';

class SubjectState extends ChangeNotifier {
  List<String> _selectedSubjects = ['English'];
  List<String> get selectedSubjects => _selectedSubjects;

  Map<String, Map<String, dynamic>> _subjectProgress = {};
  Map<String, Map<String, dynamic>> get subjectProgress => _subjectProgress;

  void setSelectedSubjects(List<String> subjects) {
    _selectedSubjects = subjects;
    notifyListeners();
  }

  void setSubjectProgress(String subject, Map<String, dynamic> progress) {
    _subjectProgress[subject] = progress;
    notifyListeners();
  }

  void loadSubjectProgress(Map<String, Map<String, dynamic>> progress) {
    _subjectProgress = progress;
    notifyListeners();
  }
}
