import 'package:flutter/material.dart';

import '../../../../data/models/category.dart';
import '../../../chat/chat_screen.dart';
import '../../../../providers/chat_launch_args.dart';

class HomeAssistantSection extends StatelessWidget {
  final List<Category> categories;

  const HomeAssistantSection({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(
            children: [
              Text(
                'Assistants',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              Spacer(),
              Text(
                'See All',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, index) => SizedBox(
                width: 60,
                child: _AssistantCard(category: categories[index]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AssistantCard extends StatelessWidget {
  const _AssistantCard({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        ChatScreen.open(context, ChatLaunchArgs.assistantSuggestions(category));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
            ),
            alignment: Alignment.center,
            child: Text(
              category.icon ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            category.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
