import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/quiz_model.dart';
import '../models/quiz_progress_model.dart';

class QuizService {
  // TODO: Điều chỉnh URL cho khớp với API của bạn
  final String baseUrl = "http://10.0.2.2:8080/api/quiz";

  Future<List<QuizModel>> getQuizzesByLesson(int lessonId) async {
    try {
      final Uri url = Uri.parse('$baseUrl/$lessonId');
      debugPrint("🚀 ĐANG GỌI API QUIZ: $url");

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
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

  Future<bool> saveQuizProgress(List<QuizProgressRequest> requests) async {
    if (requests.isEmpty) {
      print('⚠️ Không có câu trả lời Quiz nào để lưu.');
      return true;
    }

    // ⚠️ LƯU Ý QUAN TRỌNG: Hãy đảm bảo URL này khớp với endpoint BATCH mới bên Spring Boot
    // Ví dụ: tách riêng thành /progress/quiz/batch để không bị trùng lặp với Flashcard
    final url = Uri.parse('$baseUrl/progress/batch');

    print('🚀 ĐANG GỌI API BATCH QUIZ: $url (Lưu ${requests.length} câu hỏi cùng lúc)');

    try {
      // 1. Biến mảng Object thành mảng JSON [{}, {}, ...]
      final List<Map<String, dynamic>> jsonData = requests.map((req) => req.toJson()).toList();

      // 2. Gửi 1 request duy nhất
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(jsonData), // Encode toàn bộ mảng
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Save ${requests.length} quiz progress successfully');
        return true; // Trả về true để UI biết đã lưu thành công
      } else {
        print("❌ Lỗi lưu Quiz: Code ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Lỗi kết nối khi lưu Quiz: $e");
      return false;
    }
  }

  /*Future<void> saveQuizProgress(List<QuizProgressRequest> requests) async {
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
  }*/

}