import 'package:flutter/material.dart';

import '../../core/database/conversation_entities.dart';
import '../../providers/chat_launch_args.dart';
import '../../providers/history_provider.dart';
import '../chat/chat_screen.dart';
import 'history_item.dart';

class HistoryHeader extends StatelessWidget {
  const HistoryHeader({super.key, required this.onClearAllTap});

  final VoidCallback onClearAllTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 44),
        const Expanded(
          child: Center(
            child: Text(
              'History',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: onClearAllTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.delete_sweep_outlined, color: Colors.black),
          ),
        ),
      ],
    );
  }
}

class HistorySearchField extends StatelessWidget {
  const HistorySearchField({super.key, required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
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
          borderSide: const BorderSide(color: Colors.black12, width: 1.2),
        ),
        prefixIcon: const Icon(Icons.search),
        hintText: 'Tìm trong tiêu đề / chủ đề...',
      ),
      onChanged: onChanged,
    );
  }
}

class HistoryList extends StatelessWidget {
  const HistoryList({super.key, required this.items, required this.provider});

  final List<ConversationEntity> items;
  final HistoryProvider provider;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'No data found',
          style: TextStyle(color: Colors.black54, fontSize: 15),
        ),
      );
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (_, i) {
        final conversation = items[i];
        return Dismissible(
          key: ValueKey(conversation.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (_) => _showDeleteConversationDialog(context),
          onDismissed: (_) async {
            await provider.deleteConversation(conversation.id);
          },
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => ChatScreen.open(
              context,
              ChatLaunchArgs.historyThread(conversation.id),
            ),
            child: HistoryItem(
              entity: conversation,
              previewText: provider.lastMessagePreview(conversation),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _showDeleteConversationDialog(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa hội thoại'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    return shouldDelete == true;
  }
}
