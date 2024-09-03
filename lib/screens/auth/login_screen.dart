import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ainaglam/extentions/context.dart';
import 'package:ainaglam/extentions/responsive.dart';
import 'package:ainaglam/extentions/input_field.dart';
import 'package:ainaglam/extentions/labeled_text_button.dart';
import '../../providers/auth_provider.dart';
import 'sms_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isSignUp = false;

  void _toggleMode() {
    setState(() {
      _isSignUp = !_isSignUp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ConstrainedWidth.mobile(
        child: Form(
          key: _formKey,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child:
                  Consumer<AuthProvider>(builder: (context, authProvider, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    Text(
                      _isSignUp ? 'アカウントを作成' : 'ログイン',
                      style: context.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    InputField.email(
                      controller: _emailController,
                      label: 'メールアドレス',
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) {
                                return;
                              }
                              context.closeKeyboard();
                              await authProvider.login(
                                  _emailController.text.trim(), context);
                              if (authProvider.status == true) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SmsVerificationScreen(),
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text('SMSコードを送信する'),
                    ),
                    const SizedBox(height: 8),
                    LabeledTextButton(
                        label: _isSignUp ? 'すでに登録済みですか？' : '新しいアカウントを作成',
                        action: _isSignUp ? 'ログイン' : 'サインアップ',
                        onTap: _toggleMode),
                    const Spacer(),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
