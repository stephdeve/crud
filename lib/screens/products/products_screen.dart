import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import '../../widgets/product_card.dart';
import 'product_form_screen.dart';
import 'product_detail_screen.dart';
import '../../utils/navigation.dart' as nav;
import '../../utils/animations.dart';
import '../../utils/overlays.dart';

class ProductsScreen extends ConsumerWidget {
  final int categoryId;
  final String categoryName;
  const ProductsScreen({super.key, required this.categoryId, required this.categoryName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProducts = ref.watch(productsByCategoryProvider(categoryId));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        foregroundColor: colorScheme.onPrimary,
        backgroundColor: colorScheme.primary,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.inventory_2_rounded,
                color: colorScheme.onPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Consumer(
                  builder: (context, ref, child) {
                    final productCount = asyncProducts.maybeWhen(
                      data: (data) => data.length,
                      orElse: () => 0,
                    );
                    return Text(
                      '$productCount produit${productCount > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onPrimary.withOpacity(0.8),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add,
                color: colorScheme.onPrimaryContainer,
                size: 22,
              ),
            ),
            onPressed: () async {
              final created = await nav.push<bool>(context, ProductFormScreen(categoryId: categoryId));
              if (created == true) {
                ref.invalidate(productsByCategoryProvider(categoryId));
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barre de recherche
            _buildSearchSection(ref, colorScheme),
            const SizedBox(height: 24),

            // En-tête de la liste
            _buildListHeader(ref, asyncProducts, colorScheme),
            const SizedBox(height: 16),

            // Liste des produits
            Expanded(
              child: _buildProductsList(context, asyncProducts, ref, colorScheme),
            ),
          ],
        ),
      ),

      // Bouton flottant
      floatingActionButton: Container(
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onPressed: () async {
            final created = await nav.push<bool>(context, ProductFormScreen(categoryId: categoryId));
            if (created == true) {
              ref.invalidate(productsByCategoryProvider(categoryId));
            }
          },
          child: const Icon(Icons.add_rounded, size: 28),
        ),
      ),
    );
  }

  Widget _buildSearchSection(WidgetRef ref, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (v) => ref.read(productSearchProvider(categoryId).notifier).state = v,
        decoration: InputDecoration(
          hintText: 'Rechercher un produit...',
          hintStyle: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.5),
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_rounded,
              color: colorScheme.primary,
            ),
          ),
          filled: true,
          fillColor: colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildListHeader(WidgetRef ref, AsyncValue asyncProducts, ColorScheme colorScheme) {
    return Row(
      children: [
        Text(
          'Tous les produits',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.onBackground,
          ),
        ),
        const Spacer(),
        Consumer(
          builder: (context, ref, child) {
            final searchTerm = ref.watch(productSearchProvider(categoryId));
            final itemCount = asyncProducts.maybeWhen(
              data: (data) => data.length,
              orElse: () => 0,
            );

            if (searchTerm.isNotEmpty) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$itemCount résultat${itemCount > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.secondary,
                  ),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ],
    );
  }

  Widget _buildProductsList(BuildContext context, AsyncValue asyncProducts, WidgetRef ref, ColorScheme colorScheme) {
    return RefreshIndicator(
      backgroundColor: colorScheme.surface,
      color: colorScheme.primary,
      onRefresh: () async {
        ref.invalidate(productsByCategoryProvider(categoryId));
        await ref.read(productsByCategoryProvider(categoryId).future);
      },
      child: asyncProducts.when(
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: colorScheme.primary,
                strokeWidth: 2,
              ),
              const SizedBox(height: 16),
              Text(
                'Chargement des produits...',
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Une erreur est survenue',
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onBackground,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Erreur: $e',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  ref.invalidate(productsByCategoryProvider(categoryId));
                },
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return _buildEmptyState(context, colorScheme, ref);
          }

          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 20),
            itemBuilder: (context, index) {
              final product = items[index];
              return FadeSlideIn(
                index: index,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ProductCard(
                    id: product.id,
                    title: product.name,
                    price: product.price,
                    image: product.image,
                    onTap: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final cs = Theme.of(context).colorScheme;
                      final deleted = await nav.push<bool>(
                          context,
                          ProductDetailScreen(productId: product.id!)
                      );
                      ref.invalidate(productsByCategoryProvider(categoryId));
                      if (deleted == true) {
                        messenger.showSnackBar(
                            buildAppSnack(cs, '🗑️ Produit supprimé', type: SnackType.success)
                        );
                      }
                    },
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: items.length,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme, WidgetRef ref) {
    final searchTerm = ref.watch(productSearchProvider(categoryId));

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: colorScheme.primary.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            searchTerm.isEmpty ? 'Aucun produit' : 'Aucun résultat',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            searchTerm.isEmpty
                ? 'Commencez par ajouter votre premier produit\nà cette catégorie'
                : 'Aucun produit ne correspond à "$searchTerm"',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.6),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          if (searchTerm.isEmpty)
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                final created = await nav.push<bool>(
                    context,
                    ProductFormScreen(categoryId: categoryId)
                );
                if (created == true) {
                  ref.invalidate(productsByCategoryProvider(categoryId));
                }
              },
              child: const Text('Ajouter un produit'),
            )
          else
            OutlinedButton(
              onPressed: () {
                ref.read(productSearchProvider(categoryId).notifier).state = '';
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.onSurface,
                side: BorderSide(color: colorScheme.outline),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Effacer la recherche'),
            ),
        ],
      ),
    );
  }
}