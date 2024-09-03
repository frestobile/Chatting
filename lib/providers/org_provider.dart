import 'package:flutter/material.dart';
import '../models/workspace_model.dart';
import '../services/api_service.dart';

class OrgProvider with ChangeNotifier {
  List<Workspace> _workspaces = [];
  Workspace? _selectedWorkspace;

  List<Workspace> get workspaces => _workspaces;
  Workspace? get selectedWorkspace => _selectedWorkspace;

  Future<void> fetchWorkspaces() async {
    _workspaces = await ApiService.fetchWorkspaces();
    notifyListeners();
  }

  void selectWorkspace(Workspace workspace) {
    _selectedWorkspace = workspace;
    notifyListeners();
  }
}
