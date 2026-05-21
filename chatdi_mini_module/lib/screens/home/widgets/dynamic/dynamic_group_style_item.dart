import 'package:flutter/material.dart';

class DynamicGroupStyleItem extends StatelessWidget {
  const DynamicGroupStyleItem({super.key, required this.item, required this.width});

  final Map<String, dynamic> item;
  final double width;

  @override
  Widget build(BuildContext context) {
    final thumb = '${item['thumbnail'] ?? ''}';

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 1,
              child: thumb.isEmpty
                  ? Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image_not_supported_outlined),
                    )
                  : Image.network(
                      thumb,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image_outlined),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}