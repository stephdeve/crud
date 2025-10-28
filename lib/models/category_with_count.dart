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
        createdAt: row['created_at'] as String?,
        createdBy: row['created_by'] as int?,
        updatedAt: row['updated_at'] as String?,
        updatedBy: row['updated_by'] as int?,
        createdByName: row['created_by_name'] as String?,
        updatedByName: row['updated_by_name'] as String?,
      ),
      productCount: (row['product_count'] ?? 0) as int,
    );
  }
}
