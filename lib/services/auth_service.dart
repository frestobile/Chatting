import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final String _baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// Sends an SMS code to the user's email.
  Future<Map<String, dynamic>> sendSmsCode(String email) async {
    try {
      var url = Uri.parse('$_baseUrl/auth/signin');
      var response = await http.post(url, body: {'email': email});

      if (response.statusCode == 201) {
        return {'success': true, 'message': 'SMS code sent successfully.'};
      } else {
        return {
          'success': false,
          'message':
              jsonDecode(response.body)['error'] ?? 'Failed to send SMS code.'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: Unable to send SMS code.'
      };
    }
  }

  /// Verifies the SMS code provided by the user and returns user data if successful.
  Future<Map<String, dynamic>> verifySmsCode(String smsCode) async {
    try {
      var url = Uri.parse('$_baseUrl/auth/verify');
      var response =
          await http.post(url, body: {'loginVerificationCode': smsCode});

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'SMS code is Correct.',
          'data': response.body
        };
      } else if (response.statusCode == 401) {
        return {'success': false, 'message': 'Invalid SMS code.', 'data': null};
      } else {
        return {
          'success': false,
          'message': 'Failed to verify SMS code: ${response.body}',
          'data': null
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: Unable to verify SMS code.',
        'data': null
      };
    }
  }

  /// Refreshes the user's session if necessary (optional).
  Future<Map<String, dynamic>> refreshSession(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/refresh-session'),
        body: jsonEncode({'refresh_token': refreshToken}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to refresh session: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: Unable to refresh session.');
    }
  }
}
