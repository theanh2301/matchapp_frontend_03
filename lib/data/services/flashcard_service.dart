import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../core/constants/ApiConstants.dart';
import '../models/flashcard_model.dart';
import '../models/flashcard_progress_request.dart';

class FlashcardService {
  // TODO: Thay thế bằng URL API thực tế của bạn
  final String baseUrl = "${ApiConstants.baseUrl}/flashcards";

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

  Future<bool> saveMultipleProgress(List<FlashcardProgressRequest> requests) async {
    // Nếu danh sách rỗng thì không cần gọi API
    if (requests.isEmpty) {
      print('⚠️ Không có thẻ nào để lưu.');
      return true;
    }

    // Thay đổi URL thành endpoint batch của bạn
    final url = Uri.parse('$baseUrl/progress/batch');

    print('🚀 ĐANG GỌI API BATCH FLASHCARD: $url (Lưu ${requests.length} thẻ cùng lúc)');

    try {
      // Biến List<FlashcardProgressRequest> thành List<Map> để encode ra mảng JSON [{}, {}]
      final List<Map<String, dynamic>> jsonData = requests.map((req) => req.toJson()).toList();

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(jsonData), // Convert mảng thành chuỗi JSON
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Save ${requests.length} flashcards successfully');
        return true;
      } else {
        print("❌ Lỗi lưu batch thẻ: Code ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Lỗi kết nối khi lưu batch thẻ: $e");
      return false;
    }
  }

 /* Future<bool> saveSingleProgress(FlashcardProgressRequest request) async {
    // Thay đổi URL thành domain/IP thực tế của backend
    final url = Uri.parse('$baseUrl/progress/batch');

    // 1. Thêm log thông báo BẮT ĐẦU gọi API
    print('🚀 ĐANG GỌI API FLASHCARD: $url (Lưu thẻ ID: ${request.flashcardId})');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 2. Thêm log thông báo THÀNH CÔNG
        print('🚀 Save flashcard successfully');
        return true;
      } else {
        print("Lỗi lưu thẻ ${request.flashcardId}: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Lỗi kết nối khi lưu thẻ ${request.flashcardId}: $e");
      return false;
    }
  }

  // Hàm nhận danh sách thẻ đã quẹt để lưu lần lượt
  Future<void> saveMultipleProgress(List<FlashcardProgressRequest> requests) async {
    for (var request in requests) {
      await saveSingleProgress(request);
    }
  }*/

}