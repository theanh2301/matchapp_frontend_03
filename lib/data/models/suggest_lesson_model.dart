class SuggestedLessonModel {
  final int lessonId;
  final String lessonName;
  final int isLearned;
  final DateTime? updatedAt; 

  SuggestedLessonModel({
    required this.lessonId,
    required this.lessonName,
    required this.isLearned,
    this.updatedAt,
  });

  // Factory method để tạo đối tượng từ file JSON
  factory SuggestedLessonModel.fromJson(Map<String, dynamic> json) {
    return SuggestedLessonModel(
      lessonId: json['lessonId'] ?? 0,
      lessonName: json['lessonName'] ?? '',
      isLearned: json['isLearned'] ?? 0,
      // Kiểm tra nếu updatedAt không null thì parse sang DateTime, ngược lại để null
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  // Thuộc tính tiện ích giúp kiểm tra bài học đã học hay chưa (0: chưa học, 1: đã học)
  bool get isCompleted => isLearned == 1;
}