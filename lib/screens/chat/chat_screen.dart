import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/message_input_widget.dart';
import '../../widgets/emoji_reaction_widget.dart';

class ChatScreen extends StatelessWidget {
  final String workspaceId;
  final String channelId;
  final bool isPrivateChat;

  const ChatScreen({super.key, 
    required this.workspaceId,
    required this.channelId,
    this.isPrivateChat = false,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatProvider(workspaceId: workspaceId, channelId: channelId),
      child: Scaffold(
        appBar: AppBar(
          title: Text(isPrivateChat ? 'Private Chat' : 'Channel Chat'),
        ),
        body: Column(
          children: [
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, _) {
                  return ListView.builder(
                    itemCount: chatProvider.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatProvider.messages[index];
                      return ListTile(
                        title: Text(message.content),
                        subtitle: Row(
                          children: [
                            EmojiReactionWidget(
                              emoji: '👍',
                              count: message.reactions['👍'] ?? 0,
                              onReact: (emoji) {
                                // Handle reaction logic
                              },
                            ),
                            EmojiReactionWidget(
                              emoji: '❤️',
                              count: message.reactions['❤️'] ?? 0,
                              onReact: (emoji) {
                                // Handle reaction logic
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            MessageInputWidget(
              onSend: (message) {
                Provider.of<ChatProvider>(context, listen: false)
                    .sendMessages(message);
              },
            ),
          ],
        ),
      ),
    );
  }
}