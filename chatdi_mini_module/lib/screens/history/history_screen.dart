import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/conversation_local_repository.dart';
import '../../providers/history_provider.dart';
import 'history_screen_widgets.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HistoryProvider>(
      create: (context) => HistoryProvider(
        context.read<ConversationLocalRepository>(),
      ),
      child: Builder(
        builder: (context) {
          final provider = context.watch<HistoryProvider>();
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  children: [
                    HistoryHeader(
                      onClearAllTap: () => _confirmClearAll(context),
                    ),
                    const SizedBox(height: 20),
                    HistorySearchField(onChanged: provider.updateQuery),
                    const SizedBox(height: 24),
                    Expanded(
                      child: HistoryList(
                        items: provider.items,
                        provider: provider,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmClearAll(BuildContext context) async {
    final provider = context.read<HistoryProvider>();
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa toàn bộ lịch sử'),
        content: const Text('Hành động này sẽ xóa tất cả hội thoại đã lưu.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Xóa hết'),
          ),
        ],
      ),
    );

    if (shouldClear == true) {
      await provider.clearAll();
    }
  }
}
