import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/catalog_provider.dart';
import '../../providers/chat_launch_args.dart';
import '../chat/chat_screen.dart';

class CharactersScreen extends StatelessWidget {
  const CharactersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Characters')),
      body: RefreshIndicator(
        onRefresh: () => catalog.ensureCharactersLoaded(forceRefresh: true),
        child: Builder(
          builder: (ctx) {
            if (catalog.charactersLoading && catalog.characters.isEmpty) {
              return ListView(children: const [SizedBox(height: 120)]);
            }

            final list = catalog.characters;
            if (list.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('Chưa tải nhân vật — vuốt để làm mới')),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final ch = list[i];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(ch.name),
                  subtitle:
                      Text(ch.description ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                  onTap: () => ChatScreen.open(context, ChatLaunchArgs.characterChat(ch)),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
