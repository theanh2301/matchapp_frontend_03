class SubjectModel {
  final int subjectId;
  final int subjectClass;
  final String subjectName;
  final String? icon;
  final int totalLessons;
  final int completedLessons;
  final int earnedXp;
  final int totalXp;

  SubjectModel({
    required this.subjectId,
    required this.subjectClass,
    required this.subjectName,
    this.icon,
    required this.totalLessons,
    required this.completedLessons,
    required this.earnedXp,
    required this.totalXp,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      subjectId: int.tryParse(json['subjectId']?.toString() ?? '0') ?? 0,
      subjectClass: int.tryParse(json['subjectClass']?.toString() ?? '0') ?? 0,
      subjectName: json['subjectName']?.toString() ?? 'Chưa có tên',
      icon: json['icon']?.toString(),
      totalLessons: int.tryParse(json['totalLessons']?.toString() ?? '1') ?? 1,
      completedLessons: int.tryParse(json['completedLessons']?.toString() ?? '0') ?? 0,
      earnedXp: int.tryParse(json['earnedXp']?.toString() ?? '0') ?? 0,
      totalXp: int.tryParse(json['totalXp']?.toString() ?? '0') ?? 0,
    );
  }

  double get progress => totalLessons > 0 ? (completedLessons / totalLessons) : 0.0;
}