class LessonModel {
  final int lessonId;
  final String lessonName;
  final String description;
  final int earnedXp;
  final int totalPossibleXp;

  // Trạng thái các game con
  bool isFlashcardDone;
  bool isQuestionDone;
  bool isMatchCardDone;

  LessonModel({
    required this.lessonId,
    required this.lessonName,
    required this.description,
    required this.earnedXp,
    required this.totalPossibleXp,
    required this.isFlashcardDone,
    required this.isQuestionDone,
    required this.isMatchCardDone,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      lessonId: int.tryParse(json['lessonId']?.toString() ?? '0') ?? 0,
      lessonName: json['lessonName']?.toString() ?? 'Chưa có tên bài học',
      description: json['description']?.toString() ?? 'Chưa có mô tả',
      earnedXp: int.tryParse(json['earnedXp']?.toString() ?? '0') ?? 0,
      totalPossibleXp: int.tryParse(json['totalPossibleXp']?.toString() ?? '0') ?? 0,

      // Hàm chuyển đổi an toàn từ Integer (0, 1) sang boolean (false, true)
      isFlashcardDone: _parseBoolean(json['isFlashcardDone']),
      isQuestionDone: _parseBoolean(json['isQuestionDone']),
      isMatchCardDone: _parseBoolean(json['isMatchCardDone']),
    );
  }

  // Tiện ích để đếm số lượng game đã hoàn thành (Tối đa 3)
  int get completedGamesCount {
    int count = 0;
    if (isFlashcardDone) count++;
    if (isQuestionDone) count++;
    if (isMatchCardDone) count++;
    return count;
  }

  // Hàm phụ trợ giúp phân tích Integer từ Java thành Boolean trong Dart
  static bool _parseBoolean(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1; // 1 là true, 0 là false
    if (value.toString() == '1' || value.toString().toLowerCase() == 'true') return true;
    return false;
  }
}