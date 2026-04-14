import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../../core/constants/api_constants.dart';
import '../models/match_card_model.dart';
import '../models/match_card_progress_model.dart';

class MatchCardService {
  final String baseUrl = "${ApiConstants.baseUrl}/match_cards";

  Future<List<MatchCardModel>> getMatchCardsByLesson(int lessonId) async {
    try {
      final Uri url = Uri.parse('$baseUrl/$lessonId');
      debugPrint("🚀 ĐANG GỌI API MATCHCARD: $url");

      final response = await http.get(
        url,
        headers: ApiConstants.getAuthHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isEmpty) return [];

        final dynamic decodedData = jsonDecode(utf8.decode(response.bodyBytes));
        debugPrint("🚀 Call match card successfully");

        if (decodedData is Map<String, dynamic> && decodedData.containsKey('data')) {
          final List<dynamic> listData = decodedData['data'];
          return listData.map((item) => MatchCardModel.fromJson(item as Map<String, dynamic>)).toList();
        } else if (decodedData is List) {
          return decodedData.map((item) => MatchCardModel.fromJson(item as Map<String, dynamic>)).toList();
        } else {
          throw Exception("Không tìm thấy danh sách thẻ ghép.");
        }
      } else {
        throw Exception("Lỗi server: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ LỖI LẤY MATCHCARD: $e");
      throw Exception("Lỗi kết nối: $e");
    }
  }

  Future<bool> saveMatchCardProgress(SubmitMatchCardRequest request) async {
    if (request.results.isEmpty) {
      print('⚠️ Không có kết quả thẻ ghép nào để lưu.');
      return true;
    }

    final url = Uri.parse('$baseUrl/progress');

    String jsonBody = jsonEncode(request.toJson());

    try {
      final response = await http.post(
        url,
        headers: ApiConstants.getAuthHeaders(), // Đảm bảo có 'Content-Type': 'application/json' trong hàm này
        body: jsonBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Save match card results successfully');
        return true;
      } else {
        print("❌ Lỗi lưu Match Card: Code ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Lỗi kết nối lưu Match Card: $e");
      return false;
    }
  }
}