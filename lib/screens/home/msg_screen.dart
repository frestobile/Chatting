import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:ainaglam/screens/home/thread_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:quill_html_editor/quill_html_editor.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import 'package:file_picker/file_picker.dart';
import 'package:ainaglam/models/message_model.dart';
import 'package:ainaglam/providers/chat_provider.dart';
import 'package:ainaglam/widgets/message_bubble.dart';
import 'package:ainaglam/utils/dialog.dart';

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
  final QuillEditorController _controller =
      QuillEditorController(); // Initialize the editor controller

  ChatProvider chatProvider = ChatProvider();
  String organisationId = '';
  String channelId = '';
  String title = '';
  String avatar = '';
  bool isChannel = true;

  File? _selectedFile; // For mobile
  Uint8List? _selectedFileBytes; // For web

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
        await chatProvider.fetchConversationData(channelId);
        channelId = widget.channelId;
      } else {
        await chatProvider.fetchChannelMessages(
            widget.workspaceId, widget.channelId);
        await chatProvider.fetchChannelData(channelId);
        channelId = widget.channelId;
      }
    });
    if (mounted) {
      chatProvider.connect();
    }
  }

  @override
  void dispose() {
    _removeReactionPanel();
    _controller.dispose();
    _scrollController.dispose();
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
                  onTap: () {
                    _removeReactionPanel();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ThreadScreen(
                            message: message,
                            user: chatProvider.user!,
                            chatTitle: title),
                      ),
                    );
                  },
                  child: const Icon(Icons.reply, color: Colors.white),
                ),
                const SizedBox(width: 10),
                if (chatProvider.user!.id == message.sender!.id)
                  GestureDetector(
                      onTap: () {
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   const SnackBar(content: Text('Delete clicked')),
                        // );
                        _removeReactionPanel();
                        chatProvider.deleteMessage(message);
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
    _overlayEntry?.remove();
    _overlayEntry = null;
    chatProvider.setCurrentMessageId(null);
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white, // App bar background color
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 1,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  if (!isChannel)
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
                  if (isChannel)
                    Text(
                      title.toUpperCase(),
                      style: const TextStyle(fontSize: 18),
                    ),
                  const SizedBox(width: 10)
                ],
              ),
            ),
          ),
        ),
      ),
      // : AppBar(
      //     actions: [
      //       Row(
      //         children: [
      //           avatar != ''
      //               ? CircleAvatar(
      //                   radius: 20,
      //                   backgroundImage: NetworkImage(
      //                       '${dotenv.env['API_BASE_URL']}/static/avatar/$avatar'),
      //                 )
      //               : CircleAvatar(
      //                   radius: 20,
      //                   backgroundImage: RegExp(r'^[a-z]$')
      //                           .hasMatch(title[0].toLowerCase())
      //                       ? AssetImage('avatars/${title[0]}.png')
      //                       : const AssetImage('avatars/default.png'),
      //                 ),
      //           const SizedBox(width: 10),
      //           Text(
      //             title.toUpperCase(),
      //             style: const TextStyle(fontSize: 18),
      //           ),
      //           const SizedBox(width: 25),
      //         ],
      //       ),
      //     ],
      //   ),
      body: GestureDetector(
        onTap: () {
          if (_overlayEntry != null) {
            _removeReactionPanel();
          }
        },
        child: Column(
          children: [
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, value, _) {
                  if (chatProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (chatProvider.errorMessage != null) {
                    return Center(child: Text(chatProvider.errorMessage!));
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: chatProvider.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatProvider.messages[index];
                      final GlobalKey key = GlobalKey();
                      return GestureDetector(
                        key: key,
                        onTap: () {
                          if (message.type != 'date') {
                            if (chatProvider.currentMessageId != message.id) {
                              _showReactionPanel(context, key, message);
                            }
                          }
                        },
                        child: MessageBubble(
                          message: message,
                          user: chatProvider.user!,
                          onReply: () {
                            _removeReactionPanel();
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => ThreadScreen(
                                    message: message,
                                    user: chatProvider.user!,
                                    chatTitle: title),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // _buildMessageInput(chatProvider)
            _buildEditor()
          ],
        ),
      ),
    );
  }

  String lastHtmlContent = "";
  bool _hasFocus = false;

  final customToolBarList = [
    ToolBarStyle.headerOne,
    ToolBarStyle.bold,
    ToolBarStyle.italic,
    ToolBarStyle.underline,
    ToolBarStyle.align,
    ToolBarStyle.listBullet,
    ToolBarStyle.blockQuote,
    ToolBarStyle.link,
    ToolBarStyle.codeBlock,
  ];
  final _toolbarColor = Colors.grey.shade200;
  final _backgroundColor = Colors.white70;
  final _toolbarIconColor = Colors.black87;
  final _editorTextStyle = const TextStyle(
      fontSize: 16,
      color: Colors.black,
      fontWeight: FontWeight.normal,
      fontFamily: 'Roboto');
  final _hintTextStyle = const TextStyle(
      fontSize: 16,
      color: Color.fromARGB(91, 0, 0, 0),
      fontWeight: FontWeight.normal);

  Widget _buildEditor() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        children: [
          // Toolbar with custom image button
          ToolBar(
            toolBarColor: _toolbarColor, //Colors.cyan.shade50,
            activeIconColor: Colors.green,
            padding: const EdgeInsets.all(5),
            iconSize: 25,
            iconColor: _toolbarIconColor,
            controller: _controller,
            toolBarConfig: customToolBarList,
            crossAxisAlignment: WrapCrossAlignment.start,
            direction: Axis.horizontal,
            customButtons: [
              InkWell(
                onTap: _pickImage,
                child: const Icon(Icons.image),
              ),
              InkWell(
                onTap: _pickVideo,
                child: const Icon(Icons.video_camera_front_outlined),
              )
            ],
          ),

          Row(
            children: [
              Expanded(
                child: QuillHtmlEditor(
                  controller: _controller,
                  hintText: 'Message #$title',
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.only(left: 5, top: 5),
                  minHeight: 50,
                  isEnabled: true,
                  ensureVisible: false,
                  autoFocus: false,
                  textStyle: _editorTextStyle,
                  hintTextStyle: _hintTextStyle,
                  hintTextAlign: TextAlign.start,
                  inputAction: InputAction.newline,
                  onFocusChanged: (focus) async {
                    // debugPrint('has focus $focus from $_hasFocus');
                    // if (_hasFocus == false) {
                    //   if (isChannel) {
                    //     await chatProvider.fetchChannelMessages(
                    //         organisationId, channelId);
                    //   } else {
                    //     await chatProvider.fetchConversationMessages(
                    //         organisationId, channelId);
                    //   }
                    // }
                    setState(() {
                      _hasFocus = focus;
                    });
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.blue),
                onPressed: sendMessage, // Send button action
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Method to pick an image
  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      // allowedExtensions: ['jpg', 'png', 'bmp', 'ico', ''],
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      if (kIsWeb) {
        Uint8List? fileBytes = result.files.single.bytes;
        if (fileBytes != null) {
          setState(() {
            _selectedFileBytes = fileBytes; // Store file bytes for web
          });
          await chatProvider.imageUploadByByte(_selectedFileBytes!);
        }
      } else {
        String? filePath = result.files.single.path;
        if (filePath != null) {
          setState(() {
            _selectedFile = File(filePath);
          });
          await chatProvider.imageUploadByFile(_selectedFile!);
        }
      }
    }

    if (chatProvider.uploadedImageName != null) {
      _selectedFile = null;
      _selectedFileBytes = null;
      await _insertImageIntoEditor(chatProvider.uploadedImageName!);
      debugPrint("upload success!!!");
    }
  }

  Future<void> _pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
      // allowedExtensions: ['jpg', 'png', 'bmp', 'ico', ''],
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      if (file.size > 104857600) {
        showStatusDialog(context, 'ファイルサイズは100MB以下にしてください', false);
      } else {
        if (kIsWeb) {
          Uint8List? fileBytes = result.files.single.bytes;
          if (fileBytes != null) {
            setState(() {
              _selectedFileBytes = fileBytes; // Store file bytes for web
            });
            await chatProvider.videoUploadByByte(_selectedFileBytes!);
          }
        } else {
          String? filePath = result.files.single.path;
          if (filePath != null) {
            setState(() {
              _selectedFile = File(filePath);
            });
            await chatProvider.videoUploadByFile(_selectedFile!);
          }
        }
      }
    }

    if (chatProvider.uploadedVideoName != null) {
      _selectedFile = null;
      _selectedFileBytes = null;
      await _insertVideoIntoEditor(chatProvider.uploadedVideoName!);
      debugPrint("upload success!!!");
    }
  }

  Future<void> _insertVideoIntoEditor(String filename) async {
    String baseUrl = dotenv.env['API_BASE_URL']!;
    String src = '${dotenv.env['API_BASE_URL']!}/static/image/$filename';
    String customHtml = '''<a href="$src" target="_blank">$filename</a>''';
    String cleanedHtmlString = cleanHtmlString(customHtml);
    await _controller.setText(cleanedHtmlString);
  }

  Future<void> _insertImageIntoEditor(String filename) async {
    String baseUrl = dotenv.env['API_BASE_URL']!;
    String src = '${dotenv.env['API_BASE_URL']!}/static/image/$filename';
    String customHtml =
        '''<div><a href="$src" target="_blank" style="text-decoration: none;"><img alt='test' src="$src"
                                  style="
                                    width: 120px;
                                    border-radius: 8px;
                                    border: 2px solid white;
                                    margin-bottom: 6px
                                  "
                                  width=120
                                  height=120
                                />
                              </a></div>
                              <a href="${'$baseUrl/messages/download/$filename'}">$filename</a>''';
    String cleanedHtmlString = cleanHtmlString(customHtml);
    await _controller.setText(cleanedHtmlString);
  }

  String cleanHtmlString(String htmlString) {
    dom.Document document = html_parser.parse(htmlString);

    // Find all anchor tags (<a>) and remove the 'rel' attribute if it exists
    document.querySelectorAll('a').forEach((anchor) {
      anchor.attributes.remove('rel');
    });

    // Convert the cleaned HTML back to a string
    return document.body?.innerHtml ?? htmlString;
  }

  void sendMessage() async {
    final htmlContent = await _controller.getText();
    String nextContent = cleanHtmlString(htmlContent);
    var lastCharIndex = htmlContent.length - 1;
    while (htmlContent.substring(lastCharIndex - 10, lastCharIndex + 1) ==
        '<p><br></p>') {
      nextContent = nextContent.substring(0, lastCharIndex - 10);
      lastCharIndex = nextContent.length - 1;
    }
    if (nextContent == '') {
      return;
    }
    nextContent = nextContent.replaceAll('<br>', '');
    if (nextContent.contains('width: 120px;')) {
      nextContent = nextContent.replaceAll('width: 120px;', 'width: 30%;');
    }

    final newMsg = {"sender": chatProvider.user!, "content": nextContent};
    await chatProvider.sendMessage(
        organisationId, channelId, newMsg, isChannel);
    _scrollToBottom();
    _controller.clear(); // Clear editor after sending
  }

  void _handleReaction(BuildContext context, Message message, String emoji) {
    chatProvider.addEmojiReaction(message, emoji);
    // Navigator.pop(context);
  }

  void _deleteMessage(BuildContext context, Message message) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.deleteMessage(message);
    // Navigator.pop(context);
  }
}
