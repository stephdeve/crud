import '../models/category.dart';
import '../models/category_with_count.dart';
import 'db_service.dart';

class CategoryService {
  final DBService _dbService;
  CategoryService(this._dbService);

  Future<int> create(Category category) async {
    final db = await _dbService.database;
    return db.insert('categories', category.toMap());
  }

  Future<List<Category>> getAll({String search = ''}) async {
    final db = await _dbService.database;
    final like = '%${search.trim()}%';
    final rows = await db.query(
      'categories',
      where: search.isEmpty ? null : 'name LIKE ? OR IFNULL(description, "") LIKE ?',
      whereArgs: search.isEmpty ? null : [like, like],
      orderBy: 'name ASC',
    );
    return rows.map((e) => Category.fromMap(e)).toList();
  }

  Future<List<CategoryWithCount>> getAllWithCounts({String search = ''}) async {
    final db = await _dbService.database;
    final like = '%${search.trim()}%';
    final rows = await db.rawQuery('''
      SELECT c.id, c.name, c.description, c.image, COUNT(p.id) AS product_count
      FROM categories c
      LEFT JOIN products p ON p.category_id = c.id
      ${search.isEmpty ? '' : 'WHERE c.name LIKE ? OR IFNULL(c.description, "") LIKE ?'}
      GROUP BY c.id
      ORDER BY c.name ASC
    ''', search.isEmpty ? [] : [like, like]);

    return rows.map((e) => CategoryWithCount.fromRow(e)).toList();
  }

  Future<int> update(Category category) async {
    final db = await _dbService.database;
    return db.update('categories', category.toMap(), where: 'id = ?', whereArgs: [category.id]);
  }

  Future<int> delete(int id) async {
    final db = await _dbService.database;
    return db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> countProducts(int categoryId) async {
    final db = await _dbService.database;
    final result = await db.rawQuery('SELECT COUNT(*) as c FROM products WHERE category_id = ?', [categoryId]);
    return (result.first['c'] as int?) ?? 0;
  }
}
