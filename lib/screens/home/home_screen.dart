// import 'package:ainaglam/screens/home/chat_screen.dart';
import 'package:ainaglam/screens/home/msg_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:ainaglam/extentions/context.dart';
import '../../providers/home_provider.dart';
// import '../../models/channel_model.dart';
// import '../../models/user_model.dart';

class HomeScreen extends StatefulWidget {
  final String workspaceId;

  const HomeScreen({super.key, required this.workspaceId});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isTapped = false;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeProvider>(context, listen: false)
          .fetchWorkspaceDetails(widget.workspaceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('スレッド & メンバー'), automaticallyImplyLeading: false),
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
                              setState(() {
                                isTapped = true;
                              });
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
                                  horizontal: 12.0, vertical: 8.0),
                              margin: const EdgeInsets.only(bottom: 15.0),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Text(
                                ' # ${channel.name}',
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.black87),
                              ),
                            ),
                          ));
                    },
                  ),
                ),
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
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = conversations[index];
                      return GestureDetector(
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
                              horizontal: 10, vertical: 8),
                          margin: const EdgeInsets.only(top: 5),
                          decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            leading:
                                conversation.collaborators[0].avatarUrl != ''
                                    ? CircleAvatar(
                                        radius: 20,
                                        backgroundImage: NetworkImage(
                                            '${dotenv.env['API_BASE_URL']}/static/avatar/${conversation.collaborators[0].avatarUrl}'),
                                      )
                                    : CircleAvatar(
                                        radius: 20,
                                        backgroundImage: RegExp(r'^[a-z]$')
                                                .hasMatch(conversation.name[0]
                                                    .toLowerCase())
                                            ? AssetImage(
                                                'avatars/${conversation.name[0].toLowerCase()}.png')
                                            : const AssetImage(
                                                'avatars/default.png'),
                                      ),
                            title: conversation.collaborators.length == 1
                                ? Text('${conversation.name} (あなた)',
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black87))
                                : Text(
                                    conversation.name,
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black87),
                                  ),
                            contentPadding: const EdgeInsets.all(5),
                            // tileColor: Colors.grey[200],
                            selectedTileColor: Colors.grey[400],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
