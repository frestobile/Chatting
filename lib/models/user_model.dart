import 'dart:convert';

class User {
  final String id;
  final String username;
  final String name;
  final String email;
  final String avatarUrl;
  final String token;

  User(
      {this.id = 'dkjfdkfjdlkfd',
      required this.username,
      required this.name,
      required this.email,
      this.avatarUrl = 'dkljdlkjfdlkdf',
      required this.token});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'],
        username: json['username'],
        name: json['name'],
        email: json['email'],
        avatarUrl: json['avatar_url'],
        token: json['token']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
    };
  }

  // Convert to and from JSON string
  String toJsonString() => jsonEncode(toJson());
  factory User.fromJsonString(String jsonString) =>
      User.fromJson(jsonDecode(jsonString));
}
