import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../models/performance_model.dart';

class PerformanceService {
  final String baseUrl = "${ApiConstants.baseUrl}/subjects/performance";

  Future<List<SubjectPerformanceModel>> getSubjectPerformance(int userId) async {
    final url = Uri.parse("$baseUrl/subjects/$userId");

    try {
      final response = await http.get(url, headers: ApiConstants.getAuthHeaders());

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((e) => SubjectPerformanceModel.fromJson(e)).toList();
      } else {
        throw Exception("Lỗi tải đánh giá môn học: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Lỗi kết nối API Subject Performance: $e");
    }
  }

  Future<List<TypePerformanceModel>> getTypePerformance(int userId) async {
    final url = Uri.parse("$baseUrl/types/$userId");

    try {
      final response = await http.get(url, headers: ApiConstants.getAuthHeaders());

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((e) => TypePerformanceModel.fromJson(e)).toList();
      } else {
        throw Exception("Lỗi tải đánh giá dạng bài: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Lỗi kết nối API Type Performance: $e");
    }
  }
}