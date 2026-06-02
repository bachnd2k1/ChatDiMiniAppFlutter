import 'package:flutter/material.dart';

import '../../../providers/chat_provider.dart';
import 'chat_header.dart';


class ChatInput extends StatefulWidget {
  const ChatInput({
    super.key,
    required this.chat,
    required this.controller,
    required this.onSend,
  });

  final ChatProvider chat;
  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  bool _sendEnabled = false;
  bool _isSending = false;
  bool _canStopStream = false;

  @override
  void initState() {
    super.initState();
    _syncFromChat();
    widget.chat.addListener(_onSendStateChange);
  }

  @override
  void dispose() {
    widget.chat.removeListener(_onSendStateChange);
    super.dispose();
  }

  void _syncFromChat() {
    _sendEnabled = widget.chat.sendEnabled;
    _isSending = widget.chat.isSending;
    _canStopStream = widget.chat.canStopStream;
  }

  void _onSendStateChange() {
    final sendEnabled = widget.chat.sendEnabled;
    final isSending = widget.chat.isSending;
    final canStopStream = widget.chat.canStopStream;
    if (sendEnabled == _sendEnabled && isSending == _isSending && canStopStream == _canStopStream) return;
    setState(() {
      _sendEnabled = sendEnabled;
      _isSending = isSending;
      _canStopStream = canStopStream;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(
                        color: Colors.black12,
                        width: 1.2,
                      ),
                    ),
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Nhập tin nhắn ...',
                  ),
                  onSubmitted: (_) {
                    if (_sendEnabled) widget.onSend();
                  },
                ),
              ),
              const SizedBox(width: 12),

              (!_canStopStream) ?
              GestureDetector(
                onTap: widget.onSend,
                child: Image.asset('assets/ic_send.png', width: 48, height: 48),
              ) :
              ChatStopAction(chat: widget.chat),
            ],
          ),
        ),
      ),
    );
  }
}
