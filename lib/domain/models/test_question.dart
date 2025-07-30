class TestQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String subject;
  final String explanation;
  final String? difficulty;
  final String? topic;

  TestQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.subject,
    required this.explanation,
    this.difficulty,
    this.topic,
  });
}
