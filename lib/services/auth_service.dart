import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final String _baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// Sends an SMS code to the user's email.
  Future<Map<String, dynamic>> sendSmsCode(String email) async {
    try {
      // final response = await http.post(
      //   Uri.parse('$_baseUrl/auth/sign'),

      //   body: jsonEncode(<String, String>{'email': email}),
      //   headers: <String, String>{
      //     'Content-Type': 'application/json; charset=UTF-8'
      //   },
      // );
      var url = Uri.parse('$_baseUrl/auth/sign');
      var response =
          await http.post(url, body: {'email': 'js8427773@gmail.com'});

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'SMS code sent successfully.'};
      } else {
        return {
          'success': true,
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
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/verify'),
        body: jsonEncode({'code': smsCode}),
        headers: {'Content-Type': 'application/json'},
      );

      // if (response.statusCode == 200) {
      //   return {
      //     'success': true,
      //     'message': 'SMS code sent successfully.',
      //     'data': jsonDecode(response.body)
      //   };
      // } else if (response.statusCode == 401) {
      //   return {'success': true, 'message': 'Invalid SMS code.', 'data': null};
      // } else {
      //   return {
      //     'success': true,
      //     'message': 'Failed to verify SMS code: ${response.body}',
      //     'data': null
      //   };
      // }
      return {
        'success': true,
        'message': 'SMS code sent successfully.',
        'data': jsonDecode(response.body)
      };
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
