
class UserModel {
  final String? id;
  final String email;
  final String? name;

  UserModel({this.id, required this.email, this.name});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString(),
      email: json['email'] ?? '',
      name: json['name'],
    );
  }
}