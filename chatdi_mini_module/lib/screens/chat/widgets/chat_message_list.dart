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
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _syncCounts();
    widget.chat.addListener(_onChatStructureChange);
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.chat.removeListener(_onChatStructureChange);
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _syncCounts() {
    _persistedCount = widget.chat.persisted.length;
    _hasStreaming = widget.chat.streamingBubble != null;
    _isLoadingMore = widget.chat.isLoadingMore;
  }

  void _onChatStructureChange() {
    final persistedCount = widget.chat.persisted.length;
    final hasStreaming = widget.chat.streamingBubble != null;
    final isLoadingMore = widget.chat.isLoadingMore;
    if (persistedCount == _persistedCount && hasStreaming == _hasStreaming && isLoadingMore == _isLoadingMore) {
      return;
    }
    setState(() {
      _persistedCount = persistedCount;
      _hasStreaming = hasStreaming;
      _isLoadingMore = isLoadingMore;
    });
  }

  void _onScroll() async {
    // when user scrolls near top, try loading more
    try {
      if (!widget.scrollController.hasClients) return;
      final offset = widget.scrollController.offset;
      if (offset <= 120 && widget.chat.hasMoreMessages && !widget.chat.isLoadingMore) {
        final oldOffset = widget.scrollController.offset;
        // cancel any ongoing fling/scroll by jumping to current offset
        if (widget.scrollController.hasClients) {
          widget.scrollController.jumpTo(oldOffset);
        }
        final loaded = await widget.chat.loadMoreMessages();
        if (loaded > 0) {
          // crude estimate to preserve visible position: assume avg item height
          const avgHeight = 72.0;
          final added = loaded * avgHeight;
          final newPos = oldOffset + added;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && widget.scrollController.hasClients) {
              widget.scrollController.jumpTo(newPos);
            }
          });
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final chat = widget.chat;
    final extraTop = _isLoadingMore ? 1 : 0;
    final itemCount = extraTop + _persistedCount + (_hasStreaming ? 1 : 0);

    return Stack(
      children: [
        ListView.builder(
          controller: widget.scrollController,
          physics: _isLoadingMore ? const NeverScrollableScrollPhysics() : null,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            // top loading placeholder
            if (extraTop == 1 && index == 0) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  ),
                ),
              );
            }

            final msgIndex = index - extraTop;
            if (msgIndex < _persistedCount) {
              final message = chat.persisted[msgIndex];
              return ChatMessageBubble(
                key: ValueKey(message.id),
                message: message,
              );
            }

            // streaming bubble (always at the end)
            return ChatStreamingBubble(chat: chat);
          },
        ),
        // keep overlay indicator as fallback for quick visibility
        if (_isLoadingMore)
          Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
