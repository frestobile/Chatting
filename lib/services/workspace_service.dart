import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WorkspaceService {
  final String _baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  Future<Map<String, dynamic>> fetchWorkspaces(String token) async {
    var url = Uri.parse('$_baseUrl/organisation/workspaces');
    var response =
        await http.get(url, headers: {'Authorization': 'Bearer $token'});

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
}
