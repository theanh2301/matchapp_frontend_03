class DailyChallengeModel {
  final int challengeId;
  final String title;
  final String description;
  final int xpReward;
  final String source;
  final int targetValue;
  final bool isCompleted;

  DailyChallengeModel({
    required this.challengeId,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.source,
    required this.targetValue,
    required this.isCompleted,
  });

  factory DailyChallengeModel.fromJson(Map<String, dynamic> json) {
    return DailyChallengeModel(
      challengeId: json['challengeId'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      xpReward: json['xpReward'] ?? 0,
      source: json['source'] ?? '',
      targetValue: json['targetValue'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}