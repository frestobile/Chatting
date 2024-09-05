import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
      body: ConstrainedWidth.mobile(
        child: Form(
          key: _formKey,
          child: Container(
            width: 450,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Color.fromARGB(255, 226, 228, 231)),
              color: const Color.fromARGB(255, 243, 244, 246),
            ),
            child: Stack(
              children: [
                // Background SVG Image mainAxisSize: MainAxisSize.min,
                // Positioned.fill(
                //   child: SvgPicture.asset('assets/images/logo-mark.svg',
                //       fit: BoxFit.scaleDown),
                // ),
                /* Top-right corner image */
                Positioned(
                  top: 0,
                  right: 0,
                  child: SvgPicture.asset(
                    'assets/images/logo-mark.svg',
                    fit: BoxFit.scaleDown,
                    height: 100,
                    width: 100,
                  ),
                ),
                /* Foreground content (TextFields, Buttons, etc.) */
                Padding(
                  padding: const EdgeInsets.only(
                    top: 70.0,
                    bottom: 70.0,
                    left: 30.0,
                    right: 30.0,
                  ),
                  child: Consumer<AuthProvider>(
                      builder: (context, authProvider, _) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // const Spacer(),  // full screen background set
                        Align(
                          alignment: Alignment.topLeft, // center the text
                          child: Text(
                            _isSignUp ? 'アカウントを作成' : 'ログイン',
                            style: context.textTheme.headlineLarge,
                          ),
                        ),
                        const SizedBox(height: 16),
                        InputField.email(
                          controller: _emailController,
                          label: _isSignUp ? 'メールアドレス（仕事用アドレス推奨）' : 'メールアドレス',
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
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SmsVerificationScreen(
                                                emailString: _emailController
                                                    .text
                                                    .trim()),
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              backgroundColor:
                                  Color.fromARGB(255, 55, 110, 188)),
                          child: Text(
                            _isSignUp ? '登録する' : 'ログインする',
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        LabeledTextButton(
                          label: _isSignUp ? '' : '',
                          action: _isSignUp ? 'すでに登録済みですか？' : '新しいアカウントを作成',
                          onTap: _toggleMode,
                          style: context.textTheme.bodyMedium!.copyWith(
                            color: Colors.red,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.red,
                          ),
                        ),
                        // const Spacer(),    //full screen background set
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
