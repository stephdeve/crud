import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/category_with_count.dart';
import 'models/category.dart';
import 'models/product.dart';
import 'models/user.dart';
import 'services/category_service.dart';
import 'services/db_service.dart';
import 'services/product_service.dart';
import 'services/auth_service.dart';

final dbServiceProvider = Provider<DBService>((ref) => DBService.instance);

final authServiceProvider = Provider<AuthService>((ref) {
  final db = ref.read(dbServiceProvider);
  return AuthService(db);
});

final authStateProvider = StreamProvider<AppUser?>((ref) async* {
  final auth = ref.read(authServiceProvider);
  final current = await auth.getCurrentUser();
  yield current;
  yield* auth.userStream;
});

final categoryServiceProvider = Provider<CategoryService>((ref) {
  final db = ref.read(dbServiceProvider);
  final auth = ref.read(authServiceProvider);
  return CategoryService(db, auth);
});

final productServiceProvider = Provider<ProductService>((ref) {
  final db = ref.read(dbServiceProvider);
  final auth = ref.read(authServiceProvider);
  return ProductService(db, auth);
});

final categorySearchProvider = StateProvider<String>((ref) => '');

final categoriesWithCountProvider = FutureProvider.autoDispose<List<CategoryWithCount>>((ref) async {
  final service = ref.watch(categoryServiceProvider);
  final search = ref.watch(categorySearchProvider);
  return service.getAllWithCounts(search: search);
});

final categoriesProvider = FutureProvider.autoDispose<List<Category>>((ref) async {
  final service = ref.watch(categoryServiceProvider);
  return service.getAll();
});

final productSearchProvider = StateProvider.family<String, int>((ref, categoryId) => '');

final productsByCategoryProvider = FutureProvider.family.autoDispose<List<Product>, int>((ref, categoryId) async {
  final service = ref.watch(productServiceProvider);
  final search = ref.watch(productSearchProvider(categoryId));
  return service.getAll(search: search, categoryId: categoryId);
});

final productByIdProvider = FutureProvider.family.autoDispose<Product?, int>((ref, id) async {
  final service = ref.watch(productServiceProvider);
  return service.getById(id);
});
