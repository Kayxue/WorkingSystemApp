import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:working_system_app/Pages/Chatting/ConversationList.dart';

class MessageButton extends StatelessWidget {
  final int? unreadMessages;
  final String sessionKey;
  final Function() refetchUnread;

  const MessageButton({
    super.key,
    required this.sessionKey,
    this.unreadMessages,
    required this.refetchUnread,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: unreadMessages != null && unreadMessages! > 0
          ? badges.Badge(
              badgeContent: Text(
                unreadMessages.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 8),
              ),
              badgeStyle: const badges.BadgeStyle(badgeColor: Colors.blue),
              child: const Icon(Icons.message),
            )
          : const Icon(Icons.message),
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ConversationList(sessionKey: sessionKey),
          ),
        );
        refetchUnread();
      },
    );
  }
}
