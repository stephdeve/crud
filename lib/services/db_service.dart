import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBService {
  DBService._();
  static final DBService instance = DBService._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'crud.db');

    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT,
          image TEXT
        );
        ''');

        await db.execute('''
        CREATE TABLE products (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT,
          price REAL NOT NULL,
          image TEXT,
          category_id INTEGER NOT NULL,
          FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
        );
        ''');
      },
      onOpen: (db) async {
        await _seedIfEmpty(db);
      },
    );
  }

  Future<void> _seedIfEmpty(Database db) async {
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM categories')) ?? 0;
    if (count > 0) return;

    final catId1 = await db.insert('categories', {
      'name': 'Électronique',
      'description': 'Gadgets et appareils',
      'image': null,
    });
    final catId2 = await db.insert('categories', {
      'name': 'Mode',
      'description': 'Vêtements et accessoires',
      'image': null,
    });
    final catId3 = await db.insert('categories', {
      'name': 'Beauté',
      'description': 'Soins et cosmétiques',
      'image': null,
    });
    final catId4 = await db.insert('categories', {
      'name': 'Maison',
      'description': 'Décoration et utilitaires',
      'image': null,
    });

    await db.insert('products', {
      'name': 'Smartphone X',
      'description': 'Écran OLED, 128 Go',
      'price': 799.0,
      'image': null,
      'category_id': catId1,
    });
    await db.insert('products', {
      'name': 'Casque Bluetooth',
      'description': 'Réduction de bruit',
      'price': 149.99,
      'image': null,
      'category_id': catId1,
    });

    await db.insert('products', {
      'name': 'T-shirt coton',
      'description': 'Coupe unisexe',
      'price': 19.99,
      'image': null,
      'category_id': catId2,
    });

    await db.insert('products', {
      'name': 'Rouge à lèvres',
      'description': 'Couleur intense',
      'price': 12.5,
      'image': null,
      'category_id': catId3,
    });

    await db.insert('products', {
      'name': 'Lampe de table',
      'description': 'LED, style minimal',
      'price': 29.9,
      'image': null,
      'category_id': catId4,
    });
  }
}
