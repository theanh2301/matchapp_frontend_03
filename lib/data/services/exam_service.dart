import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../core/constants/api_constants.dart';
import '../models/exam_model.dart';
import '../models/practice_model.dart';
import '../models/practice_progress_model.dart';

class PracticeListService {
  final String baseUrl = "${ApiConstants.baseUrl}/practices";

  Future<List<PracticeQuestionModel>> getPracticeQuestions(int practiceId) async {
    try {
      final Uri url = Uri.parse('$baseUrl/$practiceId');
      debugPrint("🚀 ĐANG GỌI API LẤY CÂU HỎI: $url");

      final response = await http.get(
        url,
        headers: ApiConstants.getAuthHeaders(),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isEmpty) {
          debugPrint("⚠️ Server trả về body rỗng (chưa có câu hỏi).");
          return [];
        }

        final dynamic decodedData = jsonDecode(utf8.decode(response.bodyBytes));
        debugPrint("🚀 Lấy danh sách câu hỏi thành công!");

        if (decodedData is List) {
          return decodedData.map((item) => PracticeQuestionModel.fromJson(item as Map<String, dynamic>)).toList();
        } else if (decodedData is Map<String, dynamic>) {
          if (decodedData.containsKey('data') && decodedData['data'] is List) {
            return (decodedData['data'] as List).map((item) => PracticeQuestionModel.fromJson(item as Map<String, dynamic>)).toList();
          } else if (decodedData.containsKey('result') && decodedData['result'] is List) {
            return (decodedData['result'] as List).map((item) => PracticeQuestionModel.fromJson(item as Map<String, dynamic>)).toList();
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

  Future<void> saveQuizProgress(PracticeProgressRequest request) async {
    final url = Uri.parse('$baseUrl/progress');

    debugPrint('🚀 ĐANG GỌI API QUIZ: $url (Lưu bài tập ID: ${request.practiceId} với ${request.answers.length} câu hỏi)');

    try {
      final response = await http.post(
        url,
        headers: ApiConstants.getAuthHeaders(),
        body: jsonEncode(request.toJson()), // Encode toàn bộ cục data 1 lần
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Lưu tiến độ Quiz thành công cho Practice ID: ${request.practiceId}');
      } else {
        debugPrint("❌ Lỗi lưu Quiz: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ Lỗi kết nối khi lưu Quiz: $e");
    }
  }

  Future<List<WrongQuestionModel>> getWrongQuestionsDetail(int practiceId, int userId) async {
    try {
      final Uri url = Uri.parse('$baseUrl/$practiceId/wrong-questions-detail?userId=$userId');
      debugPrint("🚀 ĐANG GỌI API LẤY CHI TIẾT CÂU SAI: $url");

      final response = await http.get(
        url,
        headers: ApiConstants.getAuthHeaders(),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isEmpty) return [];

        final dynamic decodedData = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> rawList = [];
        if (decodedData is List) {
          rawList = decodedData;
        } else if (decodedData is Map<String, dynamic> && decodedData.containsKey('data')) {
          rawList = decodedData['data'];
        }

        return rawList.map((item) => WrongQuestionModel.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        throw Exception("Lỗi server ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Lỗi lấy dữ liệu câu sai: $e");
    }
  }

  Future<List<PracticeQuestionModel>> getWrongQuestionsForExam(int practiceId, int userId) async {
    try {
      final Uri url = Uri.parse('$baseUrl/$practiceId/wrong-questions-exam?userId=$userId');
      debugPrint("🚀 ĐANG GỌI API LẤY CÂU SAI CHO EXAM: $url");

      final response = await http.get(
        url,
        headers: ApiConstants.getAuthHeaders(),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isEmpty) return [];

        final dynamic decodedData = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> rawList = [];
        if (decodedData is List) {
          rawList = decodedData;
        } else if (decodedData is Map<String, dynamic> && decodedData.containsKey('data')) {
          rawList = decodedData['data'];
        }

        return rawList.map((item) => PracticeQuestionModel.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        throw Exception("Lỗi server ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Lỗi lấy dữ liệu exam câu sai: $e");
    }
  }
}