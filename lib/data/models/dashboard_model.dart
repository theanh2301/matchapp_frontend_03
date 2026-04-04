class DashboardResponse {
  final UserStatResponse stats;
  final List<XpChartResponse> weeklyXp;

  DashboardResponse({required this.stats, required this.weeklyXp});

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      stats: UserStatResponse.fromJson(json['stats']),
      weeklyXp: (json['weeklyXp'] as List)
          .map((item) => XpChartResponse.fromJson(item))
          .toList(),
    );
  }
}

class UserStatResponse {
  final int userId;
  final int totalXP;
  final int totalLesson;
  final int? totalStudyDay; // API có thể trả về null như trong ảnh
  final int streakDay;
  final String? lastDayStudy;

  UserStatResponse({
    required this.userId,
    required this.totalXP,
    required this.totalLesson,
    this.totalStudyDay,
    required this.streakDay,
    this.lastDayStudy,
  });

  factory UserStatResponse.fromJson(Map<String, dynamic> json) {
    return UserStatResponse(
      userId: json['userId'] ?? 0,
      totalXP: json['totalXP'] ?? 0,
      totalLesson: json['totalLesson'] ?? 0,
      totalStudyDay: json['totalStudyDay'],
      streakDay: json['streakDay'] ?? 0,
      lastDayStudy: json['lastDayStudy'],
    );
  }
}

class XpChartResponse {
  final String date;
  final int totalXp;

  XpChartResponse({required this.date, required this.totalXp});

  factory XpChartResponse.fromJson(Map<String, dynamic> json) {
    return XpChartResponse(
      date: json['date'] ?? "",
      totalXp: json['totalXp'] ?? 0,
    );
  }
}