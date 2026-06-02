import 'package:flutter/material.dart';

import '../../../data/models/ui_chat_message.dart';
import '../../../widgets/chat_sse_image_body.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({super.key, required this.message});

  final UiChatMessage message;

  @override
  Widget build(BuildContext context) {
    final color = message.isUser
        ? Theme.of(context).colorScheme.primaryContainer
        : Theme.of(context).colorScheme.surfaceContainerHighest;

    final bubble = ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.8,
      ),
      child: Card(
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.content.isNotEmpty)
                Text(message.content),

              if (message.imageUrl != null &&
                  message.imageUrl!.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(
                    top: message.content.isNotEmpty ? 8 : 0,
                  ),
                  child: chatSseImageBody(message.imageUrl),
                ),
            ],
          ),
        ),
      ),
    );

    // User message
    if (message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: bubble,
      );
    }

    // Bot message
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipOval(
            child: Image.asset(
              'assets/ic_chatdi.png',
              width: 32,
              height: 32,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 8),
          bubble,
        ],
      ),
    );
  }
}
