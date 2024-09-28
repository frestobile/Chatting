import 'package:flutter/material.dart';

class EmojiReactionWidget extends StatelessWidget {
  final String emoji;
  final int count;
  final Function(String) onReact;

  const EmojiReactionWidget({
    super.key,
    required this.emoji,
    required this.count,
    required this.onReact,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onReact(emoji),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 4),
            Text(count.toString(), style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
