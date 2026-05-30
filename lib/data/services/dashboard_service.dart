import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:learn_math_app_03/core/constants/api_constants.dart';

import '../demo/demo_data.dart';
import '../models/dashboard_model.dart';

class DashboardService {
  final String baseUrl = "${ApiConstants.baseUrl}/user";

  Future<DashboardResponse> getDashboardData(int userId, DateTime date) async {
    final dateStr =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    try {
      final response = await http
          .get(
            Uri.parse("$baseUrl/$userId/dashboard?date=$dateStr"),
            headers: ApiConstants.getAuthHeaders(),
          )
          .timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(
          utf8.decode(response.bodyBytes),
        );
        return DashboardResponse.fromJson(data);
      }
    } catch (e) {
      debugPrint('Dashboard offline fallback: $e');
    }

    return DemoData.dashboard(userId, date);
  }
}
