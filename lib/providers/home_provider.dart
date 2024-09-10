import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/channel_model.dart';
import '../models/coworker_model.dart';
import '../services/home_service.dart';

class HomeProvider with ChangeNotifier {
  final HomeService _homeService = HomeService();
  List<Channel> _channels = [];
  List<Coworker> _coworkers = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isApiCalled = false;

  List<Channel> get channels => _channels;
  List<Coworker> get coworkers => _coworkers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isApiCalled => _isApiCalled;

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
        _coworkers = coworkerjsonMap
            .map((coworker) => Coworker.fromJson(coworker))
            .toList();
        _channels =
            channeljsonMap.map((channel) => Channel.fromJson(channel)).toList();
      } else {
        _errorMessage = response['msg'];
      }
    } catch (error) {
      _errorMessage = "An error occurred: $error";
    } finally {
      _isLoading = false;
      _isApiCalled = true;
      notifyListeners();
    }
  }
}
