import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/message_model.dart';
import 'package:ainaglam/providers/auth_provider.dart';
import 'package:ainaglam/providers/home_provider.dart';
import 'package:ainaglam/models/user_model.dart';
import 'package:ainaglam/models/coworker_model.dart';
import 'package:ainaglam/models/threadmsg_model.dart';

class ThreadService {
  static final String _baseUrl = dotenv.env['API_BASE_URL'] ?? '';
  final AuthProvider _authProvider = AuthProvider();
  final HomeProvider _homeProvider = HomeProvider();

  Future<Map<String, dynamic>> fetchThreadMessages(String messageId) async {
    User? userData = await _authProvider.loadAuthData();
    Coworker? user = await _homeProvider.loadUserFromPrefs();
    final response = await http.get(
      Uri.parse('$_baseUrl/threads?message=$messageId'),
      headers: {'Authorization': 'Bearer ${userData?.token}'},
    );

    if (response.statusCode == 201) {
      return {'success': true, 'msg': '', 'data': response.body, 'user': user};
    } else {
      return {
        'success': false,
        'msg': 'Failed to fetch Messages',
        'data': response.body
      };
    }
  }

  static Future<Message> sendMessage(
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

  static Future<Message> replyToThread(
      String parentMessageId, String content) async {
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

  Future<Map<String, dynamic>> imageUploadByFile(File img) async {
    User? userData = await _authProvider.loadAuthData();

    final uri = Uri.parse('$_baseUrl/messages/image-upload');
    var request = http.MultipartRequest('POST', uri);

    Map<String, String> headers = {
      'Authorization':
          'Bearer ${userData!.token}', // Example header for authorization
      'Content-Type': 'multipart/form-data', // Set Content-Type
    };
    request.headers.addAll(headers);
    request.files.add(await http.MultipartFile.fromPath('image', img.path));
    final response = await request.send();

    String responseBody = await response.stream.bytesToString();
    var decodedJson = jsonDecode(responseBody);
    print("Parsed JSON: $decodedJson");
    if (response.statusCode == 200) {
      return {'success': true, 'msg': '', 'data': decodedJson};
    } else {
      return {
        'success': false,
        'msg': 'Failed to load messages',
        'data': decodedJson
      };
    }
  }

  Future<Map<String, dynamic>> imageUploadByByte(Uint8List img) async {
    User? userData = await _authProvider.loadAuthData();

    final uri = Uri.parse('$_baseUrl/messages/image-upload');
    var request = http.MultipartRequest('POST', uri);

    Map<String, String> headers = {
      'Authorization':
          'Bearer ${userData!.token}', // Example header for authorization
      'Content-Type': 'multipart/form-data', // Set Content-Type
    };
    request.headers.addAll(headers);
    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        img,
        filename: 'image.png',
        // contentType: MediaType('image', 'png'),
      ),
    );
    final response = await request.send();

    String responseBody = await response.stream.bytesToString();
    var decodedJson = jsonDecode(responseBody);
    print("Parsed JSON: $decodedJson");
    if (response.statusCode == 200) {
      return {'success': true, 'msg': '', 'data': decodedJson};
    } else {
      return {
        'success': false,
        'msg': 'Failed to load messages',
        'data': decodedJson
      };
    }
  }

  Future<Map<String, dynamic>> videoUploadByFile(File img) async {
    User? userData = await _authProvider.loadAuthData();

    final uri = Uri.parse('$_baseUrl/messages/file-upload');
    var request = http.MultipartRequest('POST', uri);

    Map<String, String> headers = {
      'Authorization':
          'Bearer ${userData!.token}', // Example header for authorization
      'Content-Type': 'multipart/form-data', // Set Content-Type
    };
    request.headers.addAll(headers);
    request.files.add(await http.MultipartFile.fromPath('file', img.path));
    final response = await request.send();

    String responseBody = await response.stream.bytesToString();
    var decodedJson = jsonDecode(responseBody);
    print("Parsed JSON: $decodedJson");
    if (response.statusCode == 200) {
      return {'success': true, 'msg': '', 'data': decodedJson};
    } else {
      return {
        'success': false,
        'msg': 'Failed to load messages',
        'data': decodedJson
      };
    }
  }

  Future<Map<String, dynamic>> videoUploadByByte(Uint8List img) async {
    User? userData = await _authProvider.loadAuthData();

    final uri = Uri.parse('$_baseUrl/messages/file-upload');
    var request = http.MultipartRequest('POST', uri);

    Map<String, String> headers = {
      'Authorization':
          'Bearer ${userData!.token}', // Example header for authorization
      'Content-Type': 'multipart/form-data', // Set Content-Type
    };
    request.headers.addAll(headers);
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        img,
        filename: 'video',
        // contentType: MediaType('image', 'png'),
      ),
    );
    final response = await request.send();

    String responseBody = await response.stream.bytesToString();
    var decodedJson = jsonDecode(responseBody);
    print("Parsed JSON: $decodedJson");
    if (response.statusCode == 200) {
      return {'success': true, 'msg': '', 'data': decodedJson};
    } else {
      return {
        'success': false,
        'msg': 'Failed to load messages',
        'data': decodedJson
      };
    }
  }
}
