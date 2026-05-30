import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../demo/demo_data.dart';
import '../models/lesson_model.dart';

class LessonService {
  final String baseUrl = "${ApiConstants.baseUrl}/lessons";

  Future<List<LessonModel>> getLessonsOverview(
    int userId,
    int chapterId,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/$chapterId?userId=$userId'),
            headers: ApiConstants.getAuthHeaders(),
          )
          .timeout(ApiConstants.requestTimeout);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.body.isNotEmpty) {
        final dynamic decodedData = jsonDecode(utf8.decode(response.bodyBytes));
        final rawList = decodedData is Map<String, dynamic>
            ? (decodedData['data'] ?? decodedData['result'])
            : decodedData;

        if (rawList is List) {
          return rawList
              .map((item) => LessonModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Lessons offline fallback: $e');
    }

    return DemoData.lessons();
  }
}
