class Coworker {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String status;

  Coworker({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl = '',
    this.status = 'online',
  });

  factory Coworker.fromJson(Map<String, dynamic> json) {
    return Coworker(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String? ?? '',
      status: json['status'] as String? ?? 'online',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'status': status,
    };
  }
}
