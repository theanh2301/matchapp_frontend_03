import '../../data/services/auth_service.dart';

class ApiConstants {
  static const Duration requestTimeout = Duration(seconds: 4);
  static const Duration aiRequestTimeout = Duration(seconds: 45);

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080/api',
  );

  static Map<String, String> getAuthHeaders() {
    final String? token = AuthService.token;

    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Map<String, String> getMultipartAuthHeaders() {
    final String? token = AuthService.token;

    return {
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }
}
