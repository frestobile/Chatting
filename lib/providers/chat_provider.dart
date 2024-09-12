import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:ainaglam/models/message_model.dart';
import 'package:ainaglam/services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  // final String workspaceId;
  // final String channelId;
  // final WebSocketChannel _channel;

  List<Message> _messages = [];
  List<Message> _threadMessages = [];
  bool _isLoading = false;
  bool _isApiCalled = false;
  String? _errorMessage;
  String? _currentMessageId;

  // ChatProvider({required this.workspaceId, required this.channelId})
  //     : _channel = WebSocketChannel.connect(
  //           Uri.parse('wss://yourserver.com/ws/$workspaceId/$channelId')) {
  //   _channel.stream.listen(_onMessageReceived);
  // }

  List<Message> get messages => _messages;
  List<Message> get threadMessages => _threadMessages;
  bool get isLoading => _isLoading;
  bool get isApiCalled => _isApiCalled;
  String? get errorMessage => _errorMessage;
  String? get currentMessageId => _currentMessageId;

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
      _isApiCalled = true;
      _isLoading = false;
      notifyListeners();
    }
    _isApiCalled = false;
  }

  Future<void> fetchConversationMessages(
      String workspaceId, String channelId) async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();
    try {
      final response =
          await _chatService.fetchConversationMessages(workspaceId, channelId);
      if (response['success'] == true) {
        List<dynamic> jsonMap = json.decode(response['data'])['data'];
        _messages = jsonMap.map((msg) => Message.fromJson(msg)).toList();
      } else {
        _errorMessage = response['msg'];
      }
    } catch (error) {
      _errorMessage = "An error occurred: $error";
    } finally {
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

  void addEmojiReaction(String messageId, String emoji) {
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
