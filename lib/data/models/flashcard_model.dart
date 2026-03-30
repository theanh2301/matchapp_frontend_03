class FlashcardModel {
  final int id;
  final String frontText;
  final String backText;
  final String hint;
  final int xpReward;

  FlashcardModel({
    required this.id,
    required this.frontText,
    required this.backText,
    required this.hint,
    required this.xpReward,
  });

  factory FlashcardModel.fromJson(Map<String, dynamic> json) {
    return FlashcardModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      frontText: json['frontText']?.toString() ?? 'Chưa có câu hỏi',
      backText: json['backText']?.toString() ?? 'Chưa có đáp án',
      hint: json['hint']?.toString() ?? '',
      xpReward: int.tryParse(json['xpReward']?.toString() ?? '0') ?? 0,
    );
  }
}