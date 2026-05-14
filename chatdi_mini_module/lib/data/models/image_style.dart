class ImageStyle {
  ImageStyle({
    required this.id,
    required this.name,
    this.description,
    this.logo,
  });

  factory ImageStyle.fromJson(Map<String, dynamic> json) => ImageStyle(
        id: '${json['id'] ?? ''}',
        name: '${json['name'] ?? ''}',
        description: json['description'] as String?,
        logo: json['logo'] as String?,
      );

  final String id;
  final String name;
  final String? description;
  final String? logo;
}
