class Product {
  final int? id;
  final String name;
  final String description;
  final double price;
  final String? image;
  final int categoryId;

  const Product({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    this.image,
    required this.categoryId,
  });

  Product copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    String? image,
    int? categoryId,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      image: image ?? this.image,
      categoryId: categoryId ?? this.categoryId,
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
    };
  }
}
