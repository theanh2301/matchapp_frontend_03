class QuizProgressRequest {
  final int userId;
  final int questionId;
  final int answerId;
  final String answeredAt;

  QuizProgressRequest({
    required this.userId,
    required this.questionId,
    required this.answerId,
    required this.answeredAt
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'questionId': questionId,
      'answerId': answerId,
      "answeredAt": answeredAt,
    };
  }
}