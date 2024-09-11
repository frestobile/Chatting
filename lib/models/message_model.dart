import './coworker_model.dart';
import './reaction_model.dart';

class Message {
  final String id;
  final Coworker sender;
  final String content;
  final String organisation;
  final String conversation;
  final String channel;
  final List<String> collaborators;
  final List<Coworker> threadReplies;
  final bool isBookmarked;
  final bool isSelf;
  final bool hasRead;
  final String type;
  final List<Coworker> unreadmember;
  final List<Reaction> reactions;
  final String createdAt;
  final String updatedAt;
  final String threadLastReplyDate;
  final int threadRepliesCount;

  Message(
      {required this.id,
      required this.sender,
      required this.content,
      required this.organisation,
      this.conversation = '',
      this.channel = '',
      required this.collaborators,
      required this.threadReplies,
      required this.isBookmarked,
      required this.isSelf,
      required this.hasRead,
      this.type = '',
      required this.unreadmember,
      required this.reactions,
      required this.createdAt,
      required this.updatedAt,
      this.threadLastReplyDate = '',
      this.threadRepliesCount = 0});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
        id: json['id'],
        sender: json['sender'],
        content: json['content'],
        organisation: json['organisation'],
        channel: json['channel'] as String? ?? '',
        conversation: json['conversation'] as String? ?? '',
        collaborators: json['collaborators'],
        threadReplies: json['threadReplies'],
        isBookmarked: json['isBookmarked'],
        isSelf: json['isSelf'],
        hasRead: json['hasRead'],
        type: json['type'] as String? ?? '',
        unreadmember: json['unreadmember'],
        reactions: json['reactions'],
        createdAt: json['createdAt'],
        updatedAt: json['updatedAt'],
        threadLastReplyDate: json['threadLastReplyDate'] as String? ?? '',
        threadRepliesCount: json['threadRepliesCount'] as int? ?? 0);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender,
      'content': content,
      'organisation': organisation,
      'channel': channel,
      'conversation': conversation,
      'collaborators': collaborators,
      'threadReplies': threadReplies,
      'isBookmarked': isBookmarked,
      'isSelf': isSelf,
      'hasRead': hasRead,
      'type': type,
      'unreadmember': unreadmember,
      'reactions': reactions,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'threadRepliesCount': threadRepliesCount,
      'threadLastReplyDate': threadLastReplyDate
    };
  }
}
