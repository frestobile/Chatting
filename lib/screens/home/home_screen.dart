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
      appBar: AppBar(title: const Text('Channels & Coworkers')),
      body: FutureBuilder(
        future: Provider.of<HomeProvider>(context, listen: false)
            .fetchWorkspaceDetails(workspaceId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Consumer<HomeProvider>(
              builder: (context, homeProvider, _) {
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: homeProvider.channels.length,
                        itemBuilder: (context, index) {
                          final channel = homeProvider.channels[index];
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
                        itemCount: homeProvider.coworkers.length,
                        itemBuilder: (context, index) {
                          final coworker = homeProvider.coworkers[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(coworker.avatarUrl),
                            ),
                            title: Text(coworker.name),
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
            );
          }
        },
      ),
    );
  }
}
