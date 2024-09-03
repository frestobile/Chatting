import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../models/message_model.dart';
import '../../widgets/message_input_widget.dart';

class ThreadScreen extends StatelessWidget {
  final Message parentMessage;

  const ThreadScreen({super.key, required this.parentMessage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thread')),
      body: Column(
        children: [
          ListTile(
            title: Text(parentMessage.content),
            subtitle: const Text('Thread'),
          ),
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, _) {
                return Column(
                  children: [
                    Expanded(
                        child: ListView.builder(
                      itemCount: chatProvider.threadMessages.length,
                      itemBuilder: (context, index) {
                        final message = chatProvider.threadMessages[index];
                        return ListTile(
                          title: Text(message.content),
                        );
                      },
                    )),
                    MessageInputWidget(
                      onSend: (content) {
                        chatProvider.replyToThread(parentMessage.id, content);
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
