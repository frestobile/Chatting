import 'package:ainaglam/models/coworker_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:ainaglam/models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final Coworker user;
  final bool isThread;
  final VoidCallback onReply;

  const MessageBubble(
      {super.key,
      required this.message,
      required this.user,
      this.isThread = false,
      required this.onReply});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: message.type != 'date'
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                message.sender!.avatarUrl != ''
                    ? CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage(
                            '${dotenv.env['API_BASE_URL']}/static/avatar/${message.sender!.avatarUrl}'),
                      )
                    : CircleAvatar(
                        radius: 18,
                        backgroundImage: RegExp(r'^[a-z]$').hasMatch(
                                message.sender!.displayName[0].toLowerCase())
                            ? AssetImage(
                                'avatars/${message.sender!.displayName[0].toLowerCase()}.png')
                            : const AssetImage('avatars/default.png'),
                      ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            message.sender!.displayName,
                            style: const TextStyle(
                                fontSize: 14.0, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Text(
                            DateFormat('hh:mm a')
                                .format(DateTime.parse(message.createdAt)),
                            style: const TextStyle(
                                fontSize: 10.0, color: Colors.grey),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(5.0),
                        margin: const EdgeInsets.only(top: 5.0),
                        decoration: BoxDecoration(
                          color: message.sender != null &&
                                  message.sender!.id == user.id
                              ? Colors.grey[300]
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Html(data: message.content),
                      ),
                      if (message.reactions.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Row(
                            children: message.reactions.map((reaction) {
                              return GestureDetector(
                                onTap: () {
                                  if (reaction.reactedToBy[0].id == user.id) {}
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(5.0),
                                  margin: const EdgeInsets.only(right: 8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800],
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(reaction.emoji,
                                          style: const TextStyle(
                                              fontFamily: 'NotoColorEmoji',
                                              fontSize: 14)),
                                      const SizedBox(width: 8.0),
                                      Text(
                                        '${reaction.reactedToBy.length}',
                                        style: const TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.white60),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      if (message.threadReplies.isNotEmpty && !isThread)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: GestureDetector(
                            onTap: onReply,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: Colors.grey, width: 1)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                          message
                                              .threadReplies[
                                                  message.threadReplies.length -
                                                      1]
                                              .displayName,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[400])),
                                      const SizedBox(width: 8),
                                      Text('他${message.threadReplies.length}人',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[400])),
                                      const SizedBox(width: 10),
                                      Icon(Icons.chat_bubble_outline_rounded,
                                          color: Colors.grey[400]),
                                      Text('${message.threadRepliesCount}件',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[400])),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3.0),
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
    );
  }
}
