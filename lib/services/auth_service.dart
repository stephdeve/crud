import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import 'db_service.dart';

class AuthService {
  static const _prefsUserIdKey = 'current_user_id';
  final DBService _db;
  final _controller = StreamController<AppUser?>.broadcast();

  AuthService(this._db);

  Stream<AppUser?> get userStream => _controller.stream;

  Future<AppUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_prefsUserIdKey);
    if (id == null) return null;
    final db = await _db.database;
    final rows = await db.query('users', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return AppUser.fromMap(rows.first);
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsUserIdKey);
    final db = await _db.database;
    await db.update('app_session', {'current_user_id': null}, where: 'id = ?', whereArgs: [1]);
    _controller.add(null);
  }

  Future<AppUser> signUp({required String name, required String email, required String password}) async {
    final db = await _db.database;
    final exists = await db.query('users', where: 'LOWER(email) = LOWER(?)', whereArgs: [email], limit: 1);
    if (exists.isNotEmpty) {
      throw Exception('Email déjà utilisé');
    }
    final salt = _generateSalt();
    final hash = _hashPassword(password, salt);
    final id = await db.insert('users', {
      'name': name.trim(),
      'email': email.trim(),
      'password_hash': hash,
      'salt': salt,
      'created_at': DateTime.now().toIso8601String(),
    });
    final user = AppUser(id: id, name: name.trim(), email: email.trim(), passwordHash: hash, createdAt: DateTime.now().toIso8601String());
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsUserIdKey, id);
    await db.update('app_session', {'current_user_id': id}, where: 'id = ?', whereArgs: [1]);
    _controller.add(user);
    return user;
  }

  Future<AppUser> signIn({required String email, required String password}) async {
    final db = await _db.database;
    final rows = await db.query('users', where: 'LOWER(email) = LOWER(?)', whereArgs: [email], limit: 1);
    if (rows.isEmpty) {
      throw Exception('Utilisateur introuvable');
    }
    final row = rows.first;
    final salt = row['salt'] as String;
    final expected = row['password_hash'] as String;
    final provided = _hashPassword(password, salt);
    if (provided != expected) {
      throw Exception('Mot de passe incorrect');
    }
    final user = AppUser.fromMap(row);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsUserIdKey, user.id!);
    await db.update('app_session', {'current_user_id': user.id}, where: 'id = ?', whereArgs: [1]);
    _controller.add(user);
    return user;
  }

  String _generateSalt({int length = 16}) {
    final rnd = Random.secure();
    final bytes = List<int>.generate(length, (_) => rnd.nextInt(256));
    return base64UrlEncode(bytes);
  }

  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode('$salt$password');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
