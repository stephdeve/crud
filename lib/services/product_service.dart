import '../models/product.dart';
import 'db_service.dart';

class ProductService {
  final DBService _dbService;
  ProductService(this._dbService);

  Future<int> create(Product product) async {
    final db = await _dbService.database;
    return db.insert('products', product.toMap());
  }

  Future<List<Product>> getAll({String search = '', int? categoryId}) async {
    final db = await _dbService.database;
    final like = '%${search.trim()}%';
    final whereClauses = <String>[];
    final whereArgs = <Object?>[];

    if (search.isNotEmpty) {
      whereClauses.add('(name LIKE ? OR IFNULL(description, "") LIKE ?)');
      whereArgs.addAll([like, like]);
    }
    if (categoryId != null) {
      whereClauses.add('category_id = ?');
      whereArgs.add(categoryId);
    }

    final rows = await db.query(
      'products',
      where: whereClauses.isEmpty ? null : whereClauses.join(' AND '),
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'name ASC',
    );
    return rows.map((e) => Product.fromMap(e)).toList();
  }

  Future<Product?> getById(int id) async {
    final db = await _dbService.database;
    final rows = await db.query('products', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return Product.fromMap(rows.first);
  }

  Future<int> update(Product product) async {
    final db = await _dbService.database;
    return db.update('products', product.toMap(), where: 'id = ?', whereArgs: [product.id]);
  }

  Future<int> delete(int id) async {
    final db = await _dbService.database;
    return db.delete('products', where: 'id = ?', whereArgs: [id]);
  }
}
