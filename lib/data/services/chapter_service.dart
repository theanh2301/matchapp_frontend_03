import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../models/chapter_model.dart'; // Để dùng debugPrint

class ChapterService {
  final String baseUrl = "http://10.0.2.2:8080/api/chapters";

  // Hàm lấy danh sách chương của 1 môn học
  Future<List<ChapterModel>> getChaptersOverview(int userId, int subjectId) async {
    try {
      final Uri url = Uri.parse('$baseUrl/$subjectId/chapters?userId=$userId');

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      ).timeout(const Duration(seconds: 10));

      // 1. KIỂM TRA MÃ TRẠNG THÁI TRƯỚC (200 là thành công)
      if (response.statusCode == 200 || response.statusCode == 201) {

        // 2. NẾU SERVER TRẢ VỀ RỖNG HOÀN TOÀN -> BÁO CHƯA CÓ CHƯƠNG NÀO
        if (response.body.isEmpty) {
          debugPrint("⚠️ Server trả về body rỗng (chưa có chương nào).");
          return []; // Trả về danh sách rỗng để UI hiện "Chưa có chương nào"
        }

        // Nếu có dữ liệu thì mới tiến hành dịch JSON
        final dynamic decodedData = jsonDecode(utf8.decode(response.bodyBytes));
        debugPrint("🚀 Call chapter successfully");

        if (decodedData is List) {
          return decodedData.map((item) => ChapterModel.fromJson(item as Map<String, dynamic>)).toList();
        } else if (decodedData is Map<String, dynamic>) {
          if (decodedData.containsKey('data') && decodedData['data'] is List) {
            return (decodedData['data'] as List).map((item) => ChapterModel.fromJson(item as Map<String, dynamic>)).toList();
          } else if (decodedData.containsKey('result') && decodedData['result'] is List) {
            return (decodedData['result'] as List).map((item) => ChapterModel.fromJson(item as Map<String, dynamic>)).toList();
          } else {
            throw Exception("Không tìm thấy danh sách chương trong Object.");
          }
        } else {
          throw Exception("Định dạng dữ liệu lạ.");
        }
      } else {
        // Nếu bị lỗi 404, 500... thì in ra luôn để dễ fix backend
        throw Exception("Lỗi server ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ LỖI LẤY CHAPTER: $e");
      throw Exception("Lỗi xử lý: $e");
    }
  }
}