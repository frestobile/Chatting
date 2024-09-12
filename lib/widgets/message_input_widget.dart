import 'package:flutter/material.dart';

class MessageInputWidget extends StatefulWidget {
  final Function(String) onSend;

  const MessageInputWidget({super.key, required this.onSend});

  @override
  _MessageInputWidgetState createState() => _MessageInputWidgetState();
}

class _MessageInputWidgetState extends State<MessageInputWidget> {
  final TextEditingController _controller = TextEditingController();
  bool _isComposing = false;

  void _handleSubmitted(String text) {
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
    setState(() {
      _isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
              ),
              onChanged: (text) {
                setState(() {
                  _isComposing = text.isNotEmpty;
                });
              },
              onSubmitted: _handleSubmitted,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            color: _isComposing ? Theme.of(context).primaryColor : Colors.grey,
            onPressed:
                _isComposing ? () => _handleSubmitted(_controller.text) : null,
          ),
        ],
      ),
    );
  }
}
