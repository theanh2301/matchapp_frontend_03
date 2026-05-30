import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../demo/demo_data.dart';
import '../models/performance_model.dart';

class PerformanceService {
  final String baseUrl = "${ApiConstants.baseUrl}/subjects/performance";

  Future<List<SubjectPerformanceModel>> getSubjectPerformance(
    int userId,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse("$baseUrl/subjects/$userId"),
            headers: ApiConstants.getAuthHeaders(),
          )
          .timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((e) => SubjectPerformanceModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Subject performance offline fallback: $e');
    }

    return DemoData.subjectPerformance();
  }

  Future<List<TypePerformanceModel>> getTypePerformance(int userId) async {
    try {
      final response = await http
          .get(
            Uri.parse("$baseUrl/types/$userId"),
            headers: ApiConstants.getAuthHeaders(),
          )
          .timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((e) => TypePerformanceModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Type performance offline fallback: $e');
    }

    return DemoData.typePerformance();
  }
}
