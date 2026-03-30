class PracticeModel {
  final String practiceType;
  final int totalPractice;
  final int completedPractice;

  PracticeModel({
    required this.practiceType,
    required this.totalPractice,
    required this.completedPractice,
  });

  factory PracticeModel.fromJson(Map<String, dynamic> json) {
    return PracticeModel(
      practiceType: json['practiceType']?.toString() ?? 'UNKNOWN',
      totalPractice: int.tryParse(json['totalPractice']?.toString() ?? '0') ?? 0,
      completedPractice: int.tryParse(json['completedPractice']?.toString() ?? '0') ?? 0,
    );
  }

  // Tiện ích phụ trợ: Tự động tính % hoàn thành để dùng cho thanh Progress trên UI
  double get progressPercent {
    if (totalPractice == 0) return 0.0;
    return completedPractice / totalPractice;
  }

  // Tiện ích phụ trợ: Trả về chuỗi dạng "2/30"
  String get progressText => "$completedPractice/$totalPractice";
}