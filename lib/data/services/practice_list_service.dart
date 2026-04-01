import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:learn_math_app_03/data/models/practice_list_model.dart';

class PracticeListService {
  // Lưu ý: Dùng 10.0.2.2 nếu chạy máy ảo Android, localhost nếu dùng web/iOS
  final String baseUrl = "http://10.0.2.2:8080/api/practices";

  /// Gọi API lấy danh sách tổng quan. Đã thêm [userId]
  Future<List<PracticeListModel>> getPracticeOverview(String practiceType, int userId) async {
    try {
      // Nối thêm &userId=$userId vào chuỗi query
      final Uri url = Uri.parse('$baseUrl/overview?practiceType=$practiceType&userId=$userId');
      debugPrint("🚀 ĐANG GỌI API OVERVIEW: $url");

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isEmpty) {
          debugPrint("⚠️ Server trả về body rỗng (chưa có bài tập nào).");
          return [];
        }

        final dynamic decodedData = jsonDecode(utf8.decode(response.bodyBytes));

        if (decodedData is List) {
          return decodedData.map((item) =>
              PracticeListModel.fromJson(item as Map<String, dynamic>)).toList();
        } else if (decodedData is Map<String, dynamic>) {
          if (decodedData.containsKey('data') && decodedData['data'] is List) {
            return (decodedData['data'] as List).map((item) =>
                PracticeListModel.fromJson(item as Map<String, dynamic>)).toList();
          } else if (decodedData.containsKey('result') && decodedData['result'] is List) {
            return (decodedData['result'] as List).map((item) =>
                PracticeListModel.fromJson(item as Map<String, dynamic>)).toList();
          } else {
            throw Exception("Không tìm thấy danh sách bài tập trong Object JSON.");
          }
        } else {
          throw Exception("Định dạng dữ liệu lạ, mong đợi List hoặc Object chứa List.");
        }
      } else {
        throw Exception("Lỗi server ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ LỖI LẤY OVERVIEW: $e");
      throw Exception("Lỗi xử lý: $e");
    }
  }
}