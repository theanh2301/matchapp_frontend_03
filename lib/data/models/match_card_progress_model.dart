class MatchCardProgressRequest {
  final int totalPairs;
  final int correctPairs;
  final int timeTaken;
  final int totalXP;
  final int lessonId;
  final int userId;

  MatchCardProgressRequest({
    required this.totalPairs,
    required this.correctPairs,
    required this.timeTaken,
    this.totalXP = 0,
    required this.lessonId,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalPairs': totalPairs,
      'correctPairs': correctPairs,
      'timeTaken': timeTaken,
      'totalXP': totalXP,
      'lessonId': lessonId,
      'userId': userId,
    };
  }
}