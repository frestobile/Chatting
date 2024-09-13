// import 'package:ainaglam/screens/home/chat_screen.dart';
import 'package:ainaglam/screens/home/msg_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:ainaglam/extentions/context.dart';
import 'package:ainaglam/utils/dialog.dart';
import '../../providers/home_provider.dart';
// import '../../models/channel_model.dart';
// import '../../models/user_model.dart';

class ChannelAndCoworkersScreen extends StatelessWidget {
  final String workspaceId;
  const ChannelAndCoworkersScreen({super.key, required this.workspaceId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('スレッド & メンバー')),
      body: Consumer<HomeProvider>(
        builder: (context, homeProvider, _) {
          if (homeProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!homeProvider.isApiCalled) {
            homeProvider.fetchWorkspaceDetails(workspaceId);
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
                        top: 10.0,
                        bottom: 10.0,
                        left: 30.0,
                        right: 30.0,
                      ),
                      child: ListTile(
                        title: Text(
                          ' # ${channel.name}',
                          style: context.textTheme.titleMedium,
                        ),
                        subtitle: Text(channel.title,
                            style: context.textTheme.titleSmall),
                        onTap: () async {
                          await homeProvider.fetchChannelData(channel.id);
                          if (homeProvider.channelData != null) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                      workspaceId: workspaceId,
                                      channelId: channel.id,
                                      title: homeProvider.channelData!.name,
                                      isPrivateChat: false)),
                              // builder: (context) => ChatScreen()),
                            );
                          } else {
                            showStatusDialog(
                                context, homeProvider.errorMessage!, false);
                          }
                        },
                      ),
                    );
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
                    return ListTile(
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
                          ? Text('${conversation.name} (あなた)')
                          : Text(conversation.name),
                      onTap: () async {
                        await homeProvider
                            .fetchConversationData(conversation.id);
                        if (homeProvider.convData != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                    workspaceId: workspaceId,
                                    channelId: conversation.id,
                                    title: homeProvider.convData!.name,
                                    avatar: '',
                                    isPrivateChat: true)),
                            // builder: (context) => ChatScreen()),
                          );
                        } else {
                          showStatusDialog(
                              context, homeProvider.errorMessage!, false);
                        }
                      },
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
