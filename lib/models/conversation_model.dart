import './coworker_model.dart';

class Conversation {
  final String id;
  final String name;
  final List<Coworker> collaborators;
  final String description;
  final bool isSelf;
  final bool isConversation;
  final String organisation;
  final bool isOnline;
  final List<String> hasNotOpen;
  final String createdAt;
  final String updatedAt;
  final String createdBy;
  final int unreadMessagesNumber;

  Conversation(
      {required this.id,
      required this.name,
      required this.collaborators,
      required this.description,
      required this.isSelf,
      required this.isConversation,
      required this.organisation,
      required this.isOnline,
      required this.hasNotOpen,
      required this.createdAt,
      required this.updatedAt,
      required this.createdBy,
      this.unreadMessagesNumber = 0});

  // Factory method to create a Channel object from JSON
  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
        id: json['_id'],
        name: json['name'],
        collaborators: List<Coworker>.from(json['collaborators']
            .map((collaborator) => Coworker.fromJson(collaborator))),
        description: json['description'],
        isSelf: json['isSelf'],
        isConversation: json['isConversation'],
        organisation: json['organisation'],
        isOnline: json['isOnline'],
        hasNotOpen: List<String>.from(json['hasNotOpen']),
        createdAt: json['createdAt'] as String,
        updatedAt: json['updatedAt'] as String,
        createdBy: json['createdBy'] as String,
        unreadMessagesNumber: json['unreadMessagesNumber']);
  }

  // Method to convert Channel object to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'collaborators':
          collaborators.map((collaborator) => collaborator.toJson()).toList(),
      'description': description,
      'isSelf': isSelf,
      'isConversation': isConversation,
      'organisation': organisation,
      'isOnline': isOnline,
      'hasNotOpen': hasNotOpen,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'createdBy': createdBy,
      'unreadMessagesNumber': unreadMessagesNumber
    };
  }
}
