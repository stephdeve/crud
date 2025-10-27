import 'category.dart';

class CategoryWithCount {
  final Category category;
  final int productCount;

  const CategoryWithCount({required this.category, required this.productCount});

  factory CategoryWithCount.fromRow(Map<String, dynamic> row) {
    return CategoryWithCount(
      category: Category(
        id: row['id'] as int?,
        name: row['name'] as String,
        description: row['description'] as String?,
        image: row['image'] as String?,
      ),
      productCount: (row['product_count'] ?? 0) as int,
    );
  }
}
