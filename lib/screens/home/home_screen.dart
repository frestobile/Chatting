// import 'package:ainaglam/screens/home/chat_screen.dart';
import 'package:ainaglam/models/user_model.dart';
import 'package:ainaglam/providers/auth_provider.dart';
import 'package:ainaglam/screens/auth/login_screen.dart';
import 'package:ainaglam/screens/home/msg_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import '../../providers/home_provider.dart';
import 'package:ainaglam/screens/home/workspace_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import '../../models/channel_model.dart';
// import '../../models/user_model.dart';

class HomeScreen extends StatefulWidget {
  final String workspaceId;
  final String workspaceName;

  const HomeScreen(
      {super.key, required this.workspaceId, required this.workspaceName});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthProvider _authProvider = AuthProvider();
  bool isTapped = false;
  String title = '';
  @override
  void initState() {
    super.initState();

    title = widget.workspaceName;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeProvider>(context, listen: false)
          .fetchWorkspaceDetails(widget.workspaceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white, // App bar background color
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 1,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
              child: Row(
                children: [
                  PopupMenuButton<int>(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 1,
                        child: Row(
                          children: [
                            Icon(Icons.compare_arrows_rounded,
                                color: Colors.grey[600]),
                            const SizedBox(width: 10),
                            Text(
                              title,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 0,
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: Colors.grey[600]),
                            const SizedBox(width: 10),
                            Text(
                              "ログアウト",
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) async {
                      // Handle menu selection
                      if (value == 1) {
                        // workspace screen

                        User? userData = await _authProvider.loadAuthData();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) =>
                                WorkspaceScreen(tokenString: userData!.token),
                          ),
                        );
                      } else if (value == 0) {
                        //logout
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.remove('profile_data');
                        await prefs.remove('user_data');
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      }
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.lightBlue, // Avatar color
                          child: Text(
                            title[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Consumer<HomeProvider>(
        builder: (context, homeProvider, _) {
          if (homeProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (homeProvider.errorMessage != null) {
            return Center(child: Text(homeProvider.errorMessage!));
          }
          final channels = homeProvider.channels;
          final conversations = homeProvider.conversations;

          return Padding(
            padding:
                const EdgeInsets.only(top: 8, left: 20, right: 20, bottom: 10),
            child: Column(
              children: [
                const SizedBox(height: 15),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'スレッド',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.arrow_drop_down,
                        color: Color.fromARGB(255, 0, 0, 0)),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: channels.length,
                    itemBuilder: (context, index) {
                      final channel = channels[index];
                      return Padding(
                          padding: const EdgeInsets.only(
                            left: 5.0,
                            right: 5.0,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                          workspaceId: channel.organisation,
                                          channelId: channel.id,
                                          title: channel.name,
                                        )),
                              );
                            },
                            child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 2.0),
                                margin: const EdgeInsets.only(bottom: 5.0),
                                child: Row(
                                  children: [
                                    Text(
                                      ' # ${channel.name}',
                                      style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const Spacer(),
                                    if (channel.unreadMessagesNumber != 0)
                                      CircleAvatar(
                                        radius: 8,
                                        backgroundColor:
                                            Colors.pinkAccent, // Avatar color
                                        child: Text(
                                          '${channel.unreadMessagesNumber}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                  ],
                                )),
                          ));
                    },
                  ),
                ),
                // ListTile(
                //   leading: Icon(Icons.add_circle_outline),
                //   title: Text("新しいスレッドを作成する"),
                // ),
                const Divider(),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'メンバー',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.arrow_drop_down,
                        color: Color.fromARGB(255, 0, 0, 0)),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = conversations[index];
                      return Padding(
                        padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  workspaceId: widget.workspaceId,
                                  channelId: conversation.id,
                                  isPrivateChat: true,
                                  title: conversation.name,
                                  avatar: conversation.avatar,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 2.0),
                            margin: const EdgeInsets.only(bottom: 5.0),
                            child: Row(
                              children: [
                                conversation.avatar != ''
                                    ? CircleAvatar(
                                        radius: 14,
                                        backgroundImage: NetworkImage(
                                            '${dotenv.env['API_BASE_URL']}/static/avatar/${conversation.avatar}'),
                                      )
                                    : CircleAvatar(
                                        radius: 14,
                                        backgroundImage: RegExp(r'^[a-z]$')
                                                .hasMatch(conversation.name[0]
                                                    .toLowerCase())
                                            ? AssetImage(
                                                'avatars/${conversation.name[0].toLowerCase()}.png')
                                            : const AssetImage(
                                                'avatars/default.png'),
                                      ),
                                const SizedBox(width: 10),
                                conversation.collaborators.length == 1
                                    ? Text('${conversation.name} (あなた)',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.bold))
                                    : Text(
                                        conversation.name,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.bold),
                                      ),
                                const Spacer(),
                                if (conversation.unreadMessagesNumber != 0)
                                  CircleAvatar(
                                    radius: 8,
                                    backgroundColor:
                                        Colors.pinkAccent, // Avatar color
                                    child: Text(
                                      '${conversation.unreadMessagesNumber}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // ListTile(
                //   leading: Icon(Icons.add_circle_outline),
                //   title: Text("グループに招待する"),
                // ),
              ],
            ),
          );
        },
      ),
    );
  }
}
