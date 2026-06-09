import 'package:flutter/material.dart';

import '../../../providers/chat_provider.dart';
import 'chat_status.dart';

class ChatInput extends StatefulWidget {
  const ChatInput({
    super.key,
    required this.chat,
    required this.controller,
    required this.onSend,
    required this.onPickImages,
  });

  final ChatProvider chat;
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onPickImages;

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.chat,
      builder: (context, _) {
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
                        hintText: 'Nhập tin nhắn ...',
                      ),
                      onSubmitted: (_) {
                        if (widget.chat.isSendEnabled) widget.onSend();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),

                  if (widget.chat.isImageTab)
                    GestureDetector(
                      onTap: widget.onPickImages,
                      child: Image.asset(
                        'assets/ic_image.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                  const SizedBox(width: 12),

                  (!widget.chat.canStopStream)
                      ? GestureDetector(
                          onTap: widget.onSend,
                          child: Image.asset(
                            'assets/ic_send.png',
                            width: 42,
                            height: 42,
                          ),
                        )
                      : ChatStop(chat: widget.chat),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
