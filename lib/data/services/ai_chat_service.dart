import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';

class AiApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorType;

  const AiApiException(this.message, {this.statusCode, this.errorType});

  @override
  String toString() => message;
}

class AiChatMessageRequest {
  final int userId;
  final String message;
  final int? currentSubjectId;
  final int? currentChapterId;
  final int? currentLessonId;
  final String? sessionId;

  const AiChatMessageRequest({
    required this.userId,
    required this.message,
    this.currentSubjectId,
    this.currentChapterId,
    this.currentLessonId,
    this.sessionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'message': message,
      'currentSubjectId': currentSubjectId,
      'currentChapterId': currentChapterId,
      'currentLessonId': currentLessonId,
      'sessionId': sessionId,
    };
  }
}

class AiChatResponse {
  final String answer;
  final String? sessionId;
  final bool suggestPractice;
  final String? suggestedTopic;
  final List<String> weakTopics;
  final AiPracticeQuestion? practiceQuestion;

  const AiChatResponse({
    required this.answer,
    this.sessionId,
    this.suggestPractice = false,
    this.suggestedTopic,
    this.weakTopics = const [],
    this.practiceQuestion,
  });

  factory AiChatResponse.fromJson(Map<String, dynamic> json) {
    final data = _readData(json);

    return AiChatResponse(
      answer: (data['answer'] ?? json['message'] ?? '').toString(),
      sessionId: data['sessionId']?.toString(),
      suggestPractice: data['suggestPractice'] == true,
      suggestedTopic: data['suggestedTopic']?.toString(),
      weakTopics: _readStringList(data['weakTopics']),
      practiceQuestion: data['practiceQuestion'] is Map<String, dynamic>
          ? AiPracticeQuestion.fromJson(
              data['practiceQuestion'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class AiPracticeStartRequest {
  final int userId;
  final String? topic;
  final String difficulty;
  final bool weakTopic;
  final int? currentSubjectId;
  final int? currentChapterId;
  final int? currentLessonId;

  const AiPracticeStartRequest({
    required this.userId,
    this.topic,
    this.difficulty = 'easy',
    this.weakTopic = false,
    this.currentSubjectId,
    this.currentChapterId,
    this.currentLessonId,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'topic': topic,
      'difficulty': difficulty,
      'weakTopic': weakTopic,
      if (currentSubjectId != null) 'currentSubjectId': currentSubjectId,
      if (currentChapterId != null) 'currentChapterId': currentChapterId,
      if (currentLessonId != null) 'currentLessonId': currentLessonId,
    };
  }
}

class AiPracticeQuestion {
  final String question;
  final Map<String, String> options;
  final String? correctAnswer;
  final String? explanation;
  final String? topic;
  final String? difficulty;

  const AiPracticeQuestion({
    required this.question,
    required this.options,
    this.correctAnswer,
    this.explanation,
    this.topic,
    this.difficulty,
  });

  factory AiPracticeQuestion.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    final options = <String, String>{};

    if (rawOptions is Map) {
      rawOptions.forEach((key, value) {
        options[key.toString()] = value.toString();
      });
    }

    return AiPracticeQuestion(
      question: (json['question'] ?? '').toString(),
      options: options,
      correctAnswer: json['correctAnswer']?.toString(),
      explanation: json['explanation']?.toString(),
      topic: json['topic']?.toString(),
      difficulty: json['difficulty']?.toString(),
    );
  }
}

class AiPracticeResponse {
  final String? practiceSessionId;
  final AiPracticeQuestion? question;
  final bool? correct;
  final String? correctAnswer;
  final String? explanation;
  final int score;
  final int totalAnswered;
  final String? nextSuggestion;
  final bool active;

  const AiPracticeResponse({
    this.practiceSessionId,
    this.question,
    this.correct,
    this.correctAnswer,
    this.explanation,
    this.score = 0,
    this.totalAnswered = 0,
    this.nextSuggestion,
    this.active = false,
  });

  factory AiPracticeResponse.fromJson(Map<String, dynamic> json) {
    final data = _readData(json);

    return AiPracticeResponse(
      practiceSessionId: data['practiceSessionId']?.toString(),
      question: data['question'] is Map<String, dynamic>
          ? AiPracticeQuestion.fromJson(
              data['question'] as Map<String, dynamic>,
            )
          : null,
      correct: data['correct'] is bool ? data['correct'] as bool : null,
      correctAnswer: data['correctAnswer']?.toString(),
      explanation: data['explanation']?.toString(),
      score: _readInt(data['score']),
      totalAnswered: _readInt(data['totalAnswered']),
      nextSuggestion: data['nextSuggestion']?.toString(),
      active: data['active'] == true,
    );
  }
}

class AiChatService {
  final String baseUrl = '${ApiConstants.baseUrl}/ai';

  Future<AiChatResponse> sendMessage(AiChatMessageRequest request) async {
    final response = await _postJson('/chat', request.toJson());
    return AiChatResponse.fromJson(response);
  }

  Future<AiChatResponse> sendImageMessage({
    required int userId,
    required String message,
    required String imagePath,
    int? currentSubjectId,
    int? currentChapterId,
    int? currentLessonId,
    String? sessionId,
  }) async {
    final uri = Uri.parse('$baseUrl/chat/image');
    debugPrint('[AI API] POST multipart $uri');
    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(ApiConstants.getMultipartAuthHeaders())
      ..fields['userId'] = userId.toString()
      ..fields['message'] = message
      ..files.add(await http.MultipartFile.fromPath('image', imagePath));

    if (currentSubjectId != null) {
      request.fields['currentSubjectId'] = currentSubjectId.toString();
    }
    if (currentChapterId != null) {
      request.fields['currentChapterId'] = currentChapterId.toString();
    }
    if (currentLessonId != null) {
      request.fields['currentLessonId'] = currentLessonId.toString();
    }
    if (sessionId != null && sessionId.isNotEmpty) {
      request.fields['sessionId'] = sessionId;
    }

    try {
      final streamedResponse = await request.send().timeout(
        ApiConstants.aiRequestTimeout,
      );
      final response = await http.Response.fromStream(streamedResponse);
      debugPrint(
        '[AI API] ${response.statusCode} ${response.headers['content-type'] ?? ''}',
      );
      return AiChatResponse.fromJson(_decodeResponse(response));
    } catch (e) {
      debugPrint('AI image chat API error: $e');
      throw _normalizeException(e);
    }
  }

  Future<AiPracticeResponse> startPractice(
    AiPracticeStartRequest request,
  ) async {
    final response = await _postJson('/practice/start', request.toJson());
    return AiPracticeResponse.fromJson(response);
  }

  Future<AiPracticeResponse> answerPractice({
    required int userId,
    required String practiceSessionId,
    required String answer,
  }) async {
    final response = await _postJson('/practice/answer', {
      'userId': userId,
      'practiceSessionId': practiceSessionId,
      'answer': answer,
    });
    return AiPracticeResponse.fromJson(response);
  }

  Future<AiPracticeResponse> nextPractice({
    required int userId,
    required String practiceSessionId,
  }) async {
    final response = await _postJson('/practice/next', {
      'userId': userId,
      'practiceSessionId': practiceSessionId,
    });
    return AiPracticeResponse.fromJson(response);
  }

  Future<AiPracticeResponse> stopPractice({
    required int userId,
    required String practiceSessionId,
  }) async {
    final response = await _postJson('/practice/stop', {
      'userId': userId,
      'practiceSessionId': practiceSessionId,
    });
    return AiPracticeResponse.fromJson(response);
  }

  Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('$baseUrl$path');
    debugPrint('[AI API] POST $url');

    try {
      final response = await http
          .post(
            url,
            headers: ApiConstants.getAuthHeaders(),
            body: jsonEncode(body),
          )
          .timeout(ApiConstants.aiRequestTimeout);

      debugPrint(
        '[AI API] ${response.statusCode} ${response.headers['content-type'] ?? ''}',
      );
      return _decodeResponse(response);
    } catch (e) {
      debugPrint('AI API error at $path: $e');
      throw _normalizeException(e);
    }
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    final contentType = response.headers['content-type'] ?? '';
    final responseText = utf8.decode(response.bodyBytes);

    if (responseText.trimLeft().startsWith('<!DOCTYPE html') ||
        responseText.trimLeft().startsWith('<html') ||
        contentType.contains('text/html')) {
      throw AiApiException(
        'Backend đang trả về trang HTML/login thay vì JSON API. Hãy kiểm tra JWT, security cho /api/** và API_BASE_URL.',
        statusCode: response.statusCode,
      );
    }

    final decoded = responseText.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(responseText);

    final body = decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{'data': decoded};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    throw AiApiException(
      (body['message'] ?? 'AI hiện chưa phản hồi được, bạn thử lại nhé.')
          .toString(),
      statusCode: response.statusCode,
      errorType: body['errorType']?.toString(),
    );
  }

  AiApiException _normalizeException(Object error) {
    if (error is AiApiException) return error;
    if (error is TimeoutException) {
      return const AiApiException(
        'AI phản hồi hơi lâu. Bạn thử gửi lại câu hỏi hoặc rút gọn nội dung nhé.',
      );
    }
    return const AiApiException(
      'Không kết nối được trợ lý AI. Bạn kiểm tra mạng hoặc thử lại sau nhé.',
    );
  }
}

Map<String, dynamic> _readData(Map<String, dynamic> json) {
  final rawData = json['data'];
  if (rawData is Map<String, dynamic>) return rawData;
  return json;
}

List<String> _readStringList(dynamic value) {
  if (value is! List) return const [];
  return value.map((item) => item.toString()).toList();
}

int _readInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
