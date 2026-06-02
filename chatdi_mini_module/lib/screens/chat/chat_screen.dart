import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/catalog_repository.dart';
import '../../data/repositories/chat_api_repository.dart';
import '../../data/repositories/conversation_local_repository.dart';
import '../../data/services/chat_image_storage.dart';
import '../../providers/chat_launch_args.dart';
import '../../providers/chat_provider.dart';
import '../../providers/session_provider.dart';
import '../../widgets/chat_sse_image_body.dart';

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
    chat.removeListener(_onChatTick);
    chat.addListener(_onChatTick);
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

  void _onChatTick() {
    final chat = _chat;
    if (chat == null) {
      setState(() {});
      return;
    }
    final count = chat.visibleMessages.length;
    final streaming = chat.streamingBubble != null;
    final grew = count > _lastVisibleCount;
    _lastVisibleCount = count;
    setState(() {});
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
      c.removeListener(_onChatTick);
      c.unmount();
    }
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chat = _chat;
    final session = context.watch<SessionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          if (chat != null && chat.canStopStream)
            IconButton(
              onPressed: chat.stopGeneration,
              icon: const Icon(Icons.stop_circle_outlined),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                session.isConnected && (session.sessionId?.isNotEmpty ?? false)
                    ? 'SSE: connected'
                    : 'SSE: waiting…',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ),
      ),
      body: chat == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Ask'),
                        selected: !chat.imageTab,
                        onSelected: (_) => chat.setTabAsk(),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Image'),
                        selected: chat.imageTab,
                        onSelected:
                            chat.character == null ? (_) => chat.setTabImage() : null,
                      ),
                      const Spacer(),
                      PopupMenuButton<String>(
                        onSelected: (id) {
                          if (id == '__clear') {
                            chat.selectStyle(null);
                            return;
                          }
                          final style = chat.imageStyles.firstWhere(
                            (s) => s.id == id,
                          );
                          chat.selectStyle(style);
                        },
                        itemBuilder: (ctx) => [
                          const PopupMenuItem<String>(
                            value: '__clear',
                            child: Text('Không áp style'),
                          ),
                          ...chat.imageStyles.map(
                            (s) => PopupMenuItem<String>(
                              value: s.id,
                              child: Text(s.name),
                            ),
                          ),
                        ],
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.palette_outlined,
                                size: 18,
                                color: chat.imageTab ? null : Theme.of(context).disabledColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                chat.selectedStyle?.name ?? 'Style',
                                style: TextStyle(
                                  color: chat.imageTab ? null : Theme.of(context).disabledColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: chat.visibleMessages.length,
                    itemBuilder: (ctx, i) {
                      final m = chat.visibleMessages[i];
                      final align = m.isUser ? Alignment.centerRight : Alignment.centerLeft;
                      final color = m.isUser
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surfaceContainerHighest;
                      return Align(
                        alignment: align,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Card(
                            color: color,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (m.content.isNotEmpty) Text(m.content),
                                  if (m.imageUrl != null && m.imageUrl!.isNotEmpty)
                                    Padding(
                                      padding: EdgeInsets.only(top: m.content.isNotEmpty ? 8 : 0),
                                      child: chatSseImageBody(m.imageUrl),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            minLines: 1,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              hintText: 'Nhập tin nhắn…',
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (_) => _send(chat),
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed: chat.sendEnabled ? () => _send(chat) : null,
                          child: chat.isSending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.send),
                        ),
                      ],
                    ),
                  ),
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
      setState(() {});
      _scrollToBottom(ensureExtent: true);
    }
  }
}
