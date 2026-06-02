import 'package:flutter/material.dart';

import '../../../providers/chat_provider.dart';
import 'chat_message_bubble.dart';

/// Chỉ bubble đang stream lắng nghe [ChatProvider]; persisted bubbles không rebuild theo delta.
class ChatStreamingBubble extends StatelessWidget {
  const ChatStreamingBubble({super.key, required this.chat});

  final ChatProvider chat;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: chat,
      builder: (context, _) {
        final bubble = chat.streamingBubble;
        if (bubble == null) return const SizedBox.shrink();
        return ChatMessageBubble(key: ValueKey(bubble.id), message: bubble);
      },
    );
  }
}
