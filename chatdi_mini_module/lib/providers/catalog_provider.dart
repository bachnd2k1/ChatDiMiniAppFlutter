import 'package:flutter/foundation.dart' hide Category;

import '../data/models/category.dart';
import '../data/models/character.dart';
import '../data/models/image_generator.dart';
import '../data/models/image_style.dart';
import '../data/repositories/catalog_repository.dart';

class CatalogProvider extends ChangeNotifier {
  CatalogProvider(this._repo);

  final CatalogRepository _repo;

  List<Category> categories = [];
  List<ImageGeneratorModel> imageGenerators = [];
  List<CharacterModel> characters = [];
  List<ImageStyle> chatImageStyles = [];
  List<Map<String, dynamic>> homeDynamicGroupedStyles = [];
  List<String> trendings = [];
  bool _chatStylesLoaded = false;
  bool _homeDynamicStylesLoaded = false;

  bool categoriesLoading = false;
  bool imageGeneratorsLoading = false;
  bool charactersLoading = false;
  bool homeDynamicStylesLoading = false;
  Object? categoriesError;
  Object? homeDynamicStylesError;

  Future<void> ensureCategoriesLoaded({bool forceRefresh = false}) async {
    if (categoriesLoading) return;
    if (!forceRefresh && categories.isNotEmpty && trendings.isNotEmpty) return;
    categoriesLoading = true;
    categoriesError = null;
    notifyListeners();
    try {
      categories = await _repo.getCategories();
      trendings = await getRandomCategories(categories);
    } catch (e) {
      categoriesError = e;
    } finally {
      categoriesLoading = false;
      notifyListeners();
    }
  }

  Future<void> ensureImageGeneratorsLoaded({bool forceRefresh = false}) async {
    if (imageGeneratorsLoading) return;
    if (!forceRefresh && imageGenerators.isNotEmpty) return;
    imageGeneratorsLoading = true;
    notifyListeners();
    try {
      imageGenerators = await _repo.getImageGenerators();
    } finally {
      imageGeneratorsLoading = false;
      notifyListeners();
    }
  }

  Future<void> ensureCharactersLoaded({bool forceRefresh = false}) async {
    if (charactersLoading) return;
    if (!forceRefresh && characters.isNotEmpty) return;
    charactersLoading = true;
    notifyListeners();
    try {
      characters = await _repo.getCharacters();
    } finally {
      charactersLoading = false;
      notifyListeners();
    }
  }

  Future<void> prefetchTabData() async {
    await Future.wait([
      ensureCategoriesLoaded(),
      ensureImageGeneratorsLoaded(),
      ensureCharactersLoaded(),
    ]);
  }

  /// Chat screen companion store (unused by UI có thể dùng để chia sẻ style).
  Future<void> loadChatStylesIfNeeded() async {
    if (_chatStylesLoaded && chatImageStyles.isNotEmpty) return;
    final list = await _repo.getImageStyles();
    chatImageStyles = list;
    _chatStylesLoaded = true;
    notifyListeners();
  }

  Future<void> ensureHomeDynamicStylesLoaded({
    required String sessionId,
    bool forceRefresh = false,
  }) async {
    if (homeDynamicStylesLoading) return;
    if (!forceRefresh &&
        _homeDynamicStylesLoaded &&
        homeDynamicGroupedStyles.isNotEmpty) {
      return;
    }
    homeDynamicStylesLoading = true;
    homeDynamicStylesError = null;
    notifyListeners();
    try {
      homeDynamicGroupedStyles = await _repo.getDynamicGroupedStyles(
        sessionId: sessionId,
      );
      _homeDynamicStylesLoaded = true;
    } catch (e) {
      homeDynamicStylesError = e;
    } finally {
      homeDynamicStylesLoading = false;
      notifyListeners();
    }
  }

  Future<List<String>> getRandomCategories(
    List<Category> categoriesList, {
    int count = 4,
  }) async {
    if (categoriesList.isEmpty) {
      return ["Hello"];
    }

    final shuffled = [...categoriesList]..shuffle();
    final selectedCount = min(count, shuffled.length);
    final newCategories = shuffled.take(selectedCount).toList();

    final List<String> newTrendings = [];

    for (final category in newCategories) {
      final suggestions = (category.suggestion ?? '')
          .split('\n')
          .map((item) => item.replaceAll('- ', '').trim())
          .where((item) => item.isNotEmpty)
          .toList();

      newTrendings.addAll(suggestions);
    }

    final shuffledTrendings = [...newTrendings]..shuffle();
    return shuffledTrendings;
  }
}
