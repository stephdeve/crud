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
      version: 2,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        // Users table
        await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          password_hash TEXT NOT NULL,
          salt TEXT NOT NULL,
          created_at TEXT NOT NULL
        );
        ''');

        // Session holder for audit triggers
        await db.execute('''
        CREATE TABLE app_session (
          id INTEGER PRIMARY KEY CHECK (id = 1),
          current_user_id INTEGER,
          FOREIGN KEY (current_user_id) REFERENCES users(id)
        );
        ''');
        await db.insert('app_session', {'id': 1, 'current_user_id': null});

        // Categories with audit columns
        await db.execute('''
        CREATE TABLE categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT,
          image TEXT,
          created_at TEXT,
          created_by INTEGER,
          updated_at TEXT,
          updated_by INTEGER,
          FOREIGN KEY (created_by) REFERENCES users(id),
          FOREIGN KEY (updated_by) REFERENCES users(id)
        );
        ''');

        // Products with audit columns
        await db.execute('''
        CREATE TABLE products (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT,
          price REAL NOT NULL,
          image TEXT,
          category_id INTEGER NOT NULL,
          created_at TEXT,
          created_by INTEGER,
          updated_at TEXT,
          updated_by INTEGER,
          FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE,
          FOREIGN KEY (created_by) REFERENCES users(id),
          FOREIGN KEY (updated_by) REFERENCES users(id)
        );
        ''');

        // Audit fields are set from application code in services.
      },
      onOpen: (db) async {
        await _seedIfEmpty(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Create users and session if not exist
          await db.execute('''
          CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            password_hash TEXT NOT NULL,
            salt TEXT NOT NULL,
            created_at TEXT NOT NULL
          );
          ''');

          await db.execute('''
          CREATE TABLE IF NOT EXISTS app_session (
            id INTEGER PRIMARY KEY CHECK (id = 1),
            current_user_id INTEGER,
            FOREIGN KEY (current_user_id) REFERENCES users(id)
          );
          ''');
          final existing = await db.query('app_session', limit: 1);
          if (existing.isEmpty) {
            await db.insert('app_session', {'id': 1, 'current_user_id': null});
          }

          // Add audit columns to categories
          await db.execute('ALTER TABLE categories ADD COLUMN created_at TEXT');
          await db.execute('ALTER TABLE categories ADD COLUMN created_by INTEGER');
          await db.execute('ALTER TABLE categories ADD COLUMN updated_at TEXT');
          await db.execute('ALTER TABLE categories ADD COLUMN updated_by INTEGER');

          // Add audit columns to products
          await db.execute('ALTER TABLE products ADD COLUMN created_at TEXT');
          await db.execute('ALTER TABLE products ADD COLUMN created_by INTEGER');
          await db.execute('ALTER TABLE products ADD COLUMN updated_at TEXT');
          await db.execute('ALTER TABLE products ADD COLUMN updated_by INTEGER');

          // Audit fields are set from application code in services.
        }
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
