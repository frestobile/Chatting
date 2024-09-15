import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:ainaglam/providers/workspace_provider.dart';
import 'package:ainaglam/providers/auth_provider.dart';
import 'package:ainaglam/providers/home_provider.dart';
import 'package:ainaglam/providers/chat_provider.dart';
import 'package:ainaglam/providers/thread_provider.dart';
import 'package:ainaglam/screens/auth/splash.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<WorkspaceProvider>(
            create: (_) => WorkspaceProvider()),
        ChangeNotifierProvider<HomeProvider>(create: (_) => HomeProvider()),
        ChangeNotifierProvider<ChatProvider>(create: (_) => ChatProvider()),
        ChangeNotifierProvider<ThreadProvider>(create: (_) => ThreadProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'Ainaglam',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
