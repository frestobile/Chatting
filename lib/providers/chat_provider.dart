import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/message_model.dart';
import '../services/api_service.dart';

class ChatProvider with ChangeNotifier {
  final String workspaceId;
  final String channelId;
  final WebSocketChannel _channel;

  List<Message> _messages = [];
  List<Message> _threadMessages = [];
  bool _isLoading = false;

  ChatProvider({required this.workspaceId, required this.channelId})
      : _channel = WebSocketChannel.connect(
            Uri.parse('wss://yourserver.com/ws/$workspaceId/$channelId')) {
    _channel.stream.listen(_onMessageReceived);
  }

  List<Message> get messages => _messages;
  List<Message> get threadMessages => _threadMessages;
  bool get isLoading => _isLoading;

  void _onMessageReceived(dynamic message) {
    final decodedMessage = jsonDecode(message);
    final newMessage = Message.fromJson(decodedMessage);
    _messages.add(newMessage);
    notifyListeners();
  }

  Future<void> fetchMessages(String workspaceId, String channelId) async {
    _isLoading = true;
    notifyListeners();
    _messages = await ApiService.fetchMessages(workspaceId, channelId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendMessage(
      String workspaceId, String channelId, String content) async {
    final newMessage =
        await ApiService.sendMessage(workspaceId, channelId, content);
    _messages.add(newMessage);
    notifyListeners();
  }

  void sendMessages(String content) {
    final message = jsonEncode({
      'type': 'message',
      'workspace_id': workspaceId,
      'channel_id': channelId,
      'content': content,
      'sender_id': 'currentUserId', // Replace with actual user ID
      'timestamp': DateTime.now().toIso8601String(),
    });
    _channel.sink.add(message);
  }

  void addEmojiReaction(String messageId, String emoji) {
    // Implement emoji reaction logic
    notifyListeners();
  }

  // void openThread(String parentMessageId) {
  //   _threadMessages =
  //       _messages.where((msg) => msg. == parentMessageId).toList();
  //   notifyListeners();
  // }

  Future<void> replyToThread(String parentMessageId, String content) async {
    final newMessage = await ApiService.replyToThread(parentMessageId, content);
    _threadMessages.add(newMessage);
    notifyListeners();
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }
}
