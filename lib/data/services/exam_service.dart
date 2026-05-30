import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../demo/demo_data.dart';
import '../models/exam_model.dart';
import '../models/practice_model.dart';
import '../models/practice_progress_model.dart';

class PracticeListService {
  final String baseUrl = "${ApiConstants.baseUrl}/practices";

  Future<List<PracticeQuestionModel>> getPracticeQuestions(
    int practiceId,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/$practiceId'),
            headers: ApiConstants.getAuthHeaders(),
          )
          .timeout(ApiConstants.requestTimeout);

      final parsed = _parsePracticeQuestions(response);
      if (parsed.isNotEmpty) return parsed;
    } catch (e) {
      debugPrint('Practice questions offline fallback: $e');
    }

    return DemoData.practiceQuestions();
  }

  Future<List<PracticeQuestionModel>> getAiGeneratedPracticeQuestions(
    int practiceId,
    int userId, {
    int limit = 10,
    String difficulty = 'EASY',
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/$practiceId/ai-generated?userId=$userId&limit=$limit&difficulty=$difficulty',
            ),
            headers: ApiConstants.getAuthHeaders(),
          )
          .timeout(ApiConstants.requestTimeout);

      final parsed = _parsePracticeQuestions(response);
      if (parsed.isNotEmpty) return parsed;
    } catch (e) {
      debugPrint('AI practice questions offline fallback: $e');
    }

    return DemoData.practiceQuestions();
  }

  Future<void> saveQuizProgress(PracticeProgressRequest request) async {
    try {
      await http
          .post(
            Uri.parse('$baseUrl/progress'),
            headers: ApiConstants.getAuthHeaders(),
            body: jsonEncode(request.toJson()),
          )
          .timeout(ApiConstants.requestTimeout);
    } catch (e) {
      debugPrint('Practice progress save skipped offline: $e');
    }
  }

  Future<List<WrongQuestionModel>> getWrongQuestionsDetail(
    int practiceId,
    int userId,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/$practiceId/wrong-questions-detail?userId=$userId',
            ),
            headers: ApiConstants.getAuthHeaders(),
          )
          .timeout(ApiConstants.requestTimeout);

      final parsed = _parseWrongQuestions(response);
      if (parsed.isNotEmpty) return parsed;
    } catch (e) {
      debugPrint('Wrong question detail offline fallback: $e');
    }

    return DemoData.wrongQuestions();
  }

  Future<List<PracticeQuestionModel>> getWrongQuestionsForExam(
    int practiceId,
    int userId,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/$practiceId/wrong-questions-exam?userId=$userId',
            ),
            headers: ApiConstants.getAuthHeaders(),
          )
          .timeout(ApiConstants.requestTimeout);

      final parsed = _parsePracticeQuestions(response);
      if (parsed.isNotEmpty) return parsed;
    } catch (e) {
      debugPrint('Wrong question exam offline fallback: $e');
    }

    return DemoData.practiceQuestions();
  }

  List<PracticeQuestionModel> _parsePracticeQuestions(http.Response response) {
    if (response.statusCode != 200 && response.statusCode != 201) return [];
    if (response.body.isEmpty) return [];

    final dynamic decodedData = jsonDecode(utf8.decode(response.bodyBytes));
    final rawList = decodedData is Map<String, dynamic>
        ? (decodedData['data'] ?? decodedData['result'])
        : decodedData;

    if (rawList is! List) return [];
    return rawList
        .map(
          (item) =>
              PracticeQuestionModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  List<WrongQuestionModel> _parseWrongQuestions(http.Response response) {
    if (response.statusCode != 200 && response.statusCode != 201) return [];
    if (response.body.isEmpty) return [];

    final dynamic decodedData = jsonDecode(utf8.decode(response.bodyBytes));
    final rawList = decodedData is Map<String, dynamic>
        ? decodedData['data']
        : decodedData;

    if (rawList is! List) return [];
    return rawList
        .map(
          (item) => WrongQuestionModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }
}
