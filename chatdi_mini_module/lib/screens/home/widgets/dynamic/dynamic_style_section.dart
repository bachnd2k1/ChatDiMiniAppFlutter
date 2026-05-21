import 'package:flutter/material.dart';

import 'dynamic_group_style_item.dart';
import 'image_generator_button.dart';

class HomeDynamicStyleSection extends StatelessWidget {
  final List<Map<String, dynamic>> groupedStyles;
  final bool isLoading;
  final String? error;
  final VoidCallback? onTapGenerator;

  const HomeDynamicStyleSection({
    super.key,
    required this.groupedStyles,
    required this.isLoading,
    this.error,
    this.onTapGenerator,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && groupedStyles.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: LinearProgressIndicator(),
      );
    }

    if (error != null || groupedStyles.isEmpty) {
      return const SizedBox.shrink();
    }

    final allStylish = _allStylish(groupedStyles);
    final dataFirst = allStylish.skip(2).take(4).toList();
    final dataSecond = allStylish.skip(7).take(5).toList();
    if (dataFirst.isEmpty && dataSecond.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_buildRow(dataFirst), _buildRow(dataSecond)],
            ),
          ),
          ImageGeneratorButton(onTap: onTapGenerator),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _allStylish(List<Map<String, dynamic>> groups) {
    return groups
        .take(5)
        .expand((group) {
          final stylish = group['stylish'];
          if (stylish is! List) return const <Map<String, dynamic>>[];
          return stylish.whereType<Map<String, dynamic>>();
        })
        .where((item) {
          final thumbnail = '${item['thumbnail'] ?? ''}'.toLowerCase();
          return !thumbnail.endsWith('.webm');
        })
        .toList();
  }

  Widget _buildRow(List<Map<String, dynamic>> rowData) {
    if (rowData.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: rowData.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) =>
            DynamicGroupStyleItem(item: rowData[index], width: 110),
      ),
    );
  }
}
