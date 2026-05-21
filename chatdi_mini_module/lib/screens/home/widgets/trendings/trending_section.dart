import 'package:flutter/material.dart';

import 'trending_item.dart';

class TrendingSection extends StatelessWidget {
  const TrendingSection({super.key, required this.trendings});

  final List<String> trendings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trending Prompt',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: .all(16),
            decoration: BoxDecoration(
              borderRadius: .circular(16),
              border: Border.all(color: Color(0xFF0AC198), width: 1),
            ),
            child: ListView.separated(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: trendings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, index) =>
                  TrendingItem(prompt: trendings[index]),
            ),
          ),
        ],
      ),
    );
  }
}
