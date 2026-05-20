import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../../core/utils/json_api.dart';
import '../models/category.dart';
import '../models/character.dart';
import '../models/image_generator.dart';
import '../models/image_style.dart';

class CatalogRepository {
  CatalogRepository(this._api);

  final ApiClient _api;

  Future<List<Category>> getCategories() async {
    final raw = await _api.getJson(ApiConstants.categories);
    return asJsonObjectList(raw).map(Category.fromJson).toList();
  }

  Future<List<Map<String, dynamic>>> getDynamicGroupedStyles({
    required String sessionId,
  }) async {
    final raw = await _api.getJson(
      ApiConstants.dynamicGroupedStyles,
      sessionId: sessionId,
    );
    return asJsonObjectList(raw);
  }

  Future<List<ImageStyle>> getImageStyles() async {
    final raw = await _api.getJson(ApiConstants.imageStyles);
    return asJsonObjectList(raw).map(ImageStyle.fromJson).toList();
  }

  Future<List<ImageGeneratorModel>> getImageGenerators() async {
    final raw = await _api.getJson(ApiConstants.imageGenerators);
    return asJsonObjectList(raw).map(ImageGeneratorModel.fromJson).toList();
  }

  Future<List<CharacterModel>> getCharacters() async {
    final raw = await _api.getJson(ApiConstants.characters);
    return asJsonObjectList(raw).map(CharacterModel.fromJson).toList();
  }
}
