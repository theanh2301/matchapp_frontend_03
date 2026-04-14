// Model cho chi tiết từng cặp thẻ
class MatchCardResultRequest {
  final int pairId;
  final bool isCorrect;

  MatchCardResultRequest({
    required this.pairId,
    required this.isCorrect,
  });

  Map<String, dynamic> toJson() {
    return {
      'pairId': pairId,
      'isCorrect': isCorrect,
    };
  }
}

// Model tổng chứa userId, lessonId và mảng results
class SubmitMatchCardRequest {
  final int userId;
  final int lessonId;
  final List<MatchCardResultRequest> results;

  SubmitMatchCardRequest({
    required this.userId,
    required this.lessonId,
    required this.results,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'lessonId': lessonId,
      'results': results.map((r) => r.toJson()).toList(),
    };
  }
}