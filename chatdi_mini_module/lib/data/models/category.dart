class Category {
  Category({
    required this.id,
    required this.name,
    this.icon,
    this.description,
    this.suggestion,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: '${json['id'] ?? ''}',
        name: '${json['name'] ?? ''}',
        icon: json['icon'] as String?,
        description: json['description'] as String?,
        suggestion: json['suggestion'] as String?,
      );

  final String id;
  final String name;
  final String? icon;
  final String? description;
  final String? suggestion;

  List<String> get suggestionLines =>
      suggestion?.split(RegExp(r'[\r\n]+')).where((s) => s.trim().isNotEmpty).map((s) => s.trim()).toList() ??
      const [];
}
