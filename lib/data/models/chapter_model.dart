class ChapterModel {
  final int chapterId;
  final String chapterName;
  final String description;
  final int totalLessons;
  final int completedLessons;
  final int earnedXp;
  final int totalPossibleXp;

  ChapterModel({
    required this.chapterId,
    required this.chapterName,
    required this.description,
    required this.totalLessons,
    required this.completedLessons,
    required this.earnedXp,
    required this.totalPossibleXp,
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      chapterId: int.tryParse(json['chapterId']?.toString() ?? '0') ?? 0,
      chapterName: json['chapterName']?.toString() ?? 'Chưa có tên chương',
      description: json['description']?.toString() ?? 'Chưa có mô tả',
      totalLessons: int.tryParse(json['totalLessons']?.toString() ?? '1') ?? 1,
      completedLessons: int.tryParse(json['completedLessons']?.toString() ?? '0') ?? 0,
      earnedXp: int.tryParse(json['earnedXp']?.toString() ?? '0') ?? 0,
      totalPossibleXp: int.tryParse(json['totalPossibleXp']?.toString() ?? '0') ?? 0,
    );
  }

  // Tính phần trăm tiến độ của chương (0.0 đến 1.0)
  double get progress => totalLessons > 0 ? (completedLessons / totalLessons) : 0.0;
}