import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:ainaglam/models/message_model.dart';
import 'package:ainaglam/services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  late Socket? _socket;

  // final String workspaceId;
  // final String channelId;
  // final WebSocketChannel _channel;

  List<Message> _messages = [];
  final List<Message> _threadMessages = [];
  bool _isLoading = false;
  bool _isApiCalled = false;
  String? _errorMessage;
  String? _currentMessageId;
  bool _isChannel = true;

  List<Message> get messages => _messages;
  List<Message> get threadMessages => _threadMessages;
  bool get isLoading => _isLoading;
  bool get isApiCalled => _isApiCalled;
  String? get errorMessage => _errorMessage;
  String? get currentMessageId => _currentMessageId;
  bool get isChannel => _isChannel;

  // connect to Socket.IO server
  void connect() {
    _socket = io(dotenv.env['API_BASE_URL']);

    _socket!.connect();

    _socket!.onConnect((_) {
      print('Connected to the socket server');
    });

    // Listen for messages from the server
    _socket!.on('message', (data) {
      _messages.add(data);
      notifyListeners(); // Notify UI about the new message
    });

    _socket!.onDisconnect((_) {
      print('Disconnected from the socket server');
    });
  }

  void _onMessageReceived(dynamic message) {
    final decodedMessage = jsonDecode(message);
    final newMessage = Message.fromJson(decodedMessage);
    _messages.add(newMessage);
    notifyListeners();
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
      } else {
        _errorMessage = response['msg'];
      }
    } catch (error) {
      _errorMessage = "An error occurred: $error";
    } finally {
      _isChannel = true;
      _isApiCalled = true;
      _isLoading = false;
      notifyListeners();
    }
    _isApiCalled = false;
  }

  Future<void> fetchConversationMessages(
      String workspaceId, String conversationlId) async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();
    try {
      final response =
          await _chatService.fetchConversationMessages(workspaceId, conversationlId);
      if (response['success'] == true) {
        List<dynamic> jsonMap = json.decode(response['data'])['data'];
        _messages = jsonMap.map((msg) => Message.fromJson(msg)).toList();
      } else {
        _errorMessage = response['msg'];
      }
    } catch (error) {
      _errorMessage = "An error occurred: $error";
    } finally {
      _isChannel = false;
      _isApiCalled = true;
      _isLoading = false;
      notifyListeners();
    }
    _isApiCalled = false;
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

  Future <void> addEmojiReaction(String messageId, String emoji) async {
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
