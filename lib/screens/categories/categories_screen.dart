import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import '../../widgets/category_card.dart';
import 'category_form_screen.dart';
import '../products/products_screen.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCategories = ref.watch(categoriesWithCountProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catégories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final created = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => const CategoryFormScreen()),
              );
              if (created == true) {
                ref.invalidate(categoriesWithCountProvider);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: (v) => ref.read(categorySearchProvider.notifier).state = v,
              decoration: InputDecoration(
                hintText: 'Rechercher une catégorie...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(categoriesWithCountProvider);
                  await ref.read(categoriesWithCountProvider.future);
                },
                child: asyncCategories.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Erreur: $e')),
                  data: (items) {
                    if (items.isEmpty) {
                      return const Center(child: Text('Aucune catégorie'));
                    }
                    final width = MediaQuery.of(context).size.width;
                    final crossAxisCount = width < 600 ? 2 : 4;
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return CategoryCard(
                          title: item.category.name,
                          image: item.category.image,
                          productCount: item.productCount,
                          onTap: () {
                            if (item.category.id == null) return;
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ProductsScreen(
                                  categoryId: item.category.id!,
                                  categoryName: item.category.name,
                                ),
                              ),
                            );
                          },
                          onLongPress: () async {
                            final updated = await Navigator.of(context).push<bool>(
                              MaterialPageRoute(
                                builder: (_) => CategoryFormScreen(category: item.category),
                              ),
                            );
                            if (updated == true) {
                              ref.invalidate(categoriesWithCountProvider);
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
