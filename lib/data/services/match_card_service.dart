import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../demo/demo_data.dart';
import '../models/match_card_model.dart';
import '../models/match_card_progress_model.dart';

class MatchCardService {
  final String baseUrl = "${ApiConstants.baseUrl}/match_cards";

  Future<List<MatchCardModel>> getMatchCardsByLesson(int lessonId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/$lessonId'),
            headers: ApiConstants.getAuthHeaders(),
          )
          .timeout(ApiConstants.requestTimeout);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.body.isNotEmpty) {
        final dynamic decodedData = jsonDecode(utf8.decode(response.bodyBytes));
        final rawList = decodedData is Map<String, dynamic>
            ? decodedData['data']
            : decodedData;
        if (rawList is List) {
          return rawList
              .map(
                (item) => MatchCardModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Match cards offline fallback: $e');
    }

    return DemoData.matchCards();
  }

  Future<bool> saveMatchCardProgress(SubmitMatchCardRequest request) async {
    if (request.results.isEmpty) return true;

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/progress'),
            headers: ApiConstants.getAuthHeaders(),
            body: jsonEncode(request.toJson()),
          )
          .timeout(ApiConstants.requestTimeout);

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Match card save skipped offline: $e');
      return true;
    }
  }
}
