import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ainaglam/utils/dialog.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  User? _user;
  bool? _status;

  bool get isLoading => _isLoading;
  User? get user => _user;
  bool? get status => _status;

  AuthProvider() {
    _loadUserFromPrefs(); // Load user session when the provider is initialized
  }

  Future<void> login(String email, BuildContext context) async {
    _status = false;
    _isLoading = true;
    notifyListeners();
    var response = await _authService.sendSmsCode(email);
    _isLoading = false;

    if (response['success'] == true) {
      _status = response['success'];
    } else {
      showStatusDialog(context, response['message'], false);
    }

    notifyListeners();
  }

  Future<void> verifySmsCode(String smsCode, BuildContext context) async {
    _status = false;
    _isLoading = true;
    notifyListeners();

    var response = await _authService.verifySmsCode(smsCode);
    _isLoading = false;
    if (response['success']) {
      // _user = User.fromJson(response['data']);
      // await _saveUserToPrefs(_user!);
      _status = response['success'];
      showStatusDialog(context, response['message'], true);
    } else {
      showStatusDialog(context, response['message'], false);
    }
    await _saveUserToPrefs(_user!); // Save user session locally

    notifyListeners();
  }

  void logout() async {
    _user = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user'); // Clear user session
  }

  Future<void> _saveUserToPrefs(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', user.toJson() as String);
  }

  Future<void> _loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      _user = User.fromJson(userJson as Map<String, dynamic>);
      notifyListeners();
    }
  }
}
