import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:ainaglam/models/message_model.dart';
import 'package:ainaglam/providers/chat_provider.dart';

import 'package:ainaglam/models/channel_model.dart';
import 'package:ainaglam/models/coworker_model.dart';
import 'package:ainaglam/screens/home/thread_screen.dart';

import 'package:ainaglam/widgets/message_input_widget.dart';
import 'package:ainaglam/widgets/emoji_reaction_widget.dart';

class ChatScreen extends StatefulWidget {
  final String workspaceId;
  final String channelId;
  final bool isPrivateChat;

  ChatScreen({
    required this.workspaceId,
    required this.channelId,
    this.isPrivateChat = false,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    // Call the provider to fetch messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isPrivateChat) {
        Provider.of<ChatProvider>(context, listen: false)
            .fetchConversationMessages(widget.workspaceId, widget.channelId);
      } else {
        Provider.of<ChatProvider>(context, listen: false)
            .fetchChannelMessages(widget.workspaceId, widget.channelId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DEVELOPMENT'),
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          if (chatProvider.isLoading) {
            return const Center(
                child: CircularProgressIndicator()); // Show loading spinner
          }

          if (chatProvider.errorMessage != null) {
            return Center(
                child: Text(chatProvider.errorMessage!)); // Handle errors
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: chatProvider.messages.length,
                  itemBuilder: (context, index) {
                    final message = chatProvider.messages[index];
                    return MessageBubble(
                      message: message,
                    );
                  },
                ),
              ),
              _buildMessageInput(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Message #development',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => message.type != 'date'
          ? _showReactionTooltip(context, message)
          : () {},
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
        child: Align(
            alignment:
                message.isSelf ? Alignment.centerRight : Alignment.centerLeft,
            child: Column(
              children: [
                if (message.type != 'date')
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      message.sender!.avatarUrl != ''
                          ? CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(
                                  '${dotenv.env['API_BASE_URL']}/static/avatar/${message.sender!.avatarUrl}'),
                            )
                          : CircleAvatar(
                              radius: 20,
                              backgroundImage: RegExp(r'^[a-z]$').hasMatch(
                                      message.sender!.displayName.toLowerCase())
                                  ? AssetImage(
                                      'avatars/${message.sender!.displayName.toLowerCase()}.png')
                                  : const AssetImage('avatars/default.png'),
                            ),
                      const SizedBox(width: 8.0),
                      Text(
                        message.sender!.displayName,
                        style: const TextStyle(
                            fontSize: 14.0, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        DateFormat('hh:mm a')
                            .format(DateTime.parse(message.createdAt)),
                        style:
                            const TextStyle(fontSize: 10.0, color: Colors.grey),
                      ),
                    ],
                  ),
                if (message.type != 'date')
                  Container(
                    margin: const EdgeInsets.only(top: 2.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: message.isSelf ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Html(data: message.content),
                        // Show reactions if they exist
                        if (message.reactions.isNotEmpty)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: message.reactions.map((entry) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: Text(
                                  "${entry.emoji}: ${entry.reactedToBy.length}",
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.black54),
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                if (message.type == 'date')
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Divider(
                            color: Colors.grey, // Color of the divider
                            thickness: 1, // Thickness of the divider
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            message.content,
                            style: const TextStyle(
                              fontSize: 12, // Font size of the text
                              fontWeight:
                                  FontWeight.w200, // Font weight of the text
                              color: Colors.black, // Color of the text
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(
                            color: Colors.grey,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                  )
              ],
            )),
      ),
    );
  }

  void _showReactionTooltip(BuildContext context, Message message) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "React to message",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Reactions using emojis
                  GestureDetector(
                    onTap: () => _handleReaction(context, message, '👍'),
                    // child: Html(data: '👍')
                    child: const Text(
                      '👍',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _handleReaction(context, message, '👎'),
                    child: const Text(
                      '👎',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _handleReaction(context, message, '😂'),
                    child: const Text(
                      '😂',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _handleReaction(context, message, '❤️'),
                    child: const Text(
                      '❤️',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleReaction(BuildContext context, Message message, String reaction) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    // Send the emoji reaction to the server using the provider
    // chatProvider.sendReaction(message.id, reaction).then((_) {
    //   print("Reaction to message '${message.content}' was successful: $reaction");
    // }).catchError((error) {
    //   print("Failed to send reaction: $error");
    // });

    Navigator.pop(context); // Close the modal after reaction
  }
}
