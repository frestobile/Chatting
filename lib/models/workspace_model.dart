import 'package:ainaglam/models/branch_model.dart';

class Workspace {
  final String id;
  final String owner;
  final List<String> coWorkers;
  final String createdAt;
  final String updatedAt;
  final String name;
  final String joinLink;
  final String url;
  final List<Branch> channels;

  Workspace({
    required this.id,
    required this.owner,
    required this.coWorkers,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    required this.joinLink,
    required this.url,
    required this.channels,
  });

  // Factory method to create a Workspace object from JSON
  factory Workspace.fromJson(Map<String, dynamic> json) {
    return Workspace(
      id: json['_id'],
      owner: json['owner'],
      coWorkers: List<String>.from(json['coWorkers']),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      name: json['name'],
      joinLink: json['joinLink'],
      url: json['url'],
      channels: List<Branch>.from(
          json['channels'].map((channel) => Branch.fromJson(channel))),
    );
  }

  // Method to convert Workspace object to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'owner': owner,
      'coWorkers': coWorkers,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'name': name,
      'joinLink': joinLink,
      'url': url,
      'channels': channels.map((channel) => channel.toJson()).toList(),
    };
  }

  static List<Workspace> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => Workspace.fromJson(json)).toList();
  }
}
