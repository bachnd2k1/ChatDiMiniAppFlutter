import 'package:flutter/material.dart';

import '../../../../data/models/character.dart';
import '../../../chat/chat_screen.dart';
import '../../../../providers/chat_launch_args.dart';
import '../../character_card_type.dart';
import 'large_character_card.dart';
import 'medium_character_card.dart';
import 'wide_character_card.dart';

class HomeCharacterSection extends StatelessWidget {
  final bool isLoading;
  final List<CharacterModel> characters;

  const HomeCharacterSection({
    super.key,
    required this.isLoading,
    required this.characters,
  });

  @override
  Widget build(BuildContext context) {
    final visibleCharacters = characters.take(5).toList();

    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 0, right: 16, bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF0AC198), Color(0xFF019AB1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text(
                  'Characters',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                Spacer(),
                Text(
                  'See All',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isLoading)
              const LinearProgressIndicator(
                color: Colors.white,
                backgroundColor: Colors.white24,
              )
            else if (visibleCharacters.isEmpty)
              const Text(
                'Đang không có nhân vật — vuốt xuống để prefetch.',
                style: TextStyle(color: Colors.white),
              )
            else
              _CharacterGrid(characters: visibleCharacters),
          ],
        ),
      ),
    );
  }
}

class _CharacterGrid extends StatelessWidget {
  static const double _characterCardGap = 8;
  static const double _characterTopRowHeight = 248;

  final List<CharacterModel> characters;

  const _CharacterGrid({required this.characters});

  @override
  Widget build(BuildContext context) {
    if (characters.length < 5) {
      return Column(
        children: characters
            .asMap()
            .entries
            .map(
              (entry) => Padding(
                padding: EdgeInsets.only(bottom: entry.key < characters.length - 1 ? _characterCardGap : 0),
                child: _buildCharacterCard(context, entry.value, getCardType(entry.key)),
              ),
            )
            .toList(),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: _characterTopRowHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildCharacterCard(context, characters[0], getCardType(0)),
              ),
              const SizedBox(width: _characterCardGap),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: _buildCharacterCard(context, characters[1], getCardType(1)),
                    ),
                    const SizedBox(height: _characterCardGap),
                    Expanded(
                      child: _buildCharacterCard(context, characters[2], getCardType(2)),
                    ),
                    const SizedBox(height: _characterCardGap),
                    Expanded(
                      child: _buildCharacterCard(context, characters[3], getCardType(3)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: _characterCardGap),
        _buildCharacterCard(context, characters[4], getCardType(4)),
      ],
    );
  }

  Widget _buildCharacterCard(
    BuildContext context,
    CharacterModel item,
    CharacterCardType type,
  ) {
    void openChat() => ChatScreen.open(context, ChatLaunchArgs.characterChat(item));

    switch (type) {
      case CharacterCardType.large:
        return LargeCharacterCard(item: item, onTap: openChat);
      case CharacterCardType.medium:
        return MediumCharacterCard(item: item, onTap: openChat);
      case CharacterCardType.wide:
        return WideCharacterCard(item: item, onTap: openChat);
    }
  }

  CharacterCardType getCardType(int index) {
    switch (index) {
      case 0:
        return CharacterCardType.large;
      case 4:
        return CharacterCardType.wide;
      default:
        return CharacterCardType.medium;
    }
  }
}
