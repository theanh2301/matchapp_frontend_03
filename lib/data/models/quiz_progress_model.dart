// Model cho chi tiết từng câu trả lời
class QuizAnswerRequest {
  final int questionId;
  final int answerId;

  QuizAnswerRequest({
    required this.questionId,
    required this.answerId,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'answerId': answerId,
    };
  }
}

// Model tổng chứa userId, lessonId và mảng answers
class SubmitQuizRequest {
  final int userId;
  final int lessonId;
  final List<QuizAnswerRequest> answers;

  SubmitQuizRequest({
    required this.userId,
    required this.lessonId,
    required this.answers,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'lessonId': lessonId,
      'answers': answers.map((a) => a.toJson()).toList(),
    };
  }
}