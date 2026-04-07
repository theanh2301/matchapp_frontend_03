import '../../data/services/auth_service.dart';

class ApiConstants {
  static const String baseUrl = "http://10.0.2.2:8080/api";

  static Map<String, String> getAuthHeaders() {
    final String? token = AuthService.token;

    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }
}