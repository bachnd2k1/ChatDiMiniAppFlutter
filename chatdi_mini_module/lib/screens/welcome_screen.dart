import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_router.dart';
import '../providers/app_config_provider.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bullets = [
      'Kết nối realtime qua SSE trước khi có thể gửi tin (giống bản RN).',
      'Lịch sử được lưu cục bộ bằng Hive — không có HTTP riêng cho History.',
      'Thư mục instruction/ mô tả kiến trúc; docs/ chứa hợp đồng API.',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Chào bạn')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sẵn sàng dùng ChatDI?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ...bullets.map(
              (b) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text(b)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: () async {
              await context.read<AppConfigProvider>().setWelcomeDone();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed(AppRoutes.main);
              }
            },
            child: const Text('Bắt đầu'),
          ),
        ),
      ),
    );
  }
}
