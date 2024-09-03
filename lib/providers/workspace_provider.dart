import 'package:flutter/material.dart';
import '../models/channel_model.dart';
import '../models/coworker_model.dart';
import '../services/workspace_service.dart';

class WorkspaceProvider with ChangeNotifier {
  final WorkspaceService _workspaceService = WorkspaceService();
  List<Channel> _channels = [];
  List<Coworker> _coworkers = [];
  bool _isLoading = false;

  List<Channel> get channels => _channels;
  List<Coworker> get coworkers => _coworkers;
  bool get isLoading => _isLoading;

  Future<void> fetchWorkspaceDetails(String workspaceId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _channels = await _workspaceService.fetchChannels(workspaceId);
      _coworkers = await _workspaceService.fetchCoworkers(workspaceId);
    } catch (e) {
      print("Error fetching workspace details: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}