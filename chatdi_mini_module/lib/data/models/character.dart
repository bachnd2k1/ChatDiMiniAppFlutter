class CharacterModel {
  CharacterModel({
    required this.id,
    required this.name,
    required this.topics,
    this.question,
    this.description,
    this.picture,
  });

  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    List<String> topicsList = [];
    final t = json['topics'];
    if (t is List) {
      topicsList = t.map((e) => '$e').toList();
    }
    return CharacterModel(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? ''}',
      topics: topicsList,
      question: json['question'] as String?,
      description: json['description'] as String?,
      picture: json['picture'] as String?,
    );
  }

  final String id;
  final String name;
  final List<String> topics;
  final String? question;
  final String? description;
  final String? picture;
}
