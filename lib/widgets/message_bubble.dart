import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:ainaglam/models/message_model.dart';
import 'package:ainaglam/models/coworker_model.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final Coworker user;

  const MessageBubble({super.key, required this.message, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
      child: Align(
          alignment: message.sender!.id == user.id
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Column(
            children: [
              if (message.type != 'date')
                Row(
                  // mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    message.sender!.avatarUrl != ''
                        ? CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(
                                '${dotenv.env['API_BASE_URL']}/static/avatar/${message.sender!.avatarUrl}'),
                          )
                        : CircleAvatar(
                            radius: 20,
                            backgroundImage: RegExp(r'^[a-z]$').hasMatch(
                                    message.sender!.displayName.toLowerCase())
                                ? AssetImage(
                                    'avatars/${message.sender!.displayName.toLowerCase()}.png')
                                : const AssetImage('avatars/default.png'),
                          ),
                    const SizedBox(width: 8.0),
                    Text(
                      message.sender!.displayName,
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
              if (message.type != 'date')
                Container(
                  margin: const EdgeInsets.only(top: 2.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: user.id == message.sender!.id
                        ? Colors.blue
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Html(data: message.content),
                  ),
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
                          padding: const EdgeInsets.all(6.0),
                          // margin: const EdgeInsets.only(right: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              Text(reaction.emoji,
                                  style:
                                      GoogleFonts.notoColorEmoji(fontSize: 14)),
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
              if (message.type == 'date')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
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
                            fontWeight:
                                FontWeight.w200, // Font weight of the text
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
                )
            ],
          )),
    );
  }
}
