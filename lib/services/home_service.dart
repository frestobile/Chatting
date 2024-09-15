import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ainaglam/providers/auth_provider.dart';
import '../models/user_model.dart';

class HomeService {
  final String _baseUrl = dotenv.env['API_BASE_URL'] ?? '';
  final AuthProvider _authProvider = AuthProvider();

  Future<Map<String, dynamic>> fetchWorkspaceData(String workspaceId) async {
    User? userData = await _authProvider.loadAuthData();
    final response = await http.get(
      Uri.parse('$_baseUrl/organisation/$workspaceId'),
      headers: {'Authorization': 'Bearer ${userData?.token}'},
    );
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

  Future<Map<String, dynamic>> fetchChannelData(String channelId) async {
    User? userData = await _authProvider.loadAuthData();
    final response = await http.get(
      Uri.parse('$_baseUrl/channel/$channelId'),
      headers: {'Authorization': 'Bearer ${userData?.token}'},
    );

    if (response.statusCode == 201) {
      return {'success': true, 'msg': '', 'data': response.body};
    } else {
      return {
        'success': false,
        'msg': 'Failed to load messages',
        'data': response.body
      };
    }
  }

  Future<Map<String, dynamic>> fetchConversationData(
      String conversationId) async {
    User? userData = await _authProvider.loadAuthData();
    final response = await http.get(
      Uri.parse('$_baseUrl/conversations/$conversationId'),
      headers: {'Authorization': 'Bearer ${userData?.token}'},
    );

    if (response.statusCode == 201) {
      return {'success': true, 'msg': '', 'data': response.body};
    } else {
      return {
        'success': false,
        'msg': 'Failed to load messages',
        'data': response.body
      };
    }
  }
}
