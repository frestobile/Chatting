import './coworker_model.dart';

class Conversation {
  final String id;
  final String name;
  final List<Coworker> collaborators;
  final String description;
  final String organisation;
  final List<String> hasNotOpen;
  final bool isSelf;
  final bool isConversation;
  final bool isOnline;
  final String createdAt;
  final String updatedAt;
  final String avatar;
  final int unreadMessagesNumber;

  Conversation(
      {required this.id,
      required this.name,
      required this.collaborators,
      required this.description,
      required this.organisation,
      required this.hasNotOpen,
      required this.isSelf,
      required this.isConversation,
      required this.isOnline,
      required this.createdAt,
      required this.updatedAt,
      this.avatar = '',
      this.unreadMessagesNumber = 0});

  // Factory method to create a Channel object from JSON
  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
        id: json['_id'],
        name: json['name'],
        collaborators: List<Coworker>.from(json['collaborators']
            .map((collaborator) => Coworker.fromJson(collaborator))),
        description: json['description'],
        organisation: json['organisation'],
        hasNotOpen: List<String>.from(json['hasNotOpen']),
        isSelf: json['isSelf'],
        isConversation: json['isConversation'],
        isOnline: json['isOnline'],
        createdAt: json['createdAt'] as String,
        updatedAt: json['updatedAt'] as String,
        avatar: json['avatar'] as String? ?? '',
        unreadMessagesNumber: json['unreadMessagesNumber'] as int? ?? 0);
  }

  // Method to convert Channel object to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'collaborators':
          collaborators.map((collaborator) => collaborator.toJson()).toList(),
      'description': description,
      'organisation': organisation,
      'hasNotOpen': hasNotOpen,
      'isSelf': isSelf,
      'isConversation': isConversation,
      'isOnline': isOnline,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'avatar': avatar,
      'unreadMessagesNumber': unreadMessagesNumber
    };
  }
}
