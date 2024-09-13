import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:ainaglam/models/coworker_model.dart';
import 'package:ainaglam/models/message_model.dart';
import 'package:ainaglam/services/chat_service.dart';
import 'package:ainaglam/models/channel_model.dart';
import 'package:ainaglam/models/conversation_model.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  late IO.Socket _socket;

  List<Message> _messages = [];
  final List<Message> _threadMessages = [];
  bool _isLoading = false;

  String? _errorMessage;
  String? _currentMessageId;
  Coworker? _user;

  List<Message> get messages => _messages;
  List<Message> get threadMessages => _threadMessages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get currentMessageId => _currentMessageId;
  Coworker? get user => _user;

  // connect to Socket.IO server
  void connect() {
    _socket = IO.io(dotenv.env['API_BASE_URL'], IO.OptionBuilder());

    _socket.connect();

    _socket.onConnect((_) {
      print('Connected to the socket server');
    });

    // Listen for messages from the server
    _socket.on('message', (data) {
      _messages.add(data);
      notifyListeners(); // Notify UI about the new message
    });

    _socket.onDisconnect((_) {
      print('Disconnected from the socket server');
    });
  }

  Future<void> fetchChannelMessages(
      String workspaceId, String channelId) async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();
    try {
      final response =
          await _chatService.fetchChannelMessages(workspaceId, channelId);
      if (response['success'] == true) {
        List<dynamic> jsonMap = json.decode(response['data'])['data'];

        _messages = jsonMap.map((msg) => Message.fromJson(msg)).toList();
        _user = response['user'];
      } else {
        _errorMessage = response['msg'];
      }
    } catch (error) {
      _errorMessage = "An error occurred: $error";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchConversationMessages(
      String workspaceId, String conversationlId) async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _chatService.fetchConversationMessages(
          workspaceId, conversationlId);
      if (response['success'] == true) {
        List<dynamic> jsonMap = json.decode(response['data'])['data'];
        _messages = jsonMap.map((msg) => Message.fromJson(msg)).toList();
        if (_messages.isEmpty) {
          _errorMessage = "There are no Chat history";
        }
        _user = response['user'];
      } else {
        _errorMessage = response['msg'];
      }
    } catch (error) {
      _errorMessage = "An error occurred: $error";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCurrentMessageId(String? id) {
    _currentMessageId = id;
    notifyListeners();
  }

  Future<void> deleteMessage(Message message) async {
    notifyListeners();
  }

  Future<void> sendMessage(
      String workspaceId, String channelId, String content) async {
    final newMessage =
        await _chatService.sendMessage(workspaceId, channelId, content);
    _messages.add(newMessage);
    notifyListeners();
  }

  // void sendMessages(String content) {
  //   final message = jsonEncode({
  //     'type': 'message',
  //     'workspace_id': workspaceId,
  //     'channel_id': channelId,
  //     'content': content,
  //     'sender_id': 'currentUserId', // Replace with actual user ID
  //     'timestamp': DateTime.now().toIso8601String(),
  //   });
  //   _channel.sink.add(message);
  // }

  Future<void> addEmojiReaction(String messageId, String emoji) async {
    // Implement emoji reaction logic
    notifyListeners();
  }

  // // void openThread(String parentMessageId) {
  // //   _threadMessages =
  // //       _messages.where((msg) => msg. == parentMessageId).toList();
  // //   notifyListeners();
  // // }

  Future<void> replyToThread(String parentMessageId, String content) async {
    final newMessage =
        await _chatService.replyToThread(parentMessageId, content);
    _threadMessages.add(newMessage);
    notifyListeners();
  }

  // @override
  // void dispose() {
  //   _channel.sink.close();
  //   super.dispose();
  // }
}
