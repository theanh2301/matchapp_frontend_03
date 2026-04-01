import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/practice_list_model.dart';
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
          } else if (decodedData.containsKey('result') && decodedData['result'] is Map<String, dynamic>) {
            return PracticeModel.fromJson(decodedData['result']);
          } else if (decodedData.containsKey('practiceType')) {
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

  /// Gọi API lấy danh sách các đề cần cải thiện (yếu)
  Future<List<PracticeListModel>> getWeakPractices(String practiceType, int userId) async {
    try {
      final Uri url = Uri.parse('$baseUrl/overview/weak?practiceType=$practiceType&userId=$userId');
      debugPrint("🚀 ĐANG GỌI API LẤY ĐỀ YẾU: $url");

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isEmpty) {
          debugPrint("⚠️ Server trả về body rỗng (Không có đề yếu nào).");
          return [];
        }

        final dynamic decodedData = jsonDecode(utf8.decode(response.bodyBytes));
        debugPrint("🚀 Lấy danh sách đề yếu thành công!");

        // Xử lý linh hoạt cấu trúc JSON trả về từ Backend
        List<dynamic> rawList = [];
        if (decodedData is List) {
          rawList = decodedData;
        } else if (decodedData is Map<String, dynamic>) {
          if (decodedData.containsKey('data') && decodedData['data'] is List) {
            rawList = decodedData['data'];
          } else if (decodedData.containsKey('result') && decodedData['result'] is List) {
            rawList = decodedData['result'];
          } else {
            throw Exception("Không tìm thấy danh sách đề yếu trong cấu trúc JSON.");
          }
        }

        // Parse danh sách dynamic thành List<PracticeListModel>
        return rawList.map((item) => PracticeListModel.fromJson(item as Map<String, dynamic>)).toList();

      } else {
        throw Exception("Lỗi server ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ LỖI LẤY ĐỀ YẾU: $e");
      throw Exception("Lỗi xử lý lấy dữ liệu đề yếu: $e");
    }
  }
}