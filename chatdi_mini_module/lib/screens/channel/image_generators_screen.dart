import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/catalog_provider.dart';
import '../../providers/chat_launch_args.dart';
import '../chat/chat_screen.dart';

class ImageGeneratorsScreen extends StatelessWidget {
  const ImageGeneratorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Image Generator')),
      body: RefreshIndicator(
        onRefresh: () => catalog.ensureImageGeneratorsLoaded(forceRefresh: true),
        child: Builder(
          builder: (ctx) {
            if (catalog.imageGeneratorsLoading && catalog.imageGenerators.isEmpty) {
              return ListView(children: const [SizedBox(height: 120)]);
            }

            final list = catalog.imageGenerators;
            if (list.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('Chưa có preset — vuốt xuống để làm mới')),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final g = list[i];
                return ListTile(
                  leading: const Icon(Icons.auto_fix_high_outlined),
                  title: Text(g.name),
                  subtitle: Text(g.prompt ?? '', maxLines: 3, overflow: TextOverflow.ellipsis),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      ChatScreen.open(context, ChatLaunchArgs.generatorPreset(g)),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
