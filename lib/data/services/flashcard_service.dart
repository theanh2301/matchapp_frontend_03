import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../demo/demo_data.dart';
import '../models/flashcard_model.dart';
import '../models/flashcard_progress_request.dart';

class FlashcardService {
  final String baseUrl = "${ApiConstants.baseUrl}/flashcards";

  Future<List<FlashcardModel>> getFlashcardsByLesson(int lessonId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/$lessonId'),
            headers: ApiConstants.getAuthHeaders(),
          )
          .timeout(ApiConstants.requestTimeout);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.body.isNotEmpty) {
        final dynamic decodedData = jsonDecode(utf8.decode(response.bodyBytes));
        final rawList = decodedData is Map<String, dynamic>
            ? decodedData['data']
            : decodedData;
        if (rawList is List) {
          return rawList
              .map(
                (item) => FlashcardModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Flashcards offline fallback: $e');
    }

    return DemoData.flashcards();
  }

  Future<bool> saveProgress(SubmitFlashcardRequest request) async {
    if (request.flashcards.isEmpty) return true;

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/progress'),
            headers: ApiConstants.getAuthHeaders(),
            body: jsonEncode(request.toJson()),
          )
          .timeout(ApiConstants.requestTimeout);

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Flashcard save skipped offline: $e');
      return true;
    }
  }
}
