import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ainaglam/providers/auth_provider.dart';
import '../models/user_model.dart';
import '../models/coworker_model.dart';

class HomeService {
  final String _baseUrl = dotenv.env['API_BASE_URL'] ?? '';
  final AuthProvider _authProvider = AuthProvider();

  Future<Map<String, dynamic>> fetchWorkspaceData(String workspaceId) async {
    User? userData = await _authProvider.loadUserFromPrefs();
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
