import 'package:flutter/material.dart';

/// Docs: nút gửi chưa có API backend.
class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gửi báo cáo vấn đề',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const TextField(
              minLines: 4,
              maxLines: 8,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Mô tả chi tiết',
              ),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chưa nối API — xem docs/02 (màn Report trong đặc tả).'),
                  ),
                );
              },
              icon: const Icon(Icons.send_outlined),
              label: const Text('Gửi'),
            ),
          ],
        ),
      ),
    );
  }
}
