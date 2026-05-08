import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../models/profile_model.dart';

class ProfileService {
  final String baseUrl = "${ApiConstants.baseUrl}/profile";

  Future<ProfileResponse> getProfile(int userId) async {
    final url = Uri.parse("$baseUrl/$userId");
    try {
      final response = await http.get(
        url,
        headers: ApiConstants.getAuthHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return ProfileResponse.fromJson(data);
      } else {
        throw Exception("Lỗi tải thông tin Profile: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Lỗi kết nối API Profile: $e");
    }
  }

  Future<UserInfoResponse> getUserInfo(int userId) async {
    final url = Uri.parse("$baseUrl/$userId/info");
    try {
      final response = await http.get(
        url,
        headers: ApiConstants.getAuthHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return UserInfoResponse.fromJson(data);
      } else {
        throw Exception("Lỗi tải thông tin chi tiết User: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Lỗi kết nối API User Info: $e");
    }
  }

  Future<void> updateUserInfo(int userId, UpdateUserInfoRequest request) async {
    final url = Uri.parse("$baseUrl/$userId/info");
    try {
      // Đảm bảo có Content-Type là application/json
      Map<String, String> headers = ApiConstants.getAuthHeaders();
      headers['Content-Type'] = 'application/json; charset=UTF-8';

      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(request.toJson()),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Lỗi cập nhật thông tin: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Lỗi kết nối API Update User Info: $e");
    }
  }
}