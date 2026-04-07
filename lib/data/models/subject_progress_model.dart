class SubjectProgressModel {
  final int subjectId;
  final String subjectName;
  final int chapterId;
  final String chapterName;
  final int lessonId;
  final String lessonName;
  final double completionPercent;

  SubjectProgressModel({
    required this.subjectId,
    required this.subjectName,
    required this.chapterId,
    required this.chapterName,
    required this.lessonId,
    required this.lessonName,
    required this.completionPercent,
  });

  factory SubjectProgressModel.fromJson(Map<String, dynamic> json) {
    // Hàm hỗ trợ parse int an toàn
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is double) return value.toInt();
      return 0;
    }

    // Hàm hỗ trợ parse double an toàn
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return SubjectProgressModel(
      // Thêm key phụ (vd: subject_id) đề phòng Spring Boot format kiểu snake_case
      subjectId: parseInt(json['subjectId'] ?? json['subject_id']),
      subjectName: json['subjectName'] ?? json['subject_name'] ?? 'Chưa cập nhật',

      chapterId: parseInt(json['chapterId'] ?? json['chapter_id']),
      chapterName: json['chapterName'] ?? json['chapter_name'] ?? 'Chưa cập nhật',

      lessonId: parseInt(json['lessonId'] ?? json['lesson_id']),
      lessonName: json['lessonName'] ?? json['lesson_name'] ?? 'Chưa cập nhật',

      completionPercent: parseDouble(json['completionPercent'] ?? json['completion_percent']),
    );
  }
}