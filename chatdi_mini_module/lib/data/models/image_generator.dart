class ImageGeneratorModel {
  ImageGeneratorModel({
    required this.id,
    required this.name,
    this.picture,
    this.prompt,
  });

  factory ImageGeneratorModel.fromJson(Map<String, dynamic> json) =>
      ImageGeneratorModel(
        id: '${json['id'] ?? ''}',
        name: '${json['name'] ?? ''}',
        picture: json['picture'] as String?,
        prompt: json['prompt'] as String?,
      );

  final String id;
  final String name;
  final String? picture;
  final String? prompt;
}
