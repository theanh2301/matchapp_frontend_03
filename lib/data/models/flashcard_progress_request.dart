class FlashcardProgressRequest {
  final bool isKnown;
  final String lastReviewed;
  final int totalXP;
  final int flashcardId;
  final int userId;

  FlashcardProgressRequest({
    required this.isKnown,
    required this.lastReviewed,
    required this.totalXP,
    required this.flashcardId,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'isKnown': isKnown,
      'lastReviewed': lastReviewed,
      'totalXP': totalXP,
      'flashcardId': flashcardId,
      'userId': userId,
    };
  }
}