import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../models/match_card_model.dart';

class MatchCardService {
  // TODO: Điều chỉnh URL cho khớp với API backend của bạn
  final String baseUrl = "http://10.0.2.2:8080/api/match_cards";

  Future<List<MatchCardModel>> getMatchCardsByLesson(int lessonId) async {
    try {
      final Uri url = Uri.parse('$baseUrl/$lessonId');
      debugPrint("🚀 ĐANG GỌI API MATCHCARD: $url");

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
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
}