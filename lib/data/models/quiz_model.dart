class AnswerModel {
  final int id;
  final String content;
  final bool isCorrect;
  final String description;

  AnswerModel({
    required this.id,
    required this.content,
    required this.isCorrect,
    required this.description,
  });

  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    return AnswerModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      content: json['content']?.toString() ?? '',
      isCorrect: json['isCorrect'] == true, // Ép kiểu an toàn sang bool
      description: json['description']?.toString() ?? '',
    );
  }
}

class QuizModel {
  final int id;
  final String content;
  final String typeQuestion;
  final int xpReward;
  final List<AnswerModel> answers;

  QuizModel({
    required this.id,
    required this.content,
    required this.typeQuestion,
    required this.xpReward,
    required this.answers,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    var answersList = json['answers'] as List? ?? [];
    return QuizModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      content: json['content']?.toString() ?? 'Chưa có câu hỏi',
      typeQuestion: json['typeQuestion']?.toString() ?? 'QUIZ',
      xpReward: int.tryParse(json['xpReward']?.toString() ?? '0') ?? 0,
      answers: answersList.map((a) => AnswerModel.fromJson(a as Map<String, dynamic>)).toList(),
    );
  }

  // Hàm tiện ích để UI dễ dàng tìm ra vị trí của đáp án đúng
  int get correctOptionIndex => answers.indexWhere((a) => a.isCorrect);

  // Hàm lấy danh sách các chuỗi đáp án (A, B, C, D)
  List<String> get options => answers.map((a) => a.content).toList();
}