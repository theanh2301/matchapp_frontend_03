import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../core/constants/api_constants.dart';
import '../models/flashcard_model.dart';
import '../models/flashcard_progress_request.dart';

class FlashcardService {
  final String baseUrl = "${ApiConstants.baseUrl}/flashcards";

  Future<List<FlashcardModel>> getFlashcardsByLesson(int lessonId) async {
    try {
      final Uri url = Uri.parse('$baseUrl/$lessonId');
      debugPrint("🚀 ĐANG GỌI API FLASHCARD: $url");

      final response = await http.get(
        url,
        headers: ApiConstants.getAuthHeaders(),
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
    if (requests.isEmpty) {
      print('⚠️ Không có thẻ nào để lưu.');
      return true;
    }

    final url = Uri.parse('$baseUrl/progress/batch');

    print('🚀 ĐANG GỌI API BATCH FLASHCARD: $url (Lưu ${requests.length} thẻ cùng lúc)');

    try {
      final List<Map<String, dynamic>> jsonData = requests.map((req) => req.toJson()).toList();

      final response = await http.post(
        url,
        headers: ApiConstants.getAuthHeaders(),
        body: jsonEncode(jsonData),
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
    final url = Uri.parse('$baseUrl/progress/batch');

    print('🚀 ĐANG GỌI API FLASHCARD: $url (Lưu thẻ ID: ${request.flashcardId})');

    try {
      final response = await http.post(
        url,
        headers: ApiConstants.getAuthHeaders(),
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
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

  Future<void> saveMultipleProgress(List<FlashcardProgressRequest> requests) async {
    for (var request in requests) {
      await saveSingleProgress(request);
    }
  }*/

}