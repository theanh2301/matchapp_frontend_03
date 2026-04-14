import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../core/constants/api_constants.dart';
import '../models/quiz_model.dart';
import '../models/quiz_progress_model.dart';

class QuizService {
  final String baseUrl = "${ApiConstants.baseUrl}/quiz";

  Future<List<QuizModel>> getQuizzesByLesson(int lessonId) async {
    try {
      final Uri url = Uri.parse('$baseUrl/$lessonId');
      debugPrint("🚀 ĐANG GỌI API QUIZ: $url");

      final response = await http.get(
        url,
        headers: ApiConstants.getAuthHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isEmpty) return [];

        final dynamic decodedData = jsonDecode(utf8.decode(response.bodyBytes));
        debugPrint("🚀 Call Quiz question successfully");

        if (decodedData is Map<String, dynamic> && decodedData.containsKey('data')) {
          final List<dynamic> listData = decodedData['data'];
          return listData.map((item) => QuizModel.fromJson(item as Map<String, dynamic>)).toList();
        } else if (decodedData is List) {
          return decodedData.map((item) => QuizModel.fromJson(item as Map<String, dynamic>)).toList();
        } else {
          throw Exception("Không tìm thấy danh sách câu hỏi.");
        }
      } else {
        throw Exception("Lỗi server: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ LỖI LẤY QUIZ: $e");
      throw Exception("Lỗi kết nối: $e");
    }
  }

  Future<bool> saveQuizProgress(SubmitQuizRequest request) async {
    if (request.answers.isEmpty) {
      print('⚠️ Không có câu trả lời Quiz nào để lưu.');
      return true;
    }

    final url = Uri.parse('$baseUrl/progress');

    String jsonBody = jsonEncode(request.toJson());

    print('📦 PAYLOAD QUIZ GỬI LÊN: $jsonBody');
    print('🚀 ĐANG GỌI API QUIZ: $url (Lưu ${request.answers.length} câu hỏi)');

    try {
      final response = await http.post(
        url,
        headers: ApiConstants.getAuthHeaders(),
        body: jsonBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Save quiz progress successfully');
        return true;
      } else {
        print("❌ Lỗi lưu Quiz: Code ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Lỗi kết nối khi lưu Quiz: $e");
      return false;
    }
  }
}