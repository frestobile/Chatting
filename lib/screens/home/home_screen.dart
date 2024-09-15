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

          return Column(
            children: [
              Text("スレッド", style: context.textTheme.headlineSmall),
              Expanded(
                child: ListView.builder(
                  itemCount: channels.length,
                  itemBuilder: (context, index) {
                    final channel = channels[index];
                    return Padding(
                        padding: const EdgeInsets.only(
                          top: 5.0,
                          bottom: 5.0,
                          left: 30.0,
                          right: 30.0,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            // await homeProvider.fetchChannelData(channel.id);
                            // if (homeProvider.channelData != null) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                        workspaceId: channel.organisation,
                                        channelId: channel.id,
                                        title: channel.name,
                                      )),
                            );
                            // }
                          },
                          child: ListTile(
                            title: Text(
                              ' # ${channel.name}',
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.black87),
                            ),
                            contentPadding: const EdgeInsets.all(5),
                            // tileColor: Colors.grey[200],
                            selectedTileColor: Colors.grey[400],
                          ),
                        ));
                  },
                ),
              ),
              const Divider(),
              Text("メンバー", style: context.textTheme.headlineSmall),
              Expanded(
                child: ListView.builder(
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = conversations[index];
                    return Padding(
                      padding: const EdgeInsets.only(
                          top: 2.0, bottom: 2.0, left: 30),
                      child: GestureDetector(
                        onTap: () {
                          // await homeProvider
                          //     .fetchConversationData(conversation.id);
                          // if (homeProvider.convData != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                      workspaceId: widget.workspaceId,
                                      channelId: conversation.id,
                                      isPrivateChat: true,
                                      title: conversation.name,
                                      avatar: conversation.avatar,
                                    )),
                            // builder: (context) => ChatScreen()),
                          );
                          // }
                        },
                        child: ListTile(
                          leading: conversation.collaborators[0].avatarUrl != ''
                              ? CircleAvatar(
                                  radius: 20,
                                  backgroundImage: NetworkImage(
                                      '${dotenv.env['API_BASE_URL']}/static/avatar/${conversation.collaborators[0].avatarUrl}'),
                                )
                              : CircleAvatar(
                                  radius: 20,
                                  backgroundImage: RegExp(r'^[a-z]$').hasMatch(
                                          conversation.name[0].toLowerCase())
                                      ? AssetImage(
                                          'avatars/${conversation.name[0].toLowerCase()}.png')
                                      : const AssetImage('avatars/default.png'),
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
          );
        },
      ),
    );
  }
}
