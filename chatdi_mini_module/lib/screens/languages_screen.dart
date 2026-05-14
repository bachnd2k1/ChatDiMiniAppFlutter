import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/network/api_client.dart';
import '../providers/app_config_provider.dart';

class LanguagesScreen extends StatelessWidget {
  const LanguagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cfg = context.watch<AppConfigProvider>();
    const options = ['en', 'vi'];

    return Scaffold(
      appBar: AppBar(title: const Text('Languages')),
      body: Column(
        children: [
          for (final code in options)
            ListTile(
              title: Text(code == 'vi' ? 'Tiếng Việt' : 'English'),
              trailing: cfg.languageCode == code ? const Icon(Icons.check) : null,
              onTap: () async {
                await cfg.setLanguageCode(code);
                if (!context.mounted) return;
                context.read<ApiClient>().setAcceptLanguage(code);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }
}
