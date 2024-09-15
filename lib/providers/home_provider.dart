import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/channel_model.dart';
import '../models/coworker_model.dart';
import '../models/conversation_model.dart';
import '../services/home_service.dart';

class HomeProvider with ChangeNotifier {
  final HomeService _homeService = HomeService();
  List<Channel> _channels = [];
  List<Coworker> _coworkers = [];
  List<Conversation> _conversations = [];
  bool _isLoading = false;
  String? _errorMessage;
  Coworker? _profileUser;
  // Channel? _channelData;
  // Conversation? _convData;

  List<Channel> get channels => _channels;
  List<Coworker> get coworkers => _coworkers;
  List<Conversation> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Coworker? get profileUser => _profileUser;
  // Channel? get channelData => _channelData;
  // Conversation? get convData => _convData;

  Future<void> fetchWorkspaceDetails(String workspaceId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _homeService.fetchWorkspaceData(workspaceId);
      if (response["success"]) {
        List<dynamic> coworkerjsonMap =
            json.decode(response['data'])['data']['coWorkers'];
        List<dynamic> channeljsonMap =
            json.decode(response['data'])['data']['channels'];
        List<dynamic> conversationjsonMap =
            json.decode(response['data'])['data']['conversations'];
        _coworkers = coworkerjsonMap
            .map((coworker) => Coworker.fromJson(coworker))
            .toList();
        _channels =
            channeljsonMap.map((channel) => Channel.fromJson(channel)).toList();
        _conversations = conversationjsonMap
            .map((conversation) => Conversation.fromJson(conversation))
            .toList();
        Map<String, dynamic> profileJson =
            json.decode(response['data'])['data']['profile'];
        _profileUser = Coworker.fromJson(profileJson);
        _saveUserToPrefs(_profileUser!);
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

  Future<void> _saveUserToPrefs(Coworker user) async {
    final prefs = await SharedPreferences.getInstance();
    String userJson = jsonEncode(user.toJson());
    await prefs.setString('profile_data', userJson);
  }

  Future<Coworker?> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    String? userJson = prefs.getString('profile_data');

    if (userJson != null) {
      Map<String, dynamic> userMap = jsonDecode(userJson);
      notifyListeners();
      return Coworker.fromJson(userMap);
    }
    return null;
  }
}
