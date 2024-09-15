import './coworker_model.dart';
import './reaction_model.dart';

class ThreadMsg {
  final String id;
  final Coworker sender;
  final String content;
  final String message;
  final bool isBookmarked;
  final bool hasRead;
  final List<Reaction> reactions;
  final String createdAt;
  final String updatedAt;

  ThreadMsg({
    required this.id,
    required this.sender,
    required this.content,
    required this.message,
    required this.isBookmarked,
    required this.hasRead,
    required this.reactions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ThreadMsg.fromJson(Map<String, dynamic> json) {
    return ThreadMsg(
      id: json['_id'],
      sender: Coworker.fromJson(json['sender']),
      content: json['content'] ?? '',
      message: json['message'] ?? '',
      isBookmarked: json['isBookmarked'],
      hasRead: json['hasRead'] ?? false,
      reactions: List<Reaction>.from(
          json['reactions'].map((reaction) => Reaction.fromJson(reaction))),
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'sender': sender,
      'content': content,
      'message': message,
      'isBookmarked': isBookmarked,
      'hasRead': hasRead,
      'reactions': reactions.map((reaction) => reaction.toJson()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
