class ProfileResponse {
  final String? fullName;
  final String? email;
  final String? avatarUrl;
  final String? gradeName;
  final String? role;
  final bool isPremium;
  final int totalXp;
  final int totalLesson;
  final int streakDay;

  ProfileResponse({
    this.fullName,
    this.email,
    this.avatarUrl,
    this.gradeName,
    this.role,
    required this.isPremium,
    required this.totalXp,
    required this.totalLesson,
    required this.streakDay,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      fullName: json['fullName'],
      email: json['email'],
      avatarUrl: json['avatarUrl'],
      gradeName: json['gradeName'],
      role: json['role'],
      isPremium: json['isPremium'] ?? false,
      totalXp: json['totalXp'] ?? 0,
      totalLesson: json['totalLesson'] ?? 0,
      streakDay: json['streakDay'] ?? 0,
    );
  }
}

class UserInfoResponse {
  final String? fullName;
  final String? email;
  final String? phone;
  final String? dob;
  final String? avatarUrl;
  final String? gradeName;
  final String? role;
  final bool isPremium;

  UserInfoResponse({
    this.fullName,
    this.email,
    this.phone,
    this.dob,
    this.avatarUrl,
    this.gradeName,
    this.role,
    required this.isPremium,
  });

  factory UserInfoResponse.fromJson(Map<String, dynamic> json) {
    return UserInfoResponse(
      fullName: json['fullName'],
      email: json['email'],
      phone: json['phone'],
      dob: json['dob'],
      avatarUrl: json['avatarUrl'],
      gradeName: json['gradeName'],
      role: json['role'],
      isPremium: json['isPremium'] ?? false,
    );
  }
}

class UpdateUserInfoRequest {
  final String? fullName;
  final String? email;
  final String? phone;
  final String? dob;
  final int? gradeId;
  final String? avatarUrl;

  UpdateUserInfoRequest({
    this.fullName,
    this.email,
    this.phone,
    this.dob,
    this.gradeId,
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      if (fullName != null) 'fullName': fullName,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (dob != null) 'dob': dob,
      if (gradeId != null) 'gradeId': gradeId,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
    };
  }
}