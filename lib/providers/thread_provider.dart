import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ainaglam/models/message_model.dart';
import 'package:ainaglam/models/threadmsg_model.dart';
import 'package:ainaglam/models/coworker_model.dart';
import 'package:ainaglam/services/thread_service.dart';

class ThreadProvider with ChangeNotifier {
  final ThreadService _threadService = ThreadService();
  late IO.Socket? _socket;

  List<ThreadMsg> _threadMessages = [];
  bool _isLoading = false;
  Message? _selectedMessage;

  String? _errorMessage;
  String? _currentMessageId;
  // Coworker? _user;

  List<ThreadMsg> get threadMessages => _threadMessages;
  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;
  String? get currentMessageId => _currentMessageId;
  // Coworker? get user => _user;

  // connect to Socket.IO server
  void connect() {
    _socket = IO.io(
        dotenv.env['API_PUBLIC_SOCKET'],
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build());

    _socket!.connect();

    _socket!.onConnect((_) {
      print('Connected to the socket server');
    });

    // Listen for messages from the server
    _socket!.on('thread-message', (data) {
      ThreadMsg receivedMessage = ThreadMsg.fromJson(data['newMessage']);
      _threadMessages.add(receivedMessage);
      notifyListeners(); // Notify UI about the new message
    });

    _socket!.on('message-updated', (data) {
      if (data['isThread'] == true) {
        ThreadMsg msg = ThreadMsg.fromJson(data['message']);
        int index = _threadMessages.indexWhere((item) => item.id == data['id']);
        _threadMessages[index] = msg;
      }
      notifyListeners();
    });

    _socket!.onDisconnect((_) {
      print('Disconnected from the socket server');
    });
  }

  Future<void> fetchThreadMessages(String messageId) async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _threadService.fetchThreadMessages(messageId);
      if (response['success'] == true) {
        List<dynamic> jsonMap = json.decode(response['data'])['data'];
        _threadMessages =
            jsonMap.map((msg) => ThreadMsg.fromJson(msg)).toList();
        // _user = response['user'];
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

  Future<void> deleteMessage(
      ThreadMsg message, Coworker user, String channelId) async {
    _socket?.emit('message-delete', {
      'channelId': channelId,
      'messageId': message.id,
      'userId': user.id,
      'isThread': true
    });
    _threadMessages.remove(message);
    notifyListeners();
  }

  Future<void> addEmojiReaction(
      ThreadMsg message, Message msg, String emoji, Coworker user) async {
    _selectedMessage = msg;
    _socket!.emit('reaction', {
      'emoji': emoji,
      'id': message.id,
      'userId': user.id,
      'isThread': true
    });
    notifyListeners();
  }

  void sendMessages(String threadId, Coworker user, Map<String, dynamic> msg) {
    _socket!.emit('thread-message',
        {'message': msg, 'messageId': threadId, 'userId': user.id});
    notifyListeners();
  }

  // Future<void> addEmojiReaction(String messageId, String emoji) async {

  //   notifyListeners();
  // }

  // void openThread(String parentMessageId) {
  //   _threadMessages =
  //       _messages.where((msg) => msg. == parentMessageId).toList();
  //   notifyListeners();
  // }

  // Future<void> replyToThread(String parentMessageId, String content) async {
  //   final newMessage =
  //       await _threadService.replyToThread(parentMessageId, content);
  //   _threadMessages.add(newMessage);
  //   notifyListeners();
  // }

  // @override
  // void dispose() {
  //   _channel.sink.close();
  //   super.dispose();
  // }
}
