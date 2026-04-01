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

class WrongQuestionModel {
  final String questionContent;
  final String userAnswerContent;
  final String correctAnswerContent;

  WrongQuestionModel({
    required this.questionContent,
    required this.userAnswerContent,
    required this.correctAnswerContent,
  });

  factory WrongQuestionModel.fromJson(Map<String, dynamic> json) {
    return WrongQuestionModel(
      questionContent: json['questionContent']?.toString() ?? 'Không có nội dung câu hỏi',
      userAnswerContent: json['userAnswerContent']?.toString() ?? 'Chưa chọn',
      correctAnswerContent: json['correctAnswerContent']?.toString() ?? 'Không có đáp án',
    );
  }
}