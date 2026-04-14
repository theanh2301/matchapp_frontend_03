// Class đại diện cho từng câu trả lời bên trong mảng "answers"
class AnswerSubmit {
  final int questionId;
  final int answerId;

  AnswerSubmit({
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

// Class đại diện cho toàn bộ request gửi đi
class PracticeProgressRequest {
  final int userId;
  final int practiceId;
  final List<AnswerSubmit> answers;

  PracticeProgressRequest({
    required this.userId,
    required this.practiceId,
    required this.answers,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'practiceId': practiceId,
      'answers': answers.map((a) => a.toJson()).toList(), // Convert list sang JSON
    };
  }
}