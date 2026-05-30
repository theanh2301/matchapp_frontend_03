import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../demo/demo_data.dart';
import '../models/daily_challenge_model.dart';

class DailyChallengeService {
  final String baseUrl = "${ApiConstants.baseUrl}/challenges/today";

  Future<List<DailyChallengeModel>> getTodayChallenges(int userId) async {
    try {
      final response = await http
          .get(
            Uri.parse("$baseUrl/$userId"),
            headers: ApiConstants.getAuthHeaders(),
          )
          .timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((e) => DailyChallengeModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Daily challenges offline fallback: $e');
    }

    return DemoData.dailyChallenges();
  }
}
