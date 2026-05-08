import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../models/daily_challenge_model.dart';

class DailyChallengeService {
  // Thay đổi baseUrl cho phù hợp với API /today/{userId}
  final String baseUrl = "${ApiConstants.baseUrl}/challenges/today";

  Future<List<DailyChallengeModel>> getTodayChallenges(int userId) async {
    final url = Uri.parse("$baseUrl/$userId");
    try {
      final response = await http.get(
        url,
        headers: ApiConstants.getAuthHeaders(), // Nhớ đính kèm Token
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((e) => DailyChallengeModel.fromJson(e)).toList();
      } else {
        throw Exception("Lỗi tải thử thách: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Lỗi kết nối API Daily Challenge: $e");
    }
  }
}