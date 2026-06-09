import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/chat_provider.dart';
import '../../../providers/session_provider.dart';

class ChatStop extends StatefulWidget {
  const ChatStop({super.key, required this.chat});

  final ChatProvider chat;

  @override
  State<ChatStop> createState() => _ChatStopState();
}

class _ChatStopState extends State<ChatStop> {
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

class ChatSseStatus extends StatelessWidget {
  const ChatSseStatus({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final connected =
        session.isConnected && (session.sessionId?.isNotEmpty ?? false);

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: connected ? Colors.green : Colors.red,
        shape: BoxShape.circle,
      ),
    );
  }
}
