import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../demo/demo_data.dart';
import '../models/chapter_model.dart';

class ChapterService {
  final String baseUrl = "${ApiConstants.baseUrl}/chapters";

  Future<List<ChapterModel>> getChaptersOverview(
    int userId,
    int subjectId,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/$subjectId/chapters?userId=$userId'),
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
              .map(
                (item) => ChapterModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Chapters offline fallback: $e');
    }

    return DemoData.chapters();
  }
}
