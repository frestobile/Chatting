import 'dart:convert';

class User {
  final String username;
  final String email;
  final String token;

  User({required this.username, required this.email, required this.token});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        username: json['username'], email: json['email'], token: json['token']);
  }

  Map<String, dynamic> toJson() {
    return {'username': username, 'email': email, 'token': token};
  }

  // Convert to and from JSON string
  String toJsonString() => jsonEncode(toJson());
  factory User.fromJsonString(String jsonString) =>
      User.fromJson(jsonDecode(jsonString));
}
