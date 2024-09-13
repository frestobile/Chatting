import './coworker_model.dart';

class Reaction {
  final String id;
  final String emoji;
  final List<Coworker> reactedToBy;

  Reaction({required this.id, required this.emoji, required this.reactedToBy});

  // Factory method to create a Channel object from JSON
  factory Reaction.fromJson(Map<String, dynamic> json) {
    return Reaction(
      id: json['_id'],
      emoji: json['emoji'],
      reactedToBy: List<Coworker>.from(
          json['reactedToBy'].map((react) => Coworker.fromJson(react))),
    );
  }

  // Method to convert Channel object to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': emoji,
      'reactedToBy': reactedToBy.map((react) => react.toJson()).toList()
    };
  }
}
