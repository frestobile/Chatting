// import 'package:ainaglam/providers/home_provider.dart';
import 'package:ainaglam/screens/home/thread_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'package:ainaglam/models/message_model.dart';
import 'package:ainaglam/providers/chat_provider.dart';
import 'package:ainaglam/widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String workspaceId;
  final String channelId;
  final bool isPrivateChat;
  final String title;
  final String avatar;
  const ChatScreen({
    super.key,
    required this.workspaceId,
    required this.channelId,
    this.isPrivateChat = false,
    required this.title,
    this.avatar = '',
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  OverlayEntry? _overlayEntry;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  ChatProvider chatProvider = ChatProvider();
  String organisationId = '';
  String channelId = '';
  String title = '';
  String avatar = '';
  bool isChannel = true;

  @override
  void initState() {
    super.initState();
    if (mounted) {}
    chatProvider = Provider.of<ChatProvider>(context, listen: false);
    setState(() {
      organisationId = widget.workspaceId;
      channelId = widget.channelId;
      title = widget.title;
      avatar = widget.avatar;
      isChannel = !widget.isPrivateChat;
    });
    // organisationId = widget.workspaceId;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.isPrivateChat) {
        await chatProvider.fetchConversationMessages(
            widget.workspaceId, widget.channelId);
        channelId = widget.channelId;
      } else {
        await chatProvider.fetchChannelMessages(
            widget.workspaceId, widget.channelId);
        channelId = widget.channelId;
      }
    });
    _scrollToBottom();
    if (mounted) {
      chatProvider.connect();
    }
  }

  @override
  void dispose() {
    _removeReactionPanel();
    _scrollController.dispose();
    _messageController.dispose();
    // chatProvider.dispose();
    super.dispose();
  }

  // Function to show the reaction panel
  void _showReactionPanel(
      BuildContext context, GlobalKey key, Message message) {
    _removeReactionPanel();

    final renderBox = key.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        right: offset.dx + size.width / 2 - 180, // Adjust tooltip position
        top: offset.dy - 10, // Positioning the tooltip above the message
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: const Color.fromARGB(196, 1, 1, 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    _removeReactionPanel();
                    _handleReaction(context, message, '👍');
                  },
                  child: const Text('👍',
                      style: TextStyle(
                          fontFamily: 'NotoColorEmoji', fontSize: 20)),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    _removeReactionPanel();
                    _handleReaction(context, message, '✅');
                  },
                  child: const Text('✅',
                      style: TextStyle(
                          fontFamily: 'NotoColorEmoji', fontSize: 20)),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    _removeReactionPanel();
                    _handleReaction(context, message, '👀');
                  },
                  child: const Text('👀',
                      style: TextStyle(
                          fontFamily: 'NotoColorEmoji', fontSize: 20)),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    _removeReactionPanel();
                    _handleReaction(context, message, '💖');
                  },
                  child: const Text('💖',
                      style: TextStyle(
                          fontFamily: 'NotoColorEmoji', fontSize: 20)),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ThreadScreen(
                          message: message, user: chatProvider.user!),
                    ),
                  ),
                  child: const Icon(Icons.reply, color: Colors.white),
                ),
                const SizedBox(width: 10),
                if (chatProvider.user!.id == message.sender!.id)
                  GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Delete clicked')),
                        );
                        //  confirm dialog
                      },
                      child: const Icon(Icons.delete, color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
    Provider.of<ChatProvider>(context, listen: false)
        .setCurrentMessageId(message.id);
  }

  // Function to remove the reaction panel
  void _removeReactionPanel() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }

    chatProvider.setCurrentMessageId(null);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: isChannel
            ? AppBar(
                actions: [
                  Row(
                    children: [
                      Text(
                        title.toUpperCase(),
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 25),
                    ],
                  ),
                ],
              )
            : AppBar(
                actions: [
                  Row(
                    children: [
                      avatar != ''
                          ? CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(
                                  '${dotenv.env['API_BASE_URL']}/static/avatar/$avatar'),
                            )
                          : CircleAvatar(
                              radius: 20,
                              backgroundImage: RegExp(r'^[a-z]$')
                                      .hasMatch(title[0].toLowerCase())
                                  ? AssetImage('avatars/${title[0]}.png')
                                  : const AssetImage('avatars/default.png'),
                            ),
                      const SizedBox(width: 10),
                      Text(
                        title.toUpperCase(),
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 25),
                    ],
                  ),
                ],
              ),
        body: GestureDetector(
          onTap: () {
            if (_overlayEntry != null) {
              _removeReactionPanel();
            }
          },
          child: Consumer<ChatProvider>(builder: (context, chatProvider, _) {
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
                    controller: _scrollController,
                    itemCount: chatProvider.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatProvider.messages[index];
                      final GlobalKey key = GlobalKey();
                      return GestureDetector(
                          key: key,
                          onTap: () {
                            if (chatProvider.currentMessageId != message.id) {
                              _showReactionPanel(context, key, message);
                            }
                          },
                          child: MessageBubble(
                            message: message,
                            user: chatProvider.user!,
                            onReply: () {},
                          ));
                    },
                  ),
                ),
                _buildMessageInput(chatProvider)
              ],
            );
          }),
        ));
  }

  Widget _buildMessageInput(ChatProvider chatProvider) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Message #development',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              // chatProvider.sendMessage(
              //     organisationId, channelId, _messageController.text);
              _messageController.clear(); // Clear the input field
              _scrollToBottom();
            },
          ),
        ],
      ),
    );
  }

  void _handleReaction(BuildContext context, Message message, String emoji) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.addEmojiReaction(message, emoji);
    // Navigator.pop(context);
  }

  void _deleteMessage(BuildContext context, Message message) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.deleteMessage(message);
    // Navigator.pop(context);
  }
}
