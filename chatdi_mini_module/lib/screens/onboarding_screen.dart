import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_router.dart';
import '../providers/app_config_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      ('Chào mừng ChatDI', 'Trò chuyện với trợ lý AI và tạo hình ảnh chỉ trong vài giây.'),
      ('Đa chủ đề', 'Chọn trợ lý theo lĩnh vực, hoặc trò chuyện qua các nhân vật được thiết kế sẵn.'),
      ('Luồng realtime', 'Kết quả được stream qua SSE giống bản RN; header `x-device-id` và `x-session-id` được gắn khi POST message.'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Onboarding')),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: pages.length,
              itemBuilder: (ctx, index) => Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 48),
                    Text(
                      pages[index].$1,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      pages[index].$2,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                TextButton(
                  onPressed: () async {
                    await context.read<AppConfigProvider>().setOnboardingDone();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed(AppRoutes.welcome);
                    }
                  },
                  child: const Text('Bỏ qua'),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () async {
                    final current = (_controller.page ?? 0).round();
                    final last = current >= pages.length - 1;
                    if (last) {
                      await context.read<AppConfigProvider>().setOnboardingDone();
                      if (context.mounted) {
                        Navigator.of(context).pushReplacementNamed(AppRoutes.welcome);
                      }
                    } else {
                      await _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                  child: const Text('Tiếp tục'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
