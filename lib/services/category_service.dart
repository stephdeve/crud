import '../models/category.dart';
import '../models/category_with_count.dart';
import 'db_service.dart';
import 'auth_service.dart';

class CategoryService {
  final DBService _dbService;
  final AuthService _auth;
  CategoryService(this._dbService, this._auth);

  Future<int> create(Category category) async {
    final db = await _dbService.database;
    final user = await _auth.getCurrentUser();
    if (user == null) throw Exception('Non authentifié');
    final now = DateTime.now().toIso8601String();
    final data = category
        .copyWith(
          createdAt: now,
          updatedAt: now,
          createdBy: user.id,
          updatedBy: user.id,
        )
        .toMap();
    data.remove('id');
    return db.insert('categories', data);
  }

  Future<List<Category>> getAll({String search = ''}) async {
    final db = await _dbService.database;
    final like = '%${search.trim()}%';
    final rows = await db.rawQuery('''
      SELECT c.*,
             uc.name AS created_by_name,
             uu.name AS updated_by_name
      FROM categories c
      LEFT JOIN users uc ON uc.id = c.created_by
      LEFT JOIN users uu ON uu.id = c.updated_by
      ${search.isEmpty ? '' : 'WHERE c.name LIKE ? OR IFNULL(c.description, "") LIKE ?'}
      ORDER BY c.name ASC
    ''', search.isEmpty ? [] : [like, like]);
    return rows.map((e) => Category.fromMap(e)).toList();
  }

  Future<List<CategoryWithCount>> getAllWithCounts({String search = ''}) async {
    final db = await _dbService.database;
    final like = '%${search.trim()}%';
    final rows = await db.rawQuery('''
      SELECT c.id, c.name, c.description, c.image,
             c.created_at, c.created_by, c.updated_at, c.updated_by,
             uc.name AS created_by_name, uu.name AS updated_by_name,
             COUNT(p.id) AS product_count
      FROM categories c
      LEFT JOIN products p ON p.category_id = c.id
      LEFT JOIN users uc ON uc.id = c.created_by
      LEFT JOIN users uu ON uu.id = c.updated_by
      ${search.isEmpty ? '' : 'WHERE c.name LIKE ? OR IFNULL(c.description, "") LIKE ?'}
      GROUP BY c.id
      ORDER BY c.name ASC
    ''', search.isEmpty ? [] : [like, like]);

    return rows.map((e) => CategoryWithCount.fromRow(e)).toList();
  }

  Future<int> update(Category category) async {
    final db = await _dbService.database;
    final user = await _auth.getCurrentUser();
    if (user == null) throw Exception('Non authentifié');
    final now = DateTime.now().toIso8601String();
    final data = {
      'name': category.name,
      'description': category.description,
      'image': category.image,
      'updated_at': now,
      'updated_by': user.id,
    };
    return db.update('categories', data, where: 'id = ?', whereArgs: [category.id]);
  }

  Future<int> delete(int id) async {
    final db = await _dbService.database;
    final user = await _auth.getCurrentUser();
    if (user == null) throw Exception('Non authentifié');
    return db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> countProducts(int categoryId) async {
    final db = await _dbService.database;
    final result = await db.rawQuery('SELECT COUNT(*) as c FROM products WHERE category_id = ?', [categoryId]);
    return (result.first['c'] as int?) ?? 0;
  }
}
