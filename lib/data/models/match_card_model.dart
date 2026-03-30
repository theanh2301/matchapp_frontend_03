class MatchCardModel {
  final int id;
  final int pairId;
  final String content;
  final int xpReward;

  MatchCardModel({
    required this.id,
    required this.pairId,
    required this.content,
    required this.xpReward,
  });

  factory MatchCardModel.fromJson(Map<String, dynamic> json) {
    return MatchCardModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      pairId: int.tryParse(json['pairId']?.toString() ?? '0') ?? 0,
      content: json['content']?.toString() ?? '',
      xpReward: int.tryParse(json['xpReward']?.toString() ?? '0') ?? 0,
    );
  }
}