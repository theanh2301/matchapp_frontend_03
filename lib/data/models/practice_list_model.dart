class PracticeListModel {
  final int id;
  final String title;
  final String description;
  final int timeLimit;
  final String difficulty;
  final int totalQuestions;
  final int totalXp;

  PracticeListModel({
    required this.id,
    required this.title,
    required this.description,
    required this.timeLimit,
    required this.difficulty,
    required this.totalQuestions,
    required this.totalXp,
  });

  factory PracticeListModel.fromJson(Map<String, dynamic> json) {
    return PracticeListModel(
      // Ép kiểu an toàn, đề phòng trường hợp backend trả về null hoặc sai kiểu
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? 'Chưa có tiêu đề',
      description: json['description']?.toString() ?? 'Chưa có mô tả',
      timeLimit: int.tryParse(json['timeLimit']?.toString() ?? '0') ?? 0,
      difficulty: json['difficulty']?.toString() ?? 'UNKNOWN',
      totalQuestions: int.tryParse(json['totalQuestions']?.toString() ?? '0') ?? 0,
      totalXp: int.tryParse(json['totalXp']?.toString() ?? '0') ?? 0,
    );
  }
}