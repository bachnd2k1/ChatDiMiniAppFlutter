import 'package:flutter/material.dart';

import '../../../providers/chat_provider.dart';
import 'chat_message_bubble.dart';
import 'chat_streaming_bubble.dart';

class ChatMessageList extends StatefulWidget {
  const ChatMessageList({
    super.key,
    required this.chat,
    required this.scrollController,
  });

  final ChatProvider chat;
  final ScrollController scrollController;

  @override
  State<ChatMessageList> createState() => _ChatMessageListState();
}

class _ChatMessageListState extends State<ChatMessageList> {
  int _persistedCount = 0;
  bool _hasStreaming = false;

  @override
  void initState() {
    super.initState();
    _syncCounts();
    widget.chat.addListener(_onChatStructureChange);
  }

  @override
  void dispose() {
    widget.chat.removeListener(_onChatStructureChange);
    super.dispose();
  }

  void _syncCounts() {
    _persistedCount = widget.chat.persisted.length;
    _hasStreaming = widget.chat.streamingBubble != null;
  }

  void _onChatStructureChange() {
    final persistedCount = widget.chat.persisted.length;
    final hasStreaming = widget.chat.streamingBubble != null;
    if (persistedCount == _persistedCount && hasStreaming == _hasStreaming) {
      return;
    }
    setState(() {
      _persistedCount = persistedCount;
      _hasStreaming = hasStreaming;
    });
  }

  @override
  Widget build(BuildContext context) {
    final chat = widget.chat;
    final itemCount = _persistedCount + (_hasStreaming ? 1 : 0);

    return ListView.builder(
      controller: widget.scrollController,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index < _persistedCount) {
          final message = chat.persisted[index];
          return ChatMessageBubble(
            key: ValueKey(message.id),
            message: message,
          );
        }
        return ChatStreamingBubble(chat: chat);
      },
    );
  }
}
