import 'package:ainaglam/screens/chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: channels.length,
                  itemBuilder: (context, index) {
                    final channel = channels[index];
                    return ListTile(
                      title: Text(channel.name),
                      subtitle: Text(channel.name),
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
                    );
                  },
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: coworkers.length,
                  itemBuilder: (context, index) {
                    final coworker = coworkers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(coworker.avatarUrl),
                      ),
                      title: Text(coworker.displayName),
                      subtitle: Text(coworker.email),
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
