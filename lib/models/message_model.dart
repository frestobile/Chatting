class Message {
  final String id;
  final String channelId;
  final String content;
  final String senderId;
  final String senderName;
  final String senderAvatarUrl;
  final String? parentId;
  final DateTime timestamp;
  final Map<String, int> reactions; // e.g., {'👍': 3, '❤️': 2}

  Message({
    required this.id,
    required this.channelId,
    required this.content,
    required this.senderId,
    required this.senderName,
    required this.senderAvatarUrl,
    required this.timestamp,
    this.parentId,
    this.reactions = const {},
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      channelId: json['channel_id'],
      content: json['content'],
      senderId: json['sender_id'],
      senderName: json['sender_name'],
      senderAvatarUrl: json['sender_avatar_url'],
      timestamp: DateTime.parse(json['timestamp']),
      parentId: json['parent_id'],
      reactions: Map<String, int>.from(json['reactions'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'channel_id': channelId,
      'content': content,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_avatar_url': senderAvatarUrl,
      'timestamp': timestamp.toIso8601String(),
      'parent_id': parentId,
      'reactions': reactions,
    };
  }
}
