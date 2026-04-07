import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/subject_model.dart';
import 'package:flutter/foundation.dart';

import '../models/subject_progress_model.dart';

class SubjectService {
  final String baseUrl = "${ApiConstants.baseUrl}/subjects";

  Future<List<SubjectModel>> getSubjectsProgress(int userId) async {
    try {
      final Uri url = Uri.parse('$baseUrl/overview?userId=$userId');

      final response = await http.get(
        url,
        headers: ApiConstants.getAuthHeaders(),
      ).timeout(const Duration(seconds: 10));

      final dynamic decodedData = jsonDecode(utf8.decode(response.bodyBytes));
      debugPrint("🚀 Call subject successfully");

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (decodedData is List) {
          return decodedData.map((item) => SubjectModel.fromJson(item as Map<String, dynamic>)).toList();
        } else if (decodedData is Map<String, dynamic>) {
          if (decodedData.containsKey('data') && decodedData['data'] is List) {
            return (decodedData['data'] as List).map((item) => SubjectModel.fromJson(item as Map<String, dynamic>)).toList();
          } else if (decodedData.containsKey('result') && decodedData['result'] is List) {
            return (decodedData['result'] as List).map((item) => SubjectModel.fromJson(item as Map<String, dynamic>)).toList();
          } else if (decodedData.containsKey('content') && decodedData['content'] is List) {
            return (decodedData['content'] as List).map((item) => SubjectModel.fromJson(item as Map<String, dynamic>)).toList();
          } else {
            throw Exception("Không tìm thấy danh sách trong Object. Nội dung: $decodedData");
          }
        } else {
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

  Future<List<SubjectProgressModel>> fetchSubjectProgress(int userId) async {
    final url = '$baseUrl/progress?userId=$userId';

    print('🌐 ĐANG GỌI API: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: ApiConstants.getAuthHeaders(),
      );

      print('📦 MÃ PHẢN HỒI (Status Code): ${response.statusCode}');

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => SubjectProgressModel.fromJson(json)).toList();
      } else {
        print('❌ LỖI SERVER: ${response.statusCode} - Nội dung: ${response.body}');
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      print('🚫 LỖI KẾT NỐI: $e');
      throw Exception('Không thể kết nối đến server. Vui lòng kiểm tra mạng hoặc backend.');
    }
  }
}