import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/flashcard_model.dart';

class FlashcardService {
  // TODO: Thay thế bằng URL API thực tế của bạn
  final String baseUrl = "http://10.0.2.2:8080/api/flashcards";

  Future<List<FlashcardModel>> getFlashcardsByLesson(int lessonId) async {
    try {
      final Uri url = Uri.parse('$baseUrl/$lessonId');
      debugPrint("🚀 ĐANG GỌI API FLASHCARD: $url");

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isEmpty) return [];

        final dynamic decodedData = jsonDecode(utf8.decode(response.bodyBytes));
        debugPrint("🚀 Call flashcard successfully");

        if (decodedData is List) {
          return decodedData.map((item) => FlashcardModel.fromJson(item as Map<String, dynamic>)).toList();
        } else if (decodedData is Map<String, dynamic>) {
          if (decodedData.containsKey('data') && decodedData['data'] is List) {
            return (decodedData['data'] as List).map((item) => FlashcardModel.fromJson(item as Map<String, dynamic>)).toList();
          } else {
            throw Exception("Không tìm thấy danh sách thẻ.");
          }
        } else {
          throw Exception("Định dạng dữ liệu lạ.");
        }
      } else {
        throw Exception("Lỗi server ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ LỖI LẤY FLASHCARD: $e");
      throw Exception("Lỗi xử lý: $e");
    }
  }
}