import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/catalog_repository.dart';
import '../../data/repositories/chat_api_repository.dart';
import '../../data/repositories/conversation_local_repository.dart';
import '../../data/services/chat_image_storage.dart';
import '../../providers/chat_launch_args.dart';
import '../../providers/chat_provider.dart';
import '../../providers/session_provider.dart';
import 'widgets/chat_header.dart';
import 'widgets/chat_input.dart';
import 'widgets/chat_message_list.dart';
import 'widgets/chat_style_selector.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.args});

  final ChatLaunchArgs args;

  static Future<void> open(BuildContext context, ChatLaunchArgs args) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => ChatScreen(args: args)),
    );
  }

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final TextEditingController _controller;
  final ScrollController _scrollController = ScrollController();
  ChatProvider? _chat;
  int _lastVisibleCount = 0;

  void _bind(ChatProvider chat) {
    chat.removeListener(_onChatScrollTick);
    chat.addListener(_onChatScrollTick);
  }

  void _scrollToBottom({bool animated = false, bool ensureExtent = false}) {
    void scrollOnce() {
      if (!mounted || !_scrollController.hasClients) return;
      final max = _scrollController.position.maxScrollExtent;
      if (animated) {
        _scrollController.animateTo(
          max,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(max);
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollOnce();
      if (ensureExtent) {
        WidgetsBinding.instance.addPostFrameCallback((_) => scrollOnce());
      }
    });
  }

  /// Chỉ auto-scroll; không setState — tránh rebuild cả màn khi SSE delta.
  void _onChatScrollTick() {
    final chat = _chat;
    if (chat == null) return;

    final count = chat.visibleMessages.length;
    final streaming = chat.streamingBubble != null;
    final grew = count > _lastVisibleCount;
    _lastVisibleCount = count;

    if (streaming) {
      _scrollToBottom();
    } else if (grew) {
      _scrollToBottom(ensureExtent: count > 1);
    }
  }

  @override
  void initState() {
    super.initState();
    final seed = widget.args.initialDraft ??
        widget.args.promptFromGenerator ??
        '';
    _controller = TextEditingController(text: seed);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final chat = ChatProvider(
        context.read<ChatApiRepository>(),
        context.read<ConversationLocalRepository>(),
        context.read<CatalogRepository>(),
        ChatImageStorage(),
      );
      _bind(chat);
      _chat = chat;
      await chat.mount(widget.args, context.read<SessionProvider>());
      if (mounted) {
        _lastVisibleCount = chat.visibleMessages.length;
        setState(() {});
        if (_lastVisibleCount > 0) {
          _scrollToBottom(ensureExtent: true);
        }
      }
    });
  }

  @override
  void dispose() {
    final c = _chat;
    if (c != null) {
      c.removeListener(_onChatScrollTick);
      c.unmount();
    }
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chat = _chat;

    return Scaffold(
      appBar: chat == null
          ? null
          : ChatHeader(chat: chat),
      body: chat == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                ChatStyleSelector(chat: chat),
                Expanded(
                  child: ChatMessageList(
                    chat: chat,
                    scrollController: _scrollController,
                  ),
                ),
                ChatInput(
                  chat: chat,
                  controller: _controller,
                  onSend: () => _send(chat),
                ),
              ],
            ),
    );
  }

  Future<void> _send(ChatProvider chat) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    await chat.sendUserMessage(text);
    if (mounted) {
      _controller.clear();
      _scrollToBottom(ensureExtent: true);
    }
  }
}
