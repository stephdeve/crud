class Product {
  final int? id;
  final String name;
  final String description;
  final double price;
  final String? image;
  final int categoryId;
  final String? createdAt;
  final int? createdBy;
  final String? updatedAt;
  final int? updatedBy;
  final String? createdByName;
  final String? updatedByName;

  const Product({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    this.image,
    required this.categoryId,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.createdByName,
    this.updatedByName,
  });

  Product copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    String? image,
    int? categoryId,
    String? createdAt,
    int? createdBy,
    String? updatedAt,
    int? updatedBy,
    String? createdByName,
    String? updatedByName,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      image: image ?? this.image,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      createdByName: createdByName ?? this.createdByName,
      updatedByName: updatedByName ?? this.updatedByName,
    );
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      price: (map['price'] as num).toDouble(),
      image: map['image'] as String?,
      categoryId: map['category_id'] as int,
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
      'price': price,
      'image': image,
      'category_id': categoryId,
      'created_at': createdAt,
      'created_by': createdBy,
      'updated_at': updatedAt,
      'updated_by': updatedBy,
    };
  }
}
