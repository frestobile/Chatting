import 'package:ainaglam/models/coworker_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:ainaglam/models/threadmsg_model.dart';

class ThreadMessage extends StatelessWidget {
  final ThreadMsg message;
  final Coworker user;

  const ThreadMessage({super.key, required this.message, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            message.sender.avatarUrl != ''
                ? CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(
                        '${dotenv.env['API_BASE_URL']}/static/avatar/${message.sender.avatarUrl}'),
                  )
                : CircleAvatar(
                    radius: 20,
                    backgroundImage: RegExp(r'^[a-z]$').hasMatch(
                            message.sender.displayName[0].toLowerCase())
                        ? AssetImage(
                            'avatars/${message.sender.displayName[0].toLowerCase()}.png')
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
                      message.sender.displayName,
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
                Container(
                  padding: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    color: message.sender.id == user.id
                        ? Colors.blue
                        : Colors.grey[300],
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
                                      fontSize: 14.0, color: Colors.white60),
                                )
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            )),
          ],
        ));
  }
}
