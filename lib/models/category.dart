class Category {
  final int? id;
  final String name;
  final String? description;
  final String? image;
  final String? createdAt;
  final int? createdBy;
  final String? updatedAt;
  final int? updatedBy;
  final String? createdByName;
  final String? updatedByName;

  const Category({this.id, required this.name, this.description, this.image, this.createdAt, this.createdBy, this.updatedAt, this.updatedBy, this.createdByName, this.updatedByName});

  Category copyWith({
    int? id,
    String? name,
    String? description,
    String? image,
    String? createdAt,
    int? createdBy,
    String? updatedAt,
    int? updatedBy,
    String? createdByName,
    String? updatedByName,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      createdByName: createdByName ?? this.createdByName,
      updatedByName: updatedByName ?? this.updatedByName,
    );
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      image: map['image'] as String?,
      createdAt: map['created_at'] as String?,
      createdBy: map['created_by'] as int?,
      updatedAt: map['updated_at'] as String?,
      updatedBy: map['updated_by'] as int?,
      createdByName: map['created_by_name'] as String?,
      updatedByName: map['updated_by_name'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'image': image,
      'created_at': createdAt,
      'created_by': createdBy,
      'updated_at': updatedAt,
      'updated_by': updatedBy,
    };
  }
}
