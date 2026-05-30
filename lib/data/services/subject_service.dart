import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../demo/demo_data.dart';
import '../models/subject_model.dart';
import '../models/subject_progress_model.dart';

class SubjectService {
  final String baseUrl = "${ApiConstants.baseUrl}/subjects";

  Future<List<SubjectModel>> getSubjectsProgress(int userId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/overview?userId=$userId'),
            headers: ApiConstants.getAuthHeaders(),
          )
          .timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic decodedData = jsonDecode(utf8.decode(response.bodyBytes));
        if (decodedData is List) {
          return decodedData
              .map(
                (item) => SubjectModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }

        if (decodedData is Map<String, dynamic>) {
          final rawList =
              decodedData['data'] ??
              decodedData['result'] ??
              decodedData['content'];
          if (rawList is List) {
            return rawList
                .map(
                  (item) => SubjectModel.fromJson(item as Map<String, dynamic>),
                )
                .toList();
          }
        }
      }
    } catch (e) {
      debugPrint('Subject overview offline fallback: $e');
    }

    return DemoData.subjects(10);
  }

  Future<List<SubjectProgressModel>> fetchSubjectProgress(int userId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/progress?userId=$userId'),
            headers: ApiConstants.getAuthHeaders(),
          )
          .timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((json) => SubjectProgressModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Subject progress offline fallback: $e');
    }

    return DemoData.subjectProgress();
  }
}
