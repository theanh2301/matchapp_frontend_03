class SubjectPerformanceModel {
  final String subject;
  final int accuracy;
  final int weeklyChange;
  final String level;

  SubjectPerformanceModel({
    required this.subject,
    required this.accuracy,
    required this.weeklyChange,
    required this.level,
  });

  factory SubjectPerformanceModel.fromJson(Map<String, dynamic> json) {
    return SubjectPerformanceModel(
      subject: json['subjectName'] ?? '',
      accuracy: json['accuracy'] ?? 0,
      weeklyChange: json['weeklyChange'] ?? 0,
      level: json['level'] ?? 'Yếu',
    );
  }
}

class TypePerformanceModel {
  final String type;
  final int score;

  TypePerformanceModel({
    required this.type,
    required this.score,
  });

  factory TypePerformanceModel.fromJson(Map<String, dynamic> json) {
    // Dự phòng các tên biến backend có thể trả về (score, xp, accuracy, value)
    int parsedScore = json['score'] ?? json['xp'] ?? json['accuracy'] ?? json['value'] ?? 0;

    return TypePerformanceModel(
      type: json['type'] ?? '',
      score: parsedScore,
    );
  }
}