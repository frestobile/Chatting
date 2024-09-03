class Channel {
  final String id;
  final String name;
  final String description;
  final bool isPrivate;
  final List<String> memberIds;

  Channel({
    required this.id,
    required this.name,
    this.description = '',
    this.isPrivate = false,
    this.memberIds = const [],
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      isPrivate: json['is_private'] as bool? ?? false,
      memberIds: (json['member_ids'] as List<dynamic>?)
              ?.map((id) => id as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'is_private': isPrivate,
      'member_ids': memberIds,
    };
  }
}
