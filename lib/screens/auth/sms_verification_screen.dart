import 'package:ainaglam/screens/chat/workspace_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ainaglam/extentions/responsive.dart';
import 'package:ainaglam/extentions/context.dart';
import '../../providers/auth_provider.dart';

class SmsVerificationScreen extends StatelessWidget {
  // final TextEditingController _smsCodeController = TextEditingController();
  final List<TextEditingController> _smsCodeController =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  final String emailString;

  SmsVerificationScreen({super.key, required this.emailString});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConstrainedWidth.mobile(
        child: Container(
          width: 500,
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
                child:
                    Consumer<AuthProvider>(builder: (context, authProvider, _) {
                  return Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '認証コードを送信しました',
                        style: context.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 48, 48, 48),
                          ),
                          children: <TextSpan>[
                            const TextSpan(text: '6 文字のコードを '),
                            TextSpan(
                              text: emailString,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: ' に送信しました。24時間以内に入力してください。'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: 45,
                            child: TextField(
                              controller: _smsCodeController[index],
                              focusNode: _focusNodes[index],
                              maxLength: 1,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.text,
                              style: const TextStyle(fontSize: 22),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                counterText:
                                    '', // Removes the '1/1' under each box
                              ),
                              onChanged: (value) {
                                print(value);
                                if (value.length == 1 &&
                                    index < 5 &&
                                    value != " ") {
                                  _focusNodes[index + 1].requestFocus();
                                } else if (value.length == 6) {
                                  // Handle paste event
                                  for (int i = 0; i < 6; i++) {
                                    _smsCodeController[i].text = value[i];
                                  }
                                  _focusNodes[5].unfocus();
                                  authProvider.isLoading
                                      ? null
                                      : () async {
                                          String smsCode = _smsCodeController
                                              .map((controller) =>
                                                  controller.text)
                                              .join();
                                          if (smsCode == "" ||
                                              smsCode.length < 6) {
                                            return;
                                          }

                                          context.closeKeyboard();
                                          await authProvider.verifySmsCode(
                                              smsCode, context);
                                          if (authProvider.status == true) {
                                            Navigator.of(context)
                                                .pushReplacement(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const WorkspaceScreen(),
                                              ),
                                            );
                                          }
                                        }; // Remove focus after complete paste
                                }
                                if (value.isEmpty && index > 0) {
                                  _focusNodes[index - 1].requestFocus();
                                }
                                if (_smsCodeController.every((controller) =>
                                    controller.text.isNotEmpty)) {
                                  authProvider.isLoading
                                      ? null
                                      : () async {
                                          String smsCode = _smsCodeController
                                              .map((controller) =>
                                                  controller.text)
                                              .join();
                                          if (smsCode == "" ||
                                              smsCode.length < 6) {
                                            return;
                                          }

                                          context.closeKeyboard();
                                          await authProvider.verifySmsCode(
                                              smsCode, context);
                                          if (authProvider.status == true) {
                                            Navigator.of(context)
                                                .pushReplacement(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const WorkspaceScreen(),
                                              ),
                                            );
                                          }
                                        };
                                }
                              },
                              onSubmitted: (_) {
                                if (index == 5) {
                                  _focusNodes[index].unfocus();
                                  authProvider.isLoading
                                      ? null
                                      : () async {
                                          String smsCode = _smsCodeController
                                              .map((controller) =>
                                                  controller.text)
                                              .join();
                                          if (smsCode == "" ||
                                              smsCode.length < 6) {
                                            return;
                                          }
                                          context.closeKeyboard();
                                          await authProvider.verifySmsCode(
                                              smsCode, context);
                                          if (authProvider.status == true) {
                                            Navigator.of(context)
                                                .pushReplacement(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const WorkspaceScreen(),
                                              ),
                                            );
                                          }
                                        };
                                }
                              },
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'コードが見つからない場合は、迷惑フォルダをご確認ください。',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: ElevatedButton(
                          onPressed: authProvider.isLoading
                              ? null
                              : () async {
                                  String smsCode = _smsCodeController
                                      .map((controller) => controller.text)
                                      .join();
                                  if (smsCode == "" || smsCode.length < 6) {
                                    return;
                                  }
                                  print(smsCode);
                                  context.closeKeyboard();
                                  await authProvider.verifySmsCode(
                                      smsCode, context);
                                  if (authProvider.status == true) {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const WorkspaceScreen(),
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                          child: const Text('確認'),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(),
  //     backgroundColor: const Color.fromARGB(255, 255, 255, 255),
  //     body: Padding(
  //       padding: const EdgeInsets.all(24.0),
  //       child: Consumer<AuthProvider>(builder: (context, authProvider, _) {
  //         return Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               '認証コードを送信しました',
  //               style: context.textTheme.titleLarge,
  //             ),
  //             const SizedBox(height: 16),
  //             RichText(
  //               text: TextSpan(
  //                 style: const TextStyle(
  //                   fontSize: 16,
  //                   color: Color.fromARGB(255, 48, 48, 48),
  //                 ),
  //                 children: <TextSpan>[
  //                   const TextSpan(text: '6 文字のコードを '),
  //                   TextSpan(
  //                     text: emailString,
  //                     style: const TextStyle(
  //                       color: Colors.redAccent,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                   const TextSpan(text: ' に送信しました。24時間以内に入力してください。'),
  //                 ],
  //               ),
  //             ),
  //             const SizedBox(height: 32),
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: List.generate(6, (index) {
  //                 return SizedBox(
  //                   width: 45,
  //                   child: TextField(
  //                     controller: _smsCodeController[index],
  //                     focusNode: _focusNodes[index],
  //                     maxLength: 1,
  //                     textAlign: TextAlign.center,
  //                     keyboardType: TextInputType.text,
  //                     style: const TextStyle(fontSize: 22),
  //                     decoration: const InputDecoration(
  //                       border: OutlineInputBorder(),
  //                       counterText: '', // Removes the '1/1' under each box
  //                     ),
  //                     onChanged: (value) {
  //                       print(value);
  //                       if (value.length == 1 && index < 5 && value != " ") {
  //                         _focusNodes[index + 1].requestFocus();
  //                       } else if (value.length == 6) {
  //                         // Handle paste event
  //                         for (int i = 0; i < 6; i++) {
  //                           _smsCodeController[i].text = value[i];
  //                         }
  //                         _focusNodes[5].unfocus();
  //                         authProvider.isLoading
  //                             ? null
  //                             : () async {
  //                                 String smsCode = _smsCodeController
  //                                     .map((controller) => controller.text)
  //                                     .join();
  //                                 if (smsCode == "" || smsCode.length < 6) {
  //                                   return;
  //                                 }

  //                                 context.closeKeyboard();
  //                                 await authProvider.verifySmsCode(
  //                                     smsCode, context);
  //                                 if (authProvider.status == true) {
  //                                   Navigator.of(context).pushReplacement(
  //                                     MaterialPageRoute(
  //                                       builder: (context) =>
  //                                           const WorkspaceScreen(),
  //                                     ),
  //                                   );
  //                                 }
  //                               }; // Remove focus after complete paste
  //                       }
  //                       if (value.isEmpty && index > 0) {
  //                         _focusNodes[index - 1].requestFocus();
  //                       }
  //                       if (_smsCodeController.every(
  //                           (controller) => controller.text.isNotEmpty)) {
  //                         authProvider.isLoading
  //                             ? null
  //                             : () async {
  //                                 String smsCode = _smsCodeController
  //                                     .map((controller) => controller.text)
  //                                     .join();
  //                                 if (smsCode == "" || smsCode.length < 6) {
  //                                   return;
  //                                 }

  //                                 context.closeKeyboard();
  //                                 await authProvider.verifySmsCode(
  //                                     smsCode, context);
  //                                 if (authProvider.status == true) {
  //                                   Navigator.of(context).pushReplacement(
  //                                     MaterialPageRoute(
  //                                       builder: (context) =>
  //                                           const WorkspaceScreen(),
  //                                     ),
  //                                   );
  //                                 }
  //                               };
  //                       }
  //                     },
  //                     onSubmitted: (_) {
  //                       if (index == 5) {
  //                         _focusNodes[index].unfocus();
  //                         authProvider.isLoading
  //                             ? null
  //                             : () async {
  //                                 String smsCode = _smsCodeController
  //                                     .map((controller) => controller.text)
  //                                     .join();
  //                                 if (smsCode == "" || smsCode.length < 6) {
  //                                   return;
  //                                 }
  //                                 context.closeKeyboard();
  //                                 await authProvider.verifySmsCode(
  //                                     smsCode, context);
  //                                 if (authProvider.status == true) {
  //                                   Navigator.of(context).pushReplacement(
  //                                     MaterialPageRoute(
  //                                       builder: (context) =>
  //                                           const WorkspaceScreen(),
  //                                     ),
  //                                   );
  //                                 }
  //                               };
  //                       }
  //                     },
  //                   ),
  //                 );
  //               }),
  //             ),
  //             const SizedBox(height: 32),
  //             const Text(
  //               'コードが見つからない場合は、迷惑フォルダをご確認ください。',
  //               style: TextStyle(
  //                 fontSize: 14,
  //                 color: Colors.grey,
  //               ),
  //             ),
  //             const SizedBox(height: 24),
  //             Center(
  //               child: ElevatedButton(
  //                 onPressed: authProvider.isLoading
  //                     ? null
  //                     : () async {
  //                         String smsCode = _smsCodeController
  //                             .map((controller) => controller.text)
  //                             .join();
  //                         if (smsCode == "" || smsCode.length < 6) {
  //                           return;
  //                         }
  //                         print(smsCode);
  //                         context.closeKeyboard();
  //                         await authProvider.verifySmsCode(smsCode, context);
  //                         // if (authProvider.status == true) {
  //                         //   Navigator.of(context).pushReplacement(
  //                         //     MaterialPageRoute(
  //                         //       builder: (context) => const WorkspaceScreen(),
  //                         //     ),
  //                         //   );
  //                         // }
  //                       },
  //                 style: ElevatedButton.styleFrom(
  //                   minimumSize: const Size.fromHeight(48),
  //                 ),
  //                 child: const Text('確認'),
  //               ),
  //             ),
  //           ],
  //         );
  //       }),
  //     ),
  //   );
  // }
}
