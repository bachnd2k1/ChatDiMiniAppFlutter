import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/database/conversation_entities.dart';
import '../data/repositories/conversation_local_repository.dart';
import '../providers/chat_launch_args.dart';
import 'chat/chat_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _query = '';
  ConversationLocalRepository? _repoCache;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _repoCache ??= context.read<ConversationLocalRepository>();
  }

  List<ConversationEntity> _filtered() {
    final repo = _repoCache!;
    return repo.search(_query);
  }

  Future<void> _reload() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered();

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            onPressed: () async {
              final repo = context.read<ConversationLocalRepository>();
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Xóa toàn bộ lịch sử'),
                  content: const Text('Thao tác này không thể hoàn tác.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Huỷ')),
                    FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xóa')),
                  ],
                ),
              );
              if (ok != true) return;
              await repo.clearAll();
              if (!mounted) return;
              setState(() {});
            },
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
                hintText: 'Tìm trong tiêu đề / chủ đề…',
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _reload,
              child: items.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 96),
                        Center(child: Text('Chưa có hội thoại lưu cục bộ')),
                      ],
                    )
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final c = items[i];
                        return Dismissible(
                          key: ValueKey(c.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (_) async {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Xóa hội thoại'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Huỷ')),
                                  FilledButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Xóa'),
                                  ),
                                ],
                              ),
                            );
                            return ok == true;
                          },
                          onDismissed: (_) async {
                            await context.read<ConversationLocalRepository>().deleteConversation(c.id);
                            setState(() {});
                          },
                          child: ListTile(
                            title: Text(c.title ?? '(Không có tiêu đề)'),
                            subtitle: Text(c.lastMessage ?? ''),
                            trailing: Text('${c.messageCount} msgs'),
                            onTap: () => ChatScreen.open(
                              context,
                              ChatLaunchArgs.historyThread(c.id),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
