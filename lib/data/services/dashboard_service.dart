import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:learn_math_app_03/core/constants/api_constants.dart';

import '../models/dashboard_model.dart';

class DashboardService {

  final String baseUrl = "${ApiConstants.baseUrl}/user";
  Future<DashboardResponse> getDashboardData(int userId, DateTime date) async {
    String dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    final url = Uri.parse("$baseUrl/$userId/dashboard?date=$dateStr");

    print("🚀 CALLING DASHBOARD API: $url");
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(
            utf8.decode(response.bodyBytes));
        return DashboardResponse.fromJson(data);
      } else if (response.statusCode == 400) {
        print("❌ Lỗi 400 (Bad Request): ${response.body}");
        throw Exception("Dữ liệu gửi lên không hợp lệ (Lỗi 400).");
      } else if (response.statusCode == 404) {
        print("❌ Lỗi 404 (Not Found): ${response.body}");
        throw Exception(
            "Không tìm thấy dữ liệu hoặc API không tồn tại (Lỗi 404).");
      } else if (response.statusCode == 500) {
        print("❌ Lỗi 500 (Server Error): ${response.body}");
        throw Exception("Lỗi hệ thống từ phía server Spring Boot (Lỗi 500).");
      } else {
        print("❌ Lỗi ${response.statusCode}: ${response.body}");
        throw Exception("Lỗi gọi API: Mã trạng thái ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Lỗi Exception Catch: $e");

      // 3. PHÂN LOẠI LỖI MẠNG VÀ LỖI PARSE CODE
      if (e.toString().contains('SocketException')) {
        throw Exception(
            "Không có kết nối mạng hoặc Server Spring Boot chưa bật.");
      } else if (e.toString().contains('FormatException')) {
        throw Exception(
            "Lỗi parse JSON. Server trả về dữ liệu không đúng chuẩn.");
      } else {
        throw Exception("Không thể kết nối đến máy chủ: $e");
      }
    }
  }
}