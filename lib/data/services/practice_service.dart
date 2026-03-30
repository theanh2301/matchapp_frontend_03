import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/practice_model.dart';
class PracticeService {
  final String baseUrl = "http://10.0.2.2:8080/api/practices";

  // ... (Hàm getPracticeOverview cũ nằm ở đây) ...

  /// Lấy thống kê tiến độ của một loại bài tập
  Future<PracticeModel> getPracticeStats(String practiceType, int userId) async {
    try {
      final Uri url = Uri.parse('$baseUrl/stats?practiceType=$practiceType&userId=$userId');
      debugPrint("🚀 ĐANG GỌI API STATS: $url");

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isEmpty) {
          debugPrint("⚠️ Server trả về body rỗng.");
          return PracticeModel(practiceType: practiceType, totalPractice: 0, completedPractice: 0);
        }

        final dynamic decodedData = jsonDecode(utf8.decode(response.bodyBytes));
        debugPrint("🚀 Call stats successfully");

        if (decodedData is Map<String, dynamic>) {
          if (decodedData.containsKey('data') && decodedData['data'] is Map<String, dynamic>) {
            return PracticeModel.fromJson(decodedData['data']);
          }
          else if (decodedData.containsKey('result') && decodedData['result'] is Map<String, dynamic>) {
            return PracticeModel.fromJson(decodedData['result']);
          }
          else if (decodedData.containsKey('practiceType')) {
            return PracticeModel.fromJson(decodedData);
          } else {
            return PracticeModel(practiceType: practiceType, totalPractice: 0, completedPractice: 0);
          }
        } else {
          throw Exception("Định dạng dữ liệu lạ, mong đợi một Object Map<String, dynamic>.");
        }
      } else {
        throw Exception("Lỗi server ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ LỖI LẤY STATS: $e");
      return PracticeModel(practiceType: practiceType, totalPractice: 0, completedPractice: 0);
    }
  }
}