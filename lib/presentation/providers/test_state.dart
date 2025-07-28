import 'package:flutter/material.dart';
import '../screens/mock_test_screen.dart';
import '../../domain/models/test_question.dart';

class TestState extends ChangeNotifier {
  MockTest? _currentTest;
  MockTest? get currentTest => _currentTest;

  List<TestQuestion> _questions = [];
  List<TestQuestion> get questions => _questions;

  List<String> _selectedAnswers = [];
  List<String> get selectedAnswers => _selectedAnswers;

  int _currentQuestionIndex = 0;
  int get currentQuestionIndex => _currentQuestionIndex;

  String _currentSubject = '';
  String get currentSubject => _currentSubject;

  void setTest(MockTest test, List<TestQuestion> questions) {
    _currentTest = test;
    _questions = questions;
    _selectedAnswers = List.filled(questions.length, '');
    _currentQuestionIndex = 0;
    _currentSubject = test.subjects.first;
    notifyListeners();
  }

  void selectAnswer(int index, String answer) {
    _selectedAnswers[index] = answer;
    notifyListeners();
  }

  void setCurrentQuestionIndex(int index) {
    _currentQuestionIndex = index;
    notifyListeners();
  }

  void setCurrentSubject(String subject) {
    _currentSubject = subject;
    notifyListeners();
  }

  void reset() {
    _currentTest = null;
    _questions = [];
    _selectedAnswers = [];
    _currentQuestionIndex = 0;
    _currentSubject = '';
    notifyListeners();
  }
}
