import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:ainaglam/models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
      child: Align(
          alignment:
              message.isSelf ? Alignment.centerRight : Alignment.centerLeft,
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
                    color: message.isSelf ? Colors.blue : Colors.grey[300],
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Html(data: message.content),
                      // Show reactions if they exist
                      if (message.reactions.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: message.reactions.map((entry) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Text(
                                "${entry.emoji}: ${entry.reactedToBy.length}",
                                style: GoogleFonts.notoColorEmoji(fontSize: 12),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
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
