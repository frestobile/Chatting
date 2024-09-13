import 'package:flutter/material.dart';
import 'package:ainaglam/screens/auth/login_screen.dart';
import 'package:ainaglam/screens/home/workspace_screen.dart';
import 'package:ainaglam/models/user_model.dart';
import 'package:ainaglam/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthProvider _authProvider = AuthProvider();
  @override
  void initState() {
    super.initState();
    navigateToNextScreen();
  }

  Future<void> navigateToNextScreen() async {
    await Future.delayed(
        const Duration(seconds: 2)); // Display splash for 2 seconds
    User? userData = await _authProvider.loadAuthData();
    if (userData != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => WorkspaceScreen(tokenString: userData.token)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset('assets/images/splash.png',
            width: 200, height: 200), // Centered image
      ),
    );
  }
}
