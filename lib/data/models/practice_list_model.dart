class PracticeListModel {
  final int id;
  final String title;
  final String description;
  final int timeLimit;
  final String practiceType;
  final int totalQuestions;
  final int totalXp;

  final int totalAnswered;
  final int correctAnswers;
  final double correctPercent;

  PracticeListModel({
    required this.id,
    required this.title,
    required this.description,
    required this.timeLimit,
    required this.practiceType,
    required this.totalQuestions,
    required this.totalXp,
    required this.totalAnswered,
    required this.correctAnswers,
    required this.correctPercent,
  });

  bool get isStarted => totalAnswered > 0;
  bool get isCompleted => totalQuestions > 0 && totalAnswered >= totalQuestions;

  factory PracticeListModel.fromJson(Map<String, dynamic> json) {
    return PracticeListModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? 'Chưa có tiêu đề',
      description: json['description']?.toString() ?? 'Chưa có mô tả',
      timeLimit: int.tryParse(json['timeLimit']?.toString() ?? '0') ?? 0,
      practiceType: json['practiceType']?.toString() ?? 'UNKNOWN',
      totalQuestions: int.tryParse(json['totalQuestions']?.toString() ?? '0') ?? 0,
      totalXp: int.tryParse(json['totalXp']?.toString() ?? '0') ?? 0,
      // Ép kiểu các trường mới
      totalAnswered: int.tryParse(json['totalAnswered']?.toString() ?? '0') ?? 0,
      correctAnswers: int.tryParse(json['correctAnswers']?.toString() ?? '0') ?? 0,
      correctPercent: double.tryParse(json['correctPercent']?.toString() ?? '0.0') ?? 0.0,
    );
  }
}