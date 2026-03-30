class PracticeAnswerModel {
  final int id;
  final String content;
  final bool isCorrect;
  final String description;

  PracticeAnswerModel({
    required this.id,
    required this.content,
    required this.isCorrect,
    required this.description,
  });

  factory PracticeAnswerModel.fromJson(Map<String, dynamic> json) {
    return PracticeAnswerModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      content: json['content']?.toString() ?? '',
      isCorrect: _parseBoolean(json['isCorrect']),
      description: json['description']?.toString() ?? '',
    );
  }

  static bool _parseBoolean(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value.toString().toLowerCase() == 'true' || value.toString() == '1') return true;
    return false;
  }
}

class PracticeQuestionModel {
  final int id;
  final String content;
  final int xpReward;
  final String difficulty;
  final List<PracticeAnswerModel> answers;

  PracticeQuestionModel({
    required this.id,
    required this.content,
    required this.xpReward,
    required this.difficulty,
    required this.answers,
  });

  factory PracticeQuestionModel.fromJson(Map<String, dynamic> json) {
    // Parse danh sách câu trả lời một cách an toàn
    var answersList = json['answers'] as List?;
    List<PracticeAnswerModel> parsedAnswers = answersList != null
        ? answersList.map((i) => PracticeAnswerModel.fromJson(i as Map<String, dynamic>)).toList()
        : [];

    return PracticeQuestionModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      content: json['content']?.toString() ?? '',
      xpReward: int.tryParse(json['xpReward']?.toString() ?? '0') ?? 0,
      difficulty: json['difficulty']?.toString() ?? 'UNKNOWN',
      answers: parsedAnswers,
    );
  }
}