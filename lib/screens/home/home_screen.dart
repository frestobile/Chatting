import 'package:ainaglam/screens/auth/login_screen.dart';
import 'package:ainaglam/screens/chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:ainaglam/extentions/context.dart';
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
          final coworkers = homeProvider.coworkers;
          final conversation = homeProvider.conversations;

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
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                workspaceId: workspaceId,
                                channelId: channel.id,
                              ),
                            ),
                          );
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
                  itemCount: coworkers.length,
                  itemBuilder: (context, index) {
                    final coworker = coworkers[index];
                    return ListTile(
                      leading: coworker.avatarUrl != ''
                          ? CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(
                                  '${dotenv.env['API_BASE_URL']}/static/avatar/${coworker.avatarUrl}'),
                            )
                          : CircleAvatar(
                              radius: 30,
                              backgroundImage: RegExp(r'^[a-z]$').hasMatch(
                                      coworker.username[0].toLowerCase())
                                  ? AssetImage(
                                      'avatars/${coworker.username[0].toLowerCase()}.png')
                                  : const AssetImage('avatars/default.png'),
                            ),
                      title: Text(coworker.displayName),
                      subtitle: Text(coworker.username),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              workspaceId: workspaceId,
                              channelId: coworker.id,
                            ),
                          ),
                        );
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
