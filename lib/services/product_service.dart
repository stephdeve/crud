import '../models/product.dart';
import 'db_service.dart';
import 'auth_service.dart';

class ProductService {
  final DBService _dbService;
  final AuthService _auth;
  ProductService(this._dbService, this._auth);

  Future<int> create(Product product) async {
    final db = await _dbService.database;
    final user = await _auth.getCurrentUser();
    final now = DateTime.now().toIso8601String();
    final data = product
        .copyWith(
          createdAt: now,
          updatedAt: now,
          createdBy: user?.id,
          updatedBy: user?.id,
        )
        .toMap();
    data.remove('id');
    return db.insert('products', data);
  }

  Future<List<Product>> getAll({String search = '', int? categoryId}) async {
    final db = await _dbService.database;
    final like = '%${search.trim()}%';
    final whereClauses = <String>[];
    final whereArgs = <Object?>[];

    if (search.isNotEmpty) {
      whereClauses.add('(pr.name LIKE ? OR IFNULL(pr.description, "") LIKE ?)');
      whereArgs.addAll([like, like]);
    }
    if (categoryId != null) {
      whereClauses.add('pr.category_id = ?');
      whereArgs.add(categoryId);
    }

    final rows = await db.rawQuery('''
      SELECT pr.*, uc.name AS created_by_name, uu.name AS updated_by_name
      FROM products pr
      LEFT JOIN users uc ON uc.id = pr.created_by
      LEFT JOIN users uu ON uu.id = pr.updated_by
      ${whereClauses.isEmpty ? '' : 'WHERE ' + whereClauses.join(' AND ')}
      ORDER BY pr.name ASC
    ''', whereArgs.isEmpty ? [] : whereArgs);
    return rows.map((e) => Product.fromMap(e)).toList();
  }

  Future<Product?> getById(int id) async {
    final db = await _dbService.database;
    final rows = await db.rawQuery('''
      SELECT pr.*, uc.name AS created_by_name, uu.name AS updated_by_name
      FROM products pr
      LEFT JOIN users uc ON uc.id = pr.created_by
      LEFT JOIN users uu ON uu.id = pr.updated_by
      WHERE pr.id = ?
      LIMIT 1
    ''', [id]);
    if (rows.isEmpty) return null;
    return Product.fromMap(rows.first);
  }

  Future<int> update(Product product) async {
    final db = await _dbService.database;
    final user = await _auth.getCurrentUser();
    if (user == null) throw Exception('Non authentifié');
    final now = DateTime.now().toIso8601String();
    final data = {
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'image': product.image,
      'category_id': product.categoryId,
      'updated_at': now,
      'updated_by': user.id,
    };
    return db.update('products', data, where: 'id = ?', whereArgs: [product.id]);
  }

  Future<int> delete(int id) async {
    final db = await _dbService.database;
    final user = await _auth.getCurrentUser();
    if (user == null) throw Exception('Non authentifié');
    return db.delete('products', where: 'id = ?', whereArgs: [id]);
  }
}
