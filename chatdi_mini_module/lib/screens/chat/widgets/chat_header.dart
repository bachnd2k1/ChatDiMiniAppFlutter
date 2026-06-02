import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/chat_provider.dart';
import '../../../providers/session_provider.dart';

class ChatHeader extends StatelessWidget implements PreferredSizeWidget {
  const ChatHeader({super.key, required this.chat});

  final ChatProvider chat;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 40);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Chat'),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: _ChatSseStatus(),
          ),
        ),
      ),
    );
  }
}

class ChatStopAction extends StatefulWidget {
  const ChatStopAction({super.key, required this.chat});

  final ChatProvider chat;

  @override
  State<ChatStopAction> createState() => _ChatStopActionState();
}

class _ChatStopActionState extends State<ChatStopAction> {
  bool _canStop = false;

  @override
  void initState() {
    super.initState();
    _canStop = widget.chat.canStopStream;
    widget.chat.addListener(_onChatChange);
  }

  @override
  void dispose() {
    widget.chat.removeListener(_onChatChange);
    super.dispose();
  }

  void _onChatChange() {
    final canStop = widget.chat.canStopStream;
    if (canStop == _canStop) return;
    setState(() => _canStop = canStop);
  }

  @override
  Widget build(BuildContext context) {
    if (!_canStop) return const SizedBox.shrink();
    return IconButton(
      onPressed: widget.chat.stopGeneration,
      icon: const Icon(Icons.stop_circle_outlined),
    );
  }
}

class _ChatSseStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final connected =
        session.isConnected && (session.sessionId?.isNotEmpty ?? false);

    return Text(
      connected ? 'SSE: connected' : 'SSE: waiting…',
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}
