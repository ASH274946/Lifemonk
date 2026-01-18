/// Educational Byte Content Model
/// Represents short-form educational videos/images for quick learning
class ByteContent {
  final String id;
  final String url;
  final String type; // 'image' or 'video'
  final String? name;
  final String? description;
  final String? category; // e.g., 'HEALTH', 'MATH', 'SCIENCE'
  final DateTime createdAt;

  const ByteContent({
    required this.id,
    required this.url,
    required this.type,
    this.name,
    this.description,
    this.category,
    required this.createdAt,
  });

  factory ByteContent.mock() {
    return ByteContent(
      id: 'byte-1',
      url: 'https://via.placeholder.com/400x800?text=Learning+Bytes',
      type: 'image',
      name: 'Quick Learning Byte',
      description: 'Short educational content for quick learning',
      createdAt: DateTime.now(),
    );
  }

  factory ByteContent.fromJson(Map<String, dynamic> json) {
    return ByteContent(
      id: json['id'] as String,
      url: json['url'] as String,
      type: json['type'] as String? ?? 'image',
      name: json['name'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'type': type,
      'name': name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
