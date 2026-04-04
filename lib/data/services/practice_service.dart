import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../core/constants/ApiConstants.dart';
import '../models/practice_list_model.dart';
import '../models/practice_model.dart';

class PracticeService {
  final String baseUrl = "${ApiConstants.baseUrl}/practices";

  /// Lấy thống kê tiến độ của một loại bài tập
  Future<AllPracticeStatsModel> getAllPracticeStats(int userId) async {
    try {
      // Lưu ý kiểm tra lại URL API của bạn cho chính xác
      final Uri url = Uri.parse('$baseUrl/stats?userId=$userId');
      debugPrint("🚀 ĐANG GỌI API STATS: $url");

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isEmpty) {
          debugPrint("⚠️ Server trả về body rỗng.");
          return _emptyStats(); // Trả về dữ liệu trống an toàn
        }

        final dynamic decodedData = jsonDecode(utf8.decode(response.bodyBytes));
        debugPrint("🚀 Call stats successfully");

        // Trực tiếp truyền cục JSON vào hàm fromJson của class tổng
        if (decodedData is Map<String, dynamic>) {
          return AllPracticeStatsModel.fromJson(decodedData);
        } else {
          throw Exception("Định dạng dữ liệu lạ, mong đợi một Object Map<String, dynamic>.");
        }
      } else {
        throw Exception("Lỗi server ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ LỖI LẤY STATS: $e");
      return _emptyStats();
    }
  }

// Hàm phụ trợ tạo dữ liệu rỗng an toàn khi có lỗi mạng/server
  AllPracticeStatsModel _emptyStats() {
    return AllPracticeStatsModel(
      dailyStats: PracticeModel(practiceType: 'DAILY', totalPractice: 0, completedPractice: 0),
      topicStats: PracticeModel(practiceType: 'TOPIC', totalPractice: 0, completedPractice: 0),
      challengeStats: PracticeModel(practiceType: 'CHALLENGE', totalPractice: 0, completedPractice: 0),
    );
  }

  /// Gọi API lấy danh sách các đề cần cải thiện (yếu)
  Future<List<PracticeListModel>> getWeakPractices(int userId) async {
    try {
      final Uri url = Uri.parse('$baseUrl/overview/weak?userId=$userId');
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