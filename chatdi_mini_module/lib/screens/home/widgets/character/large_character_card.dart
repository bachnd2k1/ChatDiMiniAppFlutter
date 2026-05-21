import 'package:flutter/material.dart';

import '../../../../data/models/character.dart';
import 'character_card_container.dart';

class LargeCharacterCard extends StatelessWidget {
  const LargeCharacterCard({
    super.key,
    required this.item,
    this.onTap,
  });

  final CharacterModel item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return CharacterCardContainer(
      padding: EdgeInsets.zero,
      borderRadius: 16,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: _CharacterImage(
                    url: item.picture,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description ?? item.question ?? '',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black.withValues(alpha: 0.55),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CharacterImage extends StatelessWidget {
  const _CharacterImage({
    required this.url,
    required this.fit,
  });

  final String? url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final imageUrl = url;
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: double.infinity,
        color: Colors.grey.shade200,
        child: const Icon(Icons.person_outline, size: 48, color: Colors.grey),
      );
    }

    return Image.network(
      imageUrl,
      width: double.infinity,
      height: double.infinity,
      fit: fit,
      errorBuilder: (_, __, ___) => Container(
        width: double.infinity,
        color: Colors.grey.shade200,
        child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
      ),
    );
  }
}
