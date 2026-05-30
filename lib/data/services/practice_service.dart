import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../demo/demo_data.dart';
import '../models/practice_list_model.dart';
import '../models/practice_model.dart';

class PracticeService {
  final String baseUrl = "${ApiConstants.baseUrl}/practices";

  Future<AllPracticeStatsModel> getAllPracticeStats(int userId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/stats?userId=$userId'),
            headers: ApiConstants.getAuthHeaders(),
          )
          .timeout(ApiConstants.requestTimeout);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.body.isNotEmpty) {
        final dynamic decodedData = jsonDecode(utf8.decode(response.bodyBytes));
        if (decodedData is Map<String, dynamic>) {
          return AllPracticeStatsModel.fromJson(decodedData);
        }
      }
    } catch (e) {
      debugPrint('Practice stats offline fallback: $e');
    }

    return DemoData.practiceStats();
  }

  Future<List<PracticeListModel>> getWeakPractices(int userId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/overview/weak?userId=$userId'),
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
      debugPrint('Weak practices offline fallback: $e');
    }

    return DemoData.practices('TOPIC');
  }
}
