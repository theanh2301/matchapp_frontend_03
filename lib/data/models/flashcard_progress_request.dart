// Model cho từng thẻ flashcard
class FlashcardResultRequest {
  final int flashcardId;
  final bool isKnown;

  FlashcardResultRequest({
    required this.flashcardId,
    required this.isKnown,
  });

  Map<String, dynamic> toJson() {
    return {
      'flashcardId': flashcardId,
      'isKnown': isKnown,
    };
  }
}

// Model tổng bao bọc userId, lessonId và danh sách thẻ
class SubmitFlashcardRequest {
  final int userId;
  final int lessonId;
  final List<FlashcardResultRequest> flashcards;

  SubmitFlashcardRequest({
    required this.userId,
    required this.lessonId,
    required this.flashcards,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'lessonId': lessonId,
      // Map list các object con thành JSON
      'flashcards': flashcards.map((f) => f.toJson()).toList(),
    };
  }
}