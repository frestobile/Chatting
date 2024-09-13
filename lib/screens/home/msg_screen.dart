import 'package:ainaglam/screens/home/thread_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

import 'package:flutter_html/flutter_html.dart';
import 'package:ainaglam/models/message_model.dart';
import 'package:ainaglam/providers/chat_provider.dart';
import 'package:ainaglam/widgets/message_bubble.dart';
import 'package:ainaglam/widgets/message_input_widget.dart';

class ChatScreen extends StatefulWidget {
  final String workspaceId;
  final String channelId;
  final bool isPrivateChat;
  const ChatScreen({super.key, 
    required this.workspaceId,
    required this.channelId,
    this.isPrivateChat = false,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  OverlayEntry? _overlayEntry;
  final quill.QuillController _quillController = quill.QuillController.basic();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  String organisationId = '';
  String channelId = '';

  List<Message> messages = [];
  @override
  void initState() {
    super.initState();
    // Call the provider to fetch messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      organisationId = widget.workspaceId;

      if (widget.isPrivateChat) {
        Provider.of<ChatProvider>(context, listen: false)
            .fetchConversationMessages(widget.workspaceId, widget.channelId);
        channelId = widget.channelId;
      } else {
        Provider.of<ChatProvider>(context, listen: false)
            .fetchChannelMessages(widget.workspaceId, widget.channelId);
        channelId = widget.channelId;
      }
    });
    loadMessages();
    Provider.of<ChatProvider>(context, listen: false).connect();
  }

  void loadMessages() {
    setState(() {
      messages = Provider.of<ChatProvider>(context, listen: false).messages;
    });
    _scrollToBottom();
  }
  @override
  void dispose() {
    _removeReactionPanel();
    _scrollController.dispose();
     _messageController.dispose();
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
                  child: Text('👍',
                      style: GoogleFonts.notoColorEmoji(fontSize: 24)),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    _removeReactionPanel();
                    _handleReaction(context, message, '✅');
                  },
                  child: Text('✅',
                      style: GoogleFonts.notoColorEmoji(fontSize: 24)),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    _removeReactionPanel();
                    _handleReaction(context, message, '👀');
                  },
                  child: Text('👀',
                      style: GoogleFonts.notoColorEmoji(fontSize: 24)),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    _removeReactionPanel();
                    _handleReaction(context, message, '💖');
                  },
                  child: Text('💖',
                      style: GoogleFonts.notoColorEmoji(fontSize: 24)),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ThreadScreen(parentMessage: message),
                    ),
                  ),
                  child: const Icon(Icons.reply),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Delete clicked')),
                    );
                    //  confirm dialog
                  },
                  child: const Icon(Icons.delete)
                ),
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
    _overlayEntry?.remove();
    _overlayEntry = null;
    Provider.of<ChatProvider>(context, listen: false).setCurrentMessageId(null);
  }

  void _scrollToBottom() {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('DEVELOPMENT'),
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
              chatProvider.sendMessage(organisationId, channelId, _messageController.text);
              _messageController.clear(); // Clear the input field
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEditorToolbar() {
    return quill.QuillToolbar.simple(
      controller: _quillController,
      // multiRowsDisplay: false, // You can enable multi-rows display if necessary
    );
  }

  // The rich text editor
  Widget _buildEditor() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 150, // Adjust as needed for your UI
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: quill.QuillEditor(
          controller: _quillController,
          scrollController: ScrollController(),
          // scrollable: true,
          focusNode: FocusNode(),
          // autoFocus: false,
          // readOnly: false, // False so users can edit
          // expands: false,
          // padding: EdgeInsets.all(10),
          // keyboardAppearance: Brightness.light,
        ),
      ),
    );
  }

  // Send button to handle message sending
  Widget _buildSendButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Extract and print the rich text document content
                final doc = _quillController.document;
                final delta = doc.toDelta().toJson();
                print('Message content (Delta): $delta');

                // You can send this delta format to the server or convert it to plain text
                // Then clear the editor for the next input
                _quillController.clear();
              },
              child: const Text('Send'),
            ),
          ),
        ],
      ),
    );
  }

  void _handleReaction(BuildContext context, Message message, String emoji) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.addEmojiReaction(message.id, emoji);
    Navigator.pop(context);
  }

  void _deleteMessage(BuildContext context, Message message) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.deleteMessage(message);
    Navigator.pop(context);
  }
}
