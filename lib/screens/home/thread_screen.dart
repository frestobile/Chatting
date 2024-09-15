// import 'package:ainaglam/providers/home_provider.dart';
import 'package:ainaglam/models/threadmsg_model.dart';
import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:ainaglam/models/message_model.dart';
import 'package:ainaglam/providers/thread_provider.dart';
import 'package:ainaglam/widgets/threadmsg_bubble.dart';
import 'package:ainaglam/widgets/message_bubble.dart';
import 'package:ainaglam/models/coworker_model.dart';

class ThreadScreen extends StatefulWidget {
  final Message message;
  final Coworker user;
  const ThreadScreen({super.key, required this.message, required this.user});

  @override
  _ThreadScreenState createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
  OverlayEntry? _overlayEntry;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  ThreadProvider threadProvider = ThreadProvider();
  Message? parentMessage;
  Coworker? userData;
  @override
  void initState() {
    super.initState();
    parentMessage = widget.message;
    userData = widget.user;
    threadProvider = Provider.of<ThreadProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await threadProvider.fetchThreadMessages(parentMessage!.id);
      _scrollToBottom();
    });
    threadProvider.connect();
  }

  @override
  void dispose() {
    _removeReactionPanel();
    _scrollController.dispose();
    _messageController.dispose();
    // threadProvider.dispose();
    super.dispose();
  }

  // Function to show the reaction panel
  void _showReactionPanel(
      BuildContext context, GlobalKey key, ThreadMsg message) {
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
                if (userData!.id == message.sender.id)
                  GestureDetector(
                      onTap: () {
                        _removeReactionPanel();
                        if (parentMessage!.conversation == '') {
                          threadProvider.deleteMessage(
                              message, userData!, parentMessage!.channel);
                        } else if (parentMessage!.channel == '') {
                          threadProvider.deleteMessage(
                              message, userData!, parentMessage!.conversation);
                        }
                      },
                      child: const Icon(Icons.delete, color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
    threadProvider.setCurrentMessageId(message.id);
  }

  // Function to remove the reaction panel
  void _removeReactionPanel() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    threadProvider.setCurrentMessageId(null);
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
      appBar: AppBar(
        actions: [
          Row(
            children: [
              const Text(
                'スレッド',
                style: TextStyle(fontSize: 19),
              ),
              const SizedBox(width: 10),
              Text('# ${parentMessage!.sender!.displayName}',
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 25),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Text(userData!.displayName),
          MessageBubble(
            message: parentMessage!,
            user: userData!,
            isThread: true,
            onReply: () {},
          ),
          if (parentMessage!.threadReplies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      '${parentMessage!.threadRepliesCount} コメント',
                      style: const TextStyle(
                        fontSize: 12, // Font size of the text
                        fontWeight: FontWeight.w200, // Font weight of the text
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
            ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_overlayEntry != null) {
                  _removeReactionPanel();
                }
              },
              child: Consumer<ThreadProvider>(
                  builder: (context, threadProvider, _) {
                if (threadProvider.isLoading) {
                  return const Center(
                      child:
                          CircularProgressIndicator()); // Show loading spinner
                }

                if (threadProvider.errorMessage != null) {
                  return Center(
                      child:
                          Text(threadProvider.errorMessage!)); // Handle errors
                }
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: threadProvider.threadMessages.length,
                        itemBuilder: (context, index) {
                          final message = threadProvider.threadMessages[index];
                          final GlobalKey key = GlobalKey();
                          return GestureDetector(
                              key: key,
                              onTap: () {
                                if (threadProvider.currentMessageId !=
                                    message.id) {
                                  _showReactionPanel(context, key, message);
                                }
                              },
                              child: ThreadMessage(
                                  message: message, user: userData!));
                        },
                      ),
                    ),
                    _buildMessageInput(threadProvider)
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(ThreadProvider threadProvider) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Message #thread',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              if (_messageController.text.isNotEmpty) {
                final newMsg = {
                  "sender": userData,
                  "content": _messageController.text
                };
                threadProvider.sendMessages(
                    parentMessage!.id, userData!, newMsg);
                _messageController.clear(); // Clear the input field
                _scrollToBottom();
              }
            },
          ),
        ],
      ),
    );
  }

  void _handleReaction(BuildContext context, ThreadMsg message, String emoji) {
    // final threadProvider = Provider.of<ThreadProvider>(context, listen: false);
    threadProvider.addEmojiReaction(message, parentMessage!, emoji, userData!);
    // Navigator.pop(context);
  }

  void _deleteMessage(BuildContext context, ThreadMsg message) {
    // final threadProvider = Provider.of<ThreadProvider>(context, listen: false);
    // threadProvider.deleteMessage(message);
    // Navigator.pop(context);
  }
}
