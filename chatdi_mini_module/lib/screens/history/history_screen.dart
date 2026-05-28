import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/database/conversation_entities.dart';
import '../../data/repositories/conversation_local_repository.dart';
import 'history_item.dart';

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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            children: [
              /// HEADER
              Row(
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
                    onTap: () async {
                      // action
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.delete_sweep_outlined,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// SEARCH
              TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: Colors.black12,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: Colors.black12,
                      width: 1.2,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Tìm trong tiêu đề / chủ đề…',
                ),
                onChanged: (v) => setState(() => _query = v),
              ),

              const SizedBox(height: 24),

              /// LIST
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _reload,
                  child: items.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 120),
                            Center(
                              child: Text(
                                'Chưa có hội thoại lưu cục bộ',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 14),
                          itemBuilder: (_, i) {
                            final c = items[i];

                            return Dismissible(
                              key: ValueKey(c.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 24),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              confirmDismiss: (_) async {
                                final ok = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Xóa hội thoại'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text('Huỷ'),
                                      ),
                                      FilledButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text('Xóa'),
                                      ),
                                    ],
                                  ),
                                );

                                return ok == true;
                              },
                              onDismissed: (_) async {
                                await context
                                    .read<ConversationLocalRepository>()
                                    .deleteConversation(c.id);

                                setState(() {});
                              },
                              child: HistoryItem(entity: c),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
