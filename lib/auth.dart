// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;

  Future<void> _authenticate(String url) async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse(url), // Replace with your API endpoint
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': _emailController.text,
        'password': _passwordController.text,
      }),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (_) =>
                const MainScreen()), // Navigate to MainScreen after login
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Authentication failed. Please try again.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Okay'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text(_isLogin ? 'Login' : 'Register')),
      body: Center(
        // Center the content on the screen
        child: SingleChildScrollView(
          // Make content scrollable if needed
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center the column content
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  _isLogin ? 'Login' : 'Register',
                  style: const TextStyle(
                    fontSize: 24.0, // Set the desired font size
                    fontWeight: FontWeight.bold, // Optional: Set font weight
                    color: Colors.black, // Optional: Set text color
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(), // Add border to text field
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(), // Add border to text field
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () {
                          _authenticate(_isLogin
                              ? 'https://ainaglam.com/api/login'
                              : 'https://ainaglam.com/api/register'); // Replace with your API
                        },
                        child: Text(_isLogin ? 'Login' : 'Register'),
                      ),
                const SizedBox(height: 30),
                TextButton(
                  onPressed: _toggleMode,
                  child: Text(_isLogin
                      ? 'Create an account'
                      : 'Already have an account?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
