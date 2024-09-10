class Branch {
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
  final int unreadMessagesNumber;

  Branch(
      {required this.id,
      required this.name,
      required this.collaborators,
      required this.organisation,
      required this.hasNotOpen,
      required this.isChannel,
      required this.isPublic,
      required this.title,
      required this.createdAt,
      required this.updatedAt,
      this.unreadMessagesNumber = 0});

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
        id: json['_id'],
        name: json['name'],
        collaborators: List<String>.from(json['collaborators']),
        organisation: json['organisation'],
        hasNotOpen: List<String>.from(json['hasNotOpen']),
        isChannel: json['isChannel'],
        isPublic: json['isPublic'],
        title: json['title'] as String,
        createdAt: json['createdAt'] as String,
        updatedAt: json['updatedAt'] as String,
        unreadMessagesNumber: json['unreadMessagesNumber'] as int? ?? 0);
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
      'unreadMessagesNumber': unreadMessagesNumber
    };
  }
}
