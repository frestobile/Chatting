// import 'package:ainaglam/providers/home_provider.dart';
import 'dart:io';

import 'package:ainaglam/models/threadmsg_model.dart';
import 'package:ainaglam/utils/dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quill_html_editor/quill_html_editor.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import 'package:ainaglam/models/message_model.dart';
import 'package:ainaglam/providers/chat_provider.dart';
import 'package:ainaglam/widgets/threadmsg_bubble.dart';
import 'package:ainaglam/widgets/message_bubble.dart';
import 'package:ainaglam/models/coworker_model.dart';
import 'package:ainaglam/screens/home/msg_screen.dart';

class ThreadScreen extends StatefulWidget {
  final Message message;
  final Coworker user;
  final String chatTitle;
  const ThreadScreen(
      {super.key,
      required this.message,
      required this.user,
      required this.chatTitle});

  @override
  _ThreadScreenState createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
  OverlayEntry? _overlayEntry;
  final ScrollController _scrollController = ScrollController();
  final QuillEditorController _controller = QuillEditorController();
  ChatProvider threadProvider = ChatProvider();
  Message? parentMessage;
  Coworker? userData;
  String? title;

  File? _selectedFile; // For mobile
  Uint8List? _selectedFileBytes; // For web

  bool _isAtBottom = true;
  bool _isUserScrolling = false;

  @override
  void initState() {
    super.initState();
    parentMessage = widget.message;
    userData = widget.user;
    title = widget.chatTitle;

    threadProvider = Provider.of<ChatProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await threadProvider.fetchThreadMessages(parentMessage!.id);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _scrollToBottom();
      }
    });
    threadProvider.connect();
  }

  @override
  void dispose() {
    _removeReactionPanel();
    _scrollController.dispose();
    _controller.dispose();
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
                          threadProvider.deleteThreadMessage(
                              message, userData!, parentMessage!.channel);
                        } else if (parentMessage!.channel == '') {
                          threadProvider.deleteThreadMessage(
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

  void _scrollToBottom({bool animate = true}) {
    if (animate) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  void _onScroll() {
    // Check if the user has manually scrolled away from the bottom
    if (_scrollController.position.pixels <
        _scrollController.position.maxScrollExtent - 100) {
      setState(() {
        _isAtBottom = false; // User is not at the bottom
        _isUserScrolling = true; // User manually scrolled up
      });
    } else {
      setState(() {
        _isAtBottom = true; // User is at the bottom
        _isUserScrolling = false; // Reset scrolling flag
      });
    }
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
                      // Navigator.pop(context);
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                              workspaceId: parentMessage!.organisation,
                              channelId: parentMessage!.channel == ''
                                  ? parentMessage!.conversation
                                  : parentMessage!.channel,
                              isPrivateChat:
                                  parentMessage!.channel == '' ? true : false,
                              title: title!,
                              avatar: ''),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'スレッド',
                    style: TextStyle(fontSize: 19),
                  ),
                  const Spacer(),
                  Text(
                    '# ${parentMessage!.sender!.displayName}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            )),
          )),
      body: Column(
        children: [
          // Text(userData!.displayName),
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
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(child: Consumer<ChatProvider>(
                          builder: (context, threadProvider, _) {
                            if (threadProvider.isLoading) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (threadProvider.errorMessage != null) {
                              return Center(
                                  child: Text(threadProvider.errorMessage!));
                            }

                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (!_isUserScrolling) {
                                _scrollToBottom(animate: true);
                              }
                            });
                            return ListView.builder(
                              controller: _scrollController,
                              itemCount: threadProvider.threadMessages.length,
                              itemBuilder: (context, index) {
                                final message =
                                    threadProvider.threadMessages[index];
                                final GlobalKey key = GlobalKey();
                                return GestureDetector(
                                    key: key,
                                    onTap: () {
                                      if (threadProvider.currentMessageId !=
                                          message.id) {
                                        _showReactionPanel(
                                            context, key, message);
                                      }
                                    },
                                    child: ThreadMessage(
                                        message: message, user: userData!));
                              },
                            );
                          },
                        )),
                        _buildEditor()
                      ],
                    ),
                    if (!_isAtBottom)
                      Positioned(
                        bottom: 80,
                        right: 20,
                        child: FloatingActionButton(
                          onPressed: () {
                            _scrollToBottom(animate: true);
                          },
                          child: const Icon(Icons.arrow_downward),
                        ),
                      ),
                  ],
                )),
          ),
        ],
      ),
    );
  }

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
                  hintText: 'Message #${parentMessage!.sender!.displayName}',
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

  void _handleReaction(BuildContext context, ThreadMsg message, String emoji) {
    // final threadProvider = Provider.of<ThreadProvider>(context, listen: false);
    threadProvider.addReactForThread(message, parentMessage!, emoji, userData!);
    // Navigator.pop(context);
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
          await threadProvider.imageUploadByByte(_selectedFileBytes!, true);
        }
      } else {
        String? filePath = result.files.single.path;
        if (filePath != null) {
          setState(() {
            _selectedFile = File(filePath);
          });
          await threadProvider.imageUploadByFile(_selectedFile!, true);
        }
      }
    }

    if (threadProvider.uploadedImageName != null) {
      _selectedFile = null;
      _selectedFileBytes = null;
      await _insertImageIntoEditor(threadProvider.uploadedImageName!);
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
            await threadProvider.videoUploadByByte(_selectedFileBytes!, true);
          }
        } else {
          String? filePath = result.files.single.path;
          if (filePath != null) {
            setState(() {
              _selectedFile = File(filePath);
            });
            await threadProvider.videoUploadByFile(_selectedFile!, true);
          }
        }
      }
    }

    if (threadProvider.uploadedVideoName != null) {
      _selectedFile = null;
      _selectedFileBytes = null;
      await _insertVideoIntoEditor(threadProvider.uploadedVideoName!);
      debugPrint("upload success!!!");
    }
  }

  Future<void> _insertVideoIntoEditor(String filename) async {
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

    final newMsg = {"sender": userData!, "content": nextContent};
    threadProvider.sendThreadMessage(parentMessage!.id, userData!, newMsg);
    _scrollToBottom(animate: true);
    _controller.clear(); // Clear editor after sending
  }
}
