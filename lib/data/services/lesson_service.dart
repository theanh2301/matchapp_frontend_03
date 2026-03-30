import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lesson_model.dart';
import 'package:flutter/foundation.dart'; // Để dùng debugPrint

class LessonService {
  final String baseUrl = "http://10.0.2.2:8080/api/lessons";

  Future<List<LessonModel>> getLessonsOverview(int userId, int chapterId) async {
    try {
      final Uri url = Uri.parse('$baseUrl/$chapterId?userId=$userId');
      debugPrint("🚀 ĐANG GỌI API LESSONS: $url");

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isEmpty) {
          debugPrint("⚠️ Server trả về body rỗng (chưa có bài học nào).");
          return [];
        }

        final dynamic decodedData = jsonDecode(utf8.decode(response.bodyBytes));
        debugPrint("🚀 Call lesson successfully");

        if (decodedData is List) {
          return decodedData.map((item) =>
              LessonModel.fromJson(item as Map<String, dynamic>)).toList();
        } else if (decodedData is Map<String, dynamic>) {
          if (decodedData.containsKey('data') && decodedData['data'] is List) {
            return (decodedData['data'] as List).map((item) =>
                LessonModel.fromJson(item as Map<String, dynamic>)).toList();
          } else if (decodedData.containsKey('result') &&
              decodedData['result'] is List) {
            return (decodedData['result'] as List).map((item) =>
                LessonModel.fromJson(item as Map<String, dynamic>)).toList();
          } else {
            throw Exception("Không tìm thấy danh sách bài học trong Object.");
          }
        } else {
          throw Exception("Định dạng dữ liệu lạ.");
        }
      } else {
        throw Exception("Lỗi server ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ LỖI LẤY LESSON: $e");
      throw Exception("Lỗi xử lý: $e");
    }
  }
}