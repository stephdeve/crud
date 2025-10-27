import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import '../../widgets/product_card.dart';
import 'product_form_screen.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends ConsumerWidget {
  final int categoryId;
  final String categoryName;
  const ProductsScreen({super.key, required this.categoryId, required this.categoryName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProducts = ref.watch(productsByCategoryProvider(categoryId));
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final created = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => ProductFormScreen(categoryId: categoryId),
                ),
              );
              if (created == true) {
                ref.invalidate(productsByCategoryProvider(categoryId));
              }
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => ProductFormScreen(categoryId: categoryId),
            ),
          );
          if (created == true) {
            ref.invalidate(productsByCategoryProvider(categoryId));
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: (v) => ref.read(productSearchProvider(categoryId).notifier).state = v,
              decoration: InputDecoration(
                hintText: 'Rechercher un produit...',
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
                  ref.invalidate(productsByCategoryProvider(categoryId));
                  await ref.read(productsByCategoryProvider(categoryId).future);
                },
                child: asyncProducts.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Erreur: $e')),
                  data: (items) {
                    if (items.isEmpty) {
                      return const Center(child: Text('Aucun produit'));
                    }
                    return ListView.separated(
                      itemBuilder: (context, index) {
                        final p = items[index];
                        return ProductCard(
                          id: p.id,
                          title: p.name,
                          price: p.price,
                          image: p.image,
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: p.id!)),
                            );
                            ref.invalidate(productsByCategoryProvider(categoryId));
                          },
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemCount: items.length,
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
