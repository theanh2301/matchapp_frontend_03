import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../demo/demo_data.dart';
import '../models/profile_model.dart';

class ProfileService {
  final String baseUrl = "${ApiConstants.baseUrl}/profile";

  Future<ProfileResponse> getProfile(int userId) async {
    try {
      final response = await http
          .get(
            Uri.parse("$baseUrl/$userId"),
            headers: ApiConstants.getAuthHeaders(),
          )
          .timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(
          utf8.decode(response.bodyBytes),
        );
        return ProfileResponse.fromJson(data);
      }
    } catch (e) {
      debugPrint('Profile offline fallback: $e');
    }

    return DemoData.profile(10);
  }

  Future<UserInfoResponse> getUserInfo(int userId) async {
    try {
      final response = await http
          .get(
            Uri.parse("$baseUrl/$userId/info"),
            headers: ApiConstants.getAuthHeaders(),
          )
          .timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(
          utf8.decode(response.bodyBytes),
        );
        return UserInfoResponse.fromJson(data);
      }
    } catch (e) {
      debugPrint('User info offline fallback: $e');
    }

    return DemoData.userInfo(10);
  }

  Future<void> updateUserInfo(int userId, UpdateUserInfoRequest request) async {
    try {
      final headers = ApiConstants.getAuthHeaders();
      headers['Content-Type'] = 'application/json; charset=UTF-8';

      await http
          .put(
            Uri.parse("$baseUrl/$userId/info"),
            headers: headers,
            body: json.encode(request.toJson()),
          )
          .timeout(ApiConstants.requestTimeout);
    } catch (e) {
      debugPrint('User info update skipped offline: $e');
    }
  }
}
