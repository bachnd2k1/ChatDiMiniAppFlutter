/// Shared API configuration (aligned with docs/03-api-by-screen.md).
abstract final class ApiConstants {
  static const String baseUrl = 'https://chatdi.vynix.org';
  static const String ssePath = '/sse';

  static const categories = '/categories';
  static const dynamicGroupedStyles = '/dynamic/grouped-styles';
  static const imageStyles = '/image-styles';
  static const imageGenerators = '/image-generators';
  static const characters = '/characters';
  /// Ask chat — spec: POST `/message/message` (không còn `/message`).
  static const message = '/message/message';
  static const messageTextToImage = '/message/text-to-image';
  static const messageCharacter = '/message/character';
  static const messageStop = '/message/stop';
}
