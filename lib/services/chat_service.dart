import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ainaglam/providers/auth_provider.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';

class ChatService {
  final String _baseUrl = dotenv.env['API_BASE_URL'] ?? '';
  final AuthProvider _authProvider = AuthProvider();

  Future<Map<String, dynamic>> fetchConversationData(
      String workspaceId, String conversationId) async {
    User? userData = await _authProvider.loadUserFromPrefs();
    final response = await http.get(
      Uri.parse(
          '$_baseUrl/workspaces/$workspaceId/channels/$conversationId/messages'),
      headers: {'Authorization': 'Bearer ${userData?.token}'},
    );

    if (response.statusCode == 200) {
      return {'success': true, 'msg': '', 'data': response.body};
    } else {
      return {
        'success': true,
        'msg': 'Failed to load messages',
        'data': response.body
      };
    }
  }

  Future<Map<String, dynamic>> fetchConversationMessages(
      String workspaceId, String conversationId) async {
    User? userData = await _authProvider.loadUserFromPrefs();
    final response = await http.get(
      Uri.parse(
          '$_baseUrl/workspaces/$workspaceId/channels/$conversationId/messages'),
      headers: {'Authorization': 'Bearer ${userData?.token}'},
    );

    if (response.statusCode == 200) {
      return {'success': true, 'msg': '', 'data': response.body};
    } else {
      return {
        'success': true,
        'msg': 'Failed to load messages',
        'data': response.body
      };
    }
  }

  Future<Map<String, dynamic>> fetchChannelData(
      String workspaceId, String conversationId) async {
    User? userData = await _authProvider.loadUserFromPrefs();
    final response = await http.get(
      Uri.parse(
          '$_baseUrl/workspaces/$workspaceId/channels/$conversationId/messages'),
      headers: {'Authorization': 'Bearer ${userData?.token}'},
    );

    if (response.statusCode == 200) {
      return {'success': true, 'msg': '', 'data': response.body};
    } else {
      return {
        'success': true,
        'msg': 'Failed to load messages',
        'data': response.body
      };
    }
  }

  Future<Map<String, dynamic>> fetchChannelMessages(
      String workspaceId, String channelId) async {
    User? userData = await _authProvider.loadUserFromPrefs();
    final response = await http.get(
      Uri.parse('$_baseUrl/organisation/$workspaceId'),
      headers: {'Authorization': 'Bearer ${userData?.token}'},
    );
    print(json.decode(response.body)['data']['conversations']);
    if (response.statusCode == 201) {
      return {"success": true, "msg": "Fetched data", "data": response.body};
    } else {
      return {
        "success": false,
        "msg": "Failed to fetch data with status: ${response.statusCode}",
        "data": null
      };
    }
  }

  Future<Message> sendMessage(
      String workspaceId, String channelId, String content) async {
    final response = await http.post(
      Uri.parse(
          '$_baseUrl/workspaces/$workspaceId/channels/$channelId/messages'),
      body: jsonEncode({'content': content}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      return Message.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to send message');
    }
  }

  Future<Message> replyToThread(String parentMessageId, String content) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/messages/$parentMessageId/replies'),
      body: jsonEncode({'content': content}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      return Message.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to reply to thread');
    }
  }

  // Add more API methods as needed
}
