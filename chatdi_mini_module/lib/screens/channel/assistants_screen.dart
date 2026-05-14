import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/catalog_provider.dart';
import '../../providers/chat_launch_args.dart';
import '../chat/chat_screen.dart';

/// RN `assistants.tsx` equivalent — chỉ đọc `categories`.
class AssistantsScreen extends StatelessWidget {
  const AssistantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Assistants')),
      body: RefreshIndicator(
        onRefresh: () => catalog.ensureCategoriesLoaded(forceRefresh: true),
        child: catalog.categoriesLoading
            ? ListView(children: const [SizedBox(height: 120)])
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: catalog.categories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (ctx, index) {
                  final cat = catalog.categories[index];
                  final sug = cat.suggestionLines.take(8).toList();
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cat.name, style: Theme.of(context).textTheme.titleMedium),
                          if ((cat.description ?? '').trim().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(cat.description!, maxLines: 4, overflow: TextOverflow.ellipsis),
                          ],
                          if (sug.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: sug.map((line) {
                                return ActionChip(
                                  label: Text(line, overflow: TextOverflow.ellipsis),
                                  onPressed: () => ChatScreen.open(
                                    context,
                                    ChatLaunchArgs(
                                      topicCategory: cat,
                                      initialDraft: line,
                                      tabIndex: 0,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                          const SizedBox(height: 6),
                          TextButton.icon(
                            onPressed: () => ChatScreen.open(
                              context,
                              ChatLaunchArgs.assistantSuggestions(cat),
                            ),
                            icon: const Icon(Icons.chat_bubble_outline),
                            label: const Text('Mở trong Chat'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
