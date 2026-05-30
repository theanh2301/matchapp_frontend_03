import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:learn_math_app_03/data/models/practice_list_model.dart';

import '../../core/constants/api_constants.dart';
import '../demo/demo_data.dart';

class PracticeListService {
  final String baseUrl = "${ApiConstants.baseUrl}/practices";

  Future<List<PracticeListModel>> getPracticeOverview(
    String practiceType,
    int userId,
    int gradeId,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/overview?practiceType=$practiceType&userId=$userId&gradeId=$gradeId',
            ),
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
                (item) =>
                    PracticeListModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Practice overview offline fallback: $e');
    }

    return DemoData.practices(practiceType);
  }
}
