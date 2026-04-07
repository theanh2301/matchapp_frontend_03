import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../core/constants/api_constants.dart';
import '../models/suggest_lesson_model.dart';

class SuggestedLessonService {

  Future<List<SuggestedLessonModel>> getSuggestedLessons(int userId) async {
    final String urlString = "${ApiConstants.baseUrl}/lessons/suggested-lessons?userId=$userId";
    final Uri url = Uri.parse(urlString);

    debugPrint("🚀 ĐANG GỌI API SUGGESTED LESSONS: $urlString");

    try {
      final response = await http.get(
        url,
        headers: ApiConstants.getAuthHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(utf8.decode(response.bodyBytes));

        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> dataList = responseData['data'];
          List<SuggestedLessonModel> lessons = dataList
              .map((jsonItem) => SuggestedLessonModel.fromJson(jsonItem))
              .toList();
          return lessons;
        } else {
          throw Exception("Không tìm thấy danh sách bài học gợi ý.");
        }
      } else {
        debugPrint("❌ Lỗi từ Server: ${response.statusCode} - ${response.body}");
        throw Exception("Lỗi gọi API: Mã trạng thái ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Lỗi kết nối: $e");
      throw Exception("Không thể kết nối đến máy chủ: $e");
    }
  }
}