import '../data/models/category.dart';
import '../data/models/character.dart';
import '../data/models/image_generator.dart';

/// Parameters when opening `/chat`-equivalent route.
class ChatLaunchArgs {
  ChatLaunchArgs({
    this.conversationId,
    this.initialDraft,
    this.topicCategory,
    this.character,
    this.tabIndex = 0,
    this.promptFromGenerator,
    this.overrideTitle,
  });

  /// Open persisted thread (history).
  final String? conversationId;

  /// Prefill composer (Assistants/Home shortcuts).
  final String? initialDraft;

  /// Active assistant topic (`topics` POST field for `/message`).
  final Category? topicCategory;

  /// Character flow → POST `/message/character`.
  final CharacterModel? character;

  /// 0 Ask, 1 Image tab.
  final int tabIndex;

  /// Prompt from `/image-generators`.
  final String? promptFromGenerator;

  /// Optional title when creating a brand-new thread metadata.
  final String? overrideTitle;

  Category? get effectiveCategory => topicCategory;

  factory ChatLaunchArgs.topicPrompt(String text) =>
      ChatLaunchArgs(initialDraft: text.trim());

  factory ChatLaunchArgs.imagePrompt(String text) =>
      ChatLaunchArgs(initialDraft: text.trim(), tabIndex: 1);

  factory ChatLaunchArgs.characterChat(CharacterModel c) =>
      ChatLaunchArgs(character: c, tabIndex: 0);

  factory ChatLaunchArgs.generatorPreset(ImageGeneratorModel g) => ChatLaunchArgs(
        initialDraft: (g.prompt ?? g.name).trim(),
        tabIndex: 1,
      );

  factory ChatLaunchArgs.assistantSuggestions(Category cat) {
    final first =
        cat.suggestionLines.isNotEmpty ? cat.suggestionLines.first : '';
    return ChatLaunchArgs(topicCategory: cat, initialDraft: first);
  }

  factory ChatLaunchArgs.historyThread(String conversationId) =>
      ChatLaunchArgs(conversationId: conversationId);
}
