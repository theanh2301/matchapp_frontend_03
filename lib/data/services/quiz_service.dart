import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../demo/demo_data.dart';
import '../models/quiz_model.dart';
import '../models/quiz_progress_model.dart';

class QuizService {
  final String baseUrl = "${ApiConstants.baseUrl}/quiz";

  Future<List<QuizModel>> getQuizzesByLesson(int lessonId) async {
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
              .map((item) => QuizModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Quiz offline fallback: $e');
    }

    return DemoData.quizzes();
  }

  Future<List<QuizModel>> getAiGeneratedQuizzesByLesson(
    int lessonId,
    int userId, {
    int limit = 10,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/$lessonId/ai-generated?userId=$userId&limit=$limit',
            ),
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
              .map((item) => QuizModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('AI quiz offline fallback: $e');
    }

    return [];
  }

  Future<bool> saveQuizProgress(SubmitQuizRequest request) async {
    if (request.answers.isEmpty) return true;

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
      debugPrint('Quiz save skipped offline: $e');
      return true;
    }
  }
}
