import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../../core/constants/ApiConstants.dart';
import '../models/match_card_model.dart';
import '../models/match_card_progress_model.dart';

class MatchCardService {
  // TODO: Điều chỉnh URL cho khớp với API backend của bạn
  final String baseUrl = "${ApiConstants.baseUrl}/match_cards";

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

  /*Future<bool> saveMatchCardProgress(MatchCardProgressRequest request) async {
    // Đổi lại URL thực tế của backend
    final url = Uri.parse('$baseUrl/progress/batch');

    print('🚀 ĐANG GỌI API MATCH CARD: $url');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('🚀 Call match card progress successfully');
        return true;
      } else {
        print("Lỗi lưu tiến độ Match Card: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Lỗi kết nối lưu Match Card: $e");
      return false;
    }
  }*/

  Future<bool> saveMatchCardProgress(List<MatchCardProgressRequest> requests) async {
    if (requests.isEmpty) {
      print('⚠️ Không có thẻ ghép nào để lưu.');
      return true;
    }

    // Nhớ cập nhật URL khớp với Spring Boot mới đổi ở trên
    final url = Uri.parse('$baseUrl/progress/batch');

    print('🚀 ĐANG GỌI API MATCH CARD BATCH: $url (Lưu ${requests.length} kết quả)');

    try {
      // Chuyển danh sách Object thành mảng JSON
      final List<Map<String, dynamic>> jsonData = requests.map((req) => req.toJson()).toList();

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(jsonData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Save ${requests.length} match card results successfully');
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