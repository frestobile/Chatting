class Coworker {
  final String id;
  final String username;
  final String email;
  final String displayName;
  final String createdAt;
  final String updatedAt;
  final bool isOnline;
  final String avatarUrl;

  Coworker({
    required this.id,
    required this.username,
    required this.email,
    required this.displayName,
    required this.createdAt,
    required this.updatedAt,
    required this.isOnline,
    this.avatarUrl = '',
  });

  factory Coworker.fromJson(Map<String, dynamic> json) {
    return Coworker(
      id: json['_id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      avatarUrl: json['avatar'] as String? ?? '',
      isOnline: json['isOnline'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'email': email,
      'displayName': displayName,
      'avatar': avatarUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isOnline': isOnline,
    };
  }
}
