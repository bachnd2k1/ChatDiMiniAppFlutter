import 'package:flutter/material.dart';

import '../../../../data/models/character.dart';
import 'character_card_container.dart';

class MediumCharacterCard extends StatelessWidget {
  const MediumCharacterCard({
    super.key,
    required this.item,
    this.onTap,
  });

  final CharacterModel item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return CharacterCardContainer(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      borderRadius: 12,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Row(
            children: [
              CharacterAvatar(picture: item.picture, radius: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.description ?? item.question ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withValues(alpha: 0.55),
                        height: 1.25,
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
