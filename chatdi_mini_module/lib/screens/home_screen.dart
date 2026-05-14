import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_router.dart';
import '../data/models/category.dart';
import '../data/models/image_generator.dart';
import '../mini_app_integration.dart';
import '../providers/catalog_provider.dart';
import '../providers/chat_launch_args.dart';
import 'chat/chat_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: chatDiMiniAppEmbeddedInNativeHost
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Đóng',
                onPressed: () => requestChatDiMiniAppHostClose(),
              )
            : null,
        automaticallyImplyLeading: !chatDiMiniAppEmbeddedInNativeHost,
        title: const Text('ChatDI'),
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => catalog.ensureCategoriesLoaded(forceRefresh: true),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nhập prompt nhanh',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      spacing: 8,
                      children: [
                        FilledButton.tonal(
                          onPressed: () => ChatScreen.open(
                            context,
                            ChatLaunchArgs.topicPrompt(
                              'Một chú chó và một con mèo',
                            ),
                          ),
                          child: const Text('Trending ví dụ → Chat Ask'),
                        ),
                        FilledButton.tonal(
                          onPressed: () => ChatScreen.open(
                            context,
                            ChatLaunchArgs.imagePrompt(
                              'Mountain landscape sunrise',
                            ),
                          ),
                          child: const Text('Trending ví dụ → Tab Image'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            _section(context, catalog),
            _characterStrip(context),
            _generatorStrip(context),
          ],
        ),
      ),
    );
  }

  Widget _section(BuildContext context, CatalogProvider catalog) {
    if (catalog.categoriesLoading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final items = catalog.categories;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'Assistants',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (ctx, i) =>
                SizedBox(width: 220, child: _AssistantCard(category: items[i])),
          ),
        ),
      ],
    );
  }

  Widget _characterStrip(BuildContext context) {
    return Consumer<CatalogProvider>(
      builder: (ctx, catalog, _) {
        final chars = catalog.characters;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 8),
              child: Text(
                'Characters',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (catalog.charactersLoading)
              const LinearProgressIndicator()
            else if (chars.isEmpty)
              const Text('Đang không có nhân vật — vuốt xuống để prefetch.')
            else
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: chars.take(12).length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (ctx, i) {
                    final c = chars[i];
                    return ActionChip(
                      avatar: const Icon(Icons.person_outline, size: 18),
                      label: Text(c.name, overflow: TextOverflow.ellipsis),
                      onPressed: () => ChatScreen.open(
                        context,
                        ChatLaunchArgs.characterChat(c),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _generatorStrip(BuildContext context) {
    return Consumer<CatalogProvider>(
      builder: (ctx, catalog, _) {
        final gens = catalog.imageGenerators;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 8),
              child: Text(
                'Image presets',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (catalog.imageGeneratorsLoading)
              const LinearProgressIndicator()
            else if (gens.isEmpty)
              const Text(
                'Đang chờ prefetch Preset — mở tab Image Generator một lần.',
              )
            else
              ...gens
                  .take(4)
                  .map(
                    (ImageGeneratorModel g) => ListTile(
                      leading: const Icon(Icons.auto_fix_high_outlined),
                      title: Text(g.name),
                      subtitle: Text(
                        g.prompt ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => ChatScreen.open(
                        context,
                        ChatLaunchArgs.generatorPreset(g),
                      ),
                    ),
                  ),
          ],
        );
      },
    );
  }
}

class _AssistantCard extends StatelessWidget {
  const _AssistantCard({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                category.description ?? category.suggestion ?? '',
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              color: Colors.red,
              child: TextButton(
                onPressed: () => ChatScreen.open(
                  context,
                  ChatLaunchArgs.assistantSuggestions(category),
                ),
                child: const Text('Mở trò chuyện'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
