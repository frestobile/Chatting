import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/channel_model.dart';
import '../models/coworker_model.dart';

class HomeService {
  final String _baseUrl = dotenv.env['BASE_URL'] ?? '';

  Future<List<Channel>> fetchChannels(String workspaceId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/workspaces/$workspaceId/channels'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((channel) => Channel.fromJson(channel)).toList();
    } else {
      throw Exception('Failed to load channels');
    }
  }

  Future<List<Coworker>> fetchCoworkers(String workspaceId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/workspaces/$workspaceId/coworkers'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((friend) => Coworker.fromJson(friend)).toList();
    } else {
      throw Exception('Failed to load coworkers');
    }
  }
}
