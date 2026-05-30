import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../demo/demo_data.dart';
import '../models/suggest_lesson_model.dart';

class SuggestedLessonService {
  Future<List<SuggestedLessonModel>> getSuggestedLessons(int userId) async {
    final Uri url = Uri.parse(
      "${ApiConstants.baseUrl}/lessons/suggested-lessons?userId=$userId",
    );

    try {
      final response = await http
          .get(url, headers: ApiConstants.getAuthHeaders())
          .timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic responseData = json.decode(
          utf8.decode(response.bodyBytes),
        );
        final rawList = responseData is Map<String, dynamic>
            ? responseData['data']
            : responseData;
        if (rawList is List) {
          return rawList
              .map((jsonItem) => SuggestedLessonModel.fromJson(jsonItem))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Suggested lessons offline fallback: $e');
    }

    return DemoData.suggestedLessons();
  }
}
