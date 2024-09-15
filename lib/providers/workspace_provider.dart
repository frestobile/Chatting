import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/workspace_model.dart';
import '../services/workspace_service.dart';

class WorkspaceProvider with ChangeNotifier {
  final WorkspaceService _workspaceService = WorkspaceService();
  List<Workspace> _workspaces = [];
  Workspace? _selectedWorkspace;
  bool _isLoading = false;
  String? _errorMessage;

  List<Workspace> get workspaces => _workspaces;
  Workspace? get selectedWorkspace => _selectedWorkspace;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchWorkspaces(String token) async {
    _isLoading = true; // Start loading
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await _workspaceService.fetchWorkspaces(token);
      if (response["success"]) {
        List<dynamic> jsonMap = json.decode(response['data'])['data'];

        _workspaces = jsonMap.map((org) => Workspace.fromJson(org)).toList();
      } else {
        _errorMessage = "Failed to load data.";
      }
    } catch (error) {
      _errorMessage = "An error occurred: $error";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
