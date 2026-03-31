import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/exam_model.dart';
import '../models/practice_progress_model.dart';

class PracticeListService {
  final String baseUrl = "http://10.0.2.2:8080/api/practices";

  Future<List<PracticeQuestionModel>> getPracticeQuestions(int practiceId) async {
    try {
      // SỬA DÒNG NÀY: URL chỉ cần ID của bài tập
      final Uri url = Uri.parse('$baseUrl/$practiceId');

      debugPrint("🚀 ĐANG GỌI API LẤY CÂU HỎI CHO PRACTICE_ID: $practiceId");

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isEmpty) {
          debugPrint("⚠️ Server trả về body rỗng (chưa có câu hỏi).");
          return [];
        }

        final dynamic decodedData = jsonDecode(utf8.decode(response.bodyBytes));
        debugPrint("🚀 Lấy danh sách câu hỏi thành công!");

        if (decodedData is List) {
          return decodedData.map((item) =>
              PracticeQuestionModel.fromJson(item as Map<String, dynamic>)).toList();
        } else if (decodedData is Map<String, dynamic>) {
          if (decodedData.containsKey('data') && decodedData['data'] is List) {
            return (decodedData['data'] as List).map((item) =>
                PracticeQuestionModel.fromJson(item as Map<String, dynamic>)).toList();
          } else if (decodedData.containsKey('result') &&
              decodedData['result'] is List) {
            return (decodedData['result'] as List).map((item) =>
                PracticeQuestionModel.fromJson(item as Map<String, dynamic>)).toList();
          } else {
            throw Exception("Không tìm thấy danh sách câu hỏi trong Object JSON.");
          }
        } else {
          throw Exception("Định dạng dữ liệu lạ, mong đợi List hoặc Object chứa List.");
        }
      } else {
        throw Exception("Lỗi server ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ LỖI LẤY CÂU HỎI: $e");
      throw Exception("Lỗi xử lý: $e");
    }
  }

  Future<void> saveQuizProgress(List<PracticeProgressRequest> requests) async {
    // Thay đổi domain/IP phù hợp với môi trường của bạn
    final url = Uri.parse('$baseUrl/progress');

    for (var request in requests) {
      print('🚀 ĐANG GỌI API QUIZ: $url (Lưu câu hỏi ID: ${request.questionId})');

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(request.toJson()),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          print('🚀 Call quiz progress successfully for Question ${request.questionId}');
        } else {
          print("Lỗi lưu Quiz ${request.questionId}: ${response.body}");
        }
      } catch (e) {
        print("Lỗi kết nối khi lưu Quiz ${request.questionId}: $e");
      }
    }
  }

}