import './coworker_model.dart';
import './reaction_model.dart';

class Message {
  final String id;
  final Coworker? sender;
  final String content;
  final String organisation;
  final String channel;
  final String conversation;
  final List<String> collaborators;
  final List<Coworker> threadReplies;
  final bool isBookmarked;
  final bool isSelf;
  final bool hasRead;
  final String? type;
  final List<String> unreadmember;
  final List<Reaction> reactions;
  final String createdAt;
  final String updatedAt;
  final String? threadLastReplyDate;
  final int? threadRepliesCount;

  Message(
      {required this.id,
      this.sender,
      required this.content,
      required this.organisation,
      this.channel = '',
      this.conversation = '',
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
        id: json['_id'],
        sender:
            json['sender'] != null ? Coworker.fromJson(json['sender']) : null,
        content: json['content'] ?? '',
        organisation: json['organisation'] ?? '',
        channel: json['channel'] ?? '',
        conversation: json['conversation'] ?? '',
        collaborators: List<String>.from(json['collaborators']),
        threadReplies: List<Coworker>.from(
            json['threadReplies'].map((replyer) => Coworker.fromJson(replyer))),
        isBookmarked: json['isBookmarked'],
        isSelf: json['isSelf'] ?? false,
        hasRead: json['hasRead'] ?? false,
        type: json['type'] ?? '',
        unreadmember: List<String>.from(json['unreadmember']),
        reactions: List<Reaction>.from(
            json['reactions'].map((reaction) => Reaction.fromJson(reaction))),
        createdAt: json['createdAt'] ?? '',
        updatedAt: json['updatedAt'] ?? '',
        threadLastReplyDate: json['threadLastReplyDate'] as String? ?? '',
        threadRepliesCount: json['threadRepliesCount'] as int? ?? 0);
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'sender': sender,
      'content': content,
      'organisation': organisation,
      'channel': channel,
      'conversation': conversation,
      'collaborators': collaborators,
      'threadReplies':
          threadReplies.map((threadReply) => threadReply.toJson()).toList(),
      'isBookmarked': isBookmarked,
      'isSelf': isSelf,
      'hasRead': hasRead,
      'type': type,
      'unreadmember': unreadmember,
      'reactions': reactions.map((reaction) => reaction.toJson()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'threadRepliesCount': threadRepliesCount,
      'threadLastReplyDate': threadLastReplyDate
    };
  }
}
