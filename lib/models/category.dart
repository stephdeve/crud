class Category {
  final int? id;
  final String name;
  final String? description;
  final String? image;

  const Category({this.id, required this.name, this.description, this.image});

  Category copyWith({
    int? id,
    String? name,
    String? description,
    String? image,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
    );
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      image: map['image'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'image': image,
    };
  }
}
