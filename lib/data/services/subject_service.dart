import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/ApiConstants.dart';
import '../models/subject_model.dart';
import 'package:flutter/foundation.dart'; // Để dùng debugPrint

class SubjectService {
  final String baseUrl = "${ApiConstants.baseUrl}/subjects/overview";

  Future<List<SubjectModel>> getSubjectsProgress(int userId) async {
    try {
      final Uri url = Uri.parse('$baseUrl?userId=$userId');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(const Duration(seconds: 10));

      // Dù thành công hay thất bại, ta cứ decode ra trước để xem
      final dynamic decodedData = jsonDecode(utf8.decode(response.bodyBytes));

      // 🚀 IN RA ĐỂ KIỂM TRA CHÍNH XÁC SERVER TRẢ VỀ GÌ
      debugPrint("🚀 Call subject successfully");

      if (response.statusCode == 200 || response.statusCode == 201) {

        // TRƯỜNG HỢP 1: API trả về trực tiếp một Danh sách [...]
        if (decodedData is List) {
          return decodedData.map((item) => SubjectModel.fromJson(item as Map<String, dynamic>)).toList();
        }
        // TRƯỜNG HỢP 2: API trả về một Object {...}
        else if (decodedData is Map<String, dynamic>) {

          // Kiểm tra xem danh sách môn học có bị giấu trong các từ khóa phổ biến không
          if (decodedData.containsKey('data') && decodedData['data'] is List) {
            return (decodedData['data'] as List).map((item) => SubjectModel.fromJson(item as Map<String, dynamic>)).toList();
          }
          else if (decodedData.containsKey('result') && decodedData['result'] is List) {
            return (decodedData['result'] as List).map((item) => SubjectModel.fromJson(item as Map<String, dynamic>)).toList();
          }
          else if (decodedData.containsKey('content') && decodedData['content'] is List) {
            return (decodedData['content'] as List).map((item) => SubjectModel.fromJson(item as Map<String, dynamic>)).toList();
          }
          else {
            // Nếu không tìm thấy, quăng lỗi kèm theo nội dung JSON để ta dễ sửa
            throw Exception("Không tìm thấy danh sách trong Object. Nội dung: $decodedData");
          }
        }
        else {
          throw Exception("Định dạng dữ liệu lạ: ${decodedData.runtimeType}");
        }
      } else {
        throw Exception("Lỗi server ${response.statusCode}: $decodedData");
      }
    } catch (e) {
      debugPrint("❌ LỖI THẬT SỰ LÀ: $e");
      throw Exception("Lỗi xử lý: $e");
    }
  }
}