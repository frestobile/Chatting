class Channel {
  final String id;
  final String name;
  final List<String> collaborators;
  final String organisation;
  final List<String> hasNotOpen;
  final bool isChannel;
  final bool isPublic;
  final String title;
  final String createdAt;
  final String updatedAt;

  Channel({
    required this.id,
    required this.name,
    required this.collaborators,
    required this.organisation,
    required this.hasNotOpen,
    required this.isChannel,
    required this.isPublic,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory method to create a Channel object from JSON
  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['_id'],
      name: json['name'],
      collaborators: List<String>.from(json['collaborators']),
      organisation: json['organisation'],
      hasNotOpen: List<String>.from(json['hasNotOpen']),
      isChannel: json['isChannel'],
      isPublic: json['isPublic'],
      title: json['title'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  // Method to convert Channel object to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'collaborators': collaborators,
      'organisation': organisation,
      'hasNotOpen': hasNotOpen,
      'isChannel': isChannel,
      'isPublic': isPublic,
      'title': title,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
