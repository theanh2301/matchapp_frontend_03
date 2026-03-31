class QuizProgressRequest {
  final int userId;
  final int questionId;
  final int answerId;

  QuizProgressRequest({
    required this.userId,
    required this.questionId,
    required this.answerId,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'questionId': questionId,
      'answerId': answerId,
    };
  }
}