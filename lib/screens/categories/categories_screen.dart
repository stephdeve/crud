import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import '../../widgets/category_card.dart';
import 'category_form_screen.dart';
import '../products/products_screen.dart';
import '../../utils/navigation.dart' as nav;
import '../../utils/animations.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  // Palette de couleurs secondaires pour les cartes
  static final List<Color> _cardColors = [
    const Color(0xFF6366F1), // Indigo
    const Color(0xFFEC4899), // Pink
    const Color(0xFF10B981), // Emerald
    const Color(0xFFF59E0B), // Amber
    const Color(0xFF8B5CF6), // Violet
    const Color(0xFF06B6D4), // Cyan
    const Color(0xFF84CC16), // Lime
    const Color(0xFFEF4444), // Red
  ];

  static final List<Color> _cardLightColors = [
    const Color(0xFFEEF2FF), // Indigo light
    const Color(0xFFFDF2F8), // Pink light
    const Color(0xFFECFDF5), // Emerald light
    const Color(0xFFFFFBEB), // Amber light
    const Color(0xFFF5F3FF), // Violet light
    const Color(0xFFECFEFF), // Cyan light
    const Color(0xFFF7FEE7), // Lime light
    const Color(0xFFFEF2F2), // Red light
  ];

  Color _getCardColor(int index, bool isBackground) {
    final colorIndex = index % _cardColors.length;
    return isBackground ? _cardLightColors[colorIndex] : _cardColors[colorIndex];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCategories = ref.watch(categoriesWithCountProvider);
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
                Icons.category_rounded,
                color: colorScheme.onPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Catégories',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: colorScheme.onPrimary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primaryContainer,
                    colorScheme.secondaryContainer,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add,
                color: colorScheme.onPrimaryContainer,
                size: 22,
              ),
            ),
            onPressed: () async {
              final created = await nav.push<bool>(context, const CategoryFormScreen());
              if (created == true) {
                ref.invalidate(categoriesWithCountProvider);
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
            // Header avec statistiques
            _buildHeaderStats(ref, colorScheme),
            const SizedBox(height: 20),

            // Barre de recherche avec filtre
            _buildSearchSection(ref, colorScheme),
            const SizedBox(height: 24),

            // En-tête de la grille
            _buildGridHeader(ref, asyncCategories, colorScheme),
            const SizedBox(height: 16),

            // Grille des catégories
            Expanded(
              child: _buildCategoriesGrid(context, asyncCategories, ref, colorScheme),
            ),
          ],
        ),
      ),

      // Bouton flottant avec dégradé
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary,
              colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
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
            final created = await nav.push<bool>(context, const CategoryFormScreen());
            if (created == true) {
              ref.invalidate(categoriesWithCountProvider);
            }
          },
          child: const Icon(Icons.add_rounded, size: 28),
        ),
      ),
    );
  }

  Widget _buildHeaderStats(WidgetRef ref, ColorScheme colorScheme) {
    return Consumer(
      builder: (context, ref, child) {
        // Calcul du nombre total de produits depuis les catégories
        final categories = ref.watch(categoriesWithCountProvider);
        int totalProducts = 0;
        int categoryCount = 0;

        categories.when(
          data: (items) {
            categoryCount = items.length;
            totalProducts = items.fold(0, (sum, item) => sum + item.productCount);
          },
          loading: () {},
          error: (_, __) {},
        );

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withOpacity(0.1),
                colorScheme.secondary.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.inventory_2_rounded,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Votre collection',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onBackground.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$totalProducts produit${totalProducts > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onBackground,
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical:
                12),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.category_rounded,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$categoryCount catégorie${categoryCount > 1 ? 's' : ''
                      } disponibles',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchSection(WidgetRef ref, ColorScheme colorScheme) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            onChanged: (v) => ref.read(categorySearchProvider.notifier).state = v,
            decoration: InputDecoration(
              hintText: 'Rechercher une catégorie...',
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
        ),
      ],
    );
  }

  Widget _buildGridHeader(WidgetRef ref, AsyncValue asyncCategories, ColorScheme colorScheme) {
    return Row(
      children: [
        Text(
          'Toutes les catégories',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.onBackground,
          ),
        ),
        const Spacer(),
        Consumer(
          builder: (context, ref, child) {
            final searchTerm = ref.watch(categorySearchProvider);
            final itemCount = asyncCategories.maybeWhen(
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

  Widget _buildCategoriesGrid(BuildContext context, AsyncValue asyncCategories, WidgetRef ref, ColorScheme colorScheme) {
    return RefreshIndicator(
      backgroundColor: colorScheme.surface,
      color: colorScheme.primary,
      onRefresh: () async {
        ref.invalidate(categoriesWithCountProvider);
        await ref.read(categoriesWithCountProvider.future);
      },
      child: asyncCategories.when(
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
                'Chargement des catégories...',
                style: TextStyle(
                  color: colorScheme.onBackground.withOpacity(0.6),
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
                  color: colorScheme.onBackground.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  ref.invalidate(categoriesWithCountProvider);
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

          final width = MediaQuery.of(context).size.width;
          final crossAxisCount = width < 600 ? 2 : width < 900 ? 3 : 4;

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final cardColor = _getCardColor(index, true);
              final accentColor = _getCardColor(index, false);

              return FadeSlideIn(
                index: index,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),

                  ),
                  child: CategoryCard(
                    title: item.category.name,
                    image: item.category.image,
                    productCount: item.productCount,
                    backgroundColor: cardColor,
                    accentColor: accentColor,
                    onTap: () {
                      if (item.category.id == null) return;
                      nav.push(
                        context,
                        ProductsScreen(
                          categoryId: item.category.id!,
                          categoryName: item.category.name,
                        ),
                      );
                    },
                    onLongPress: () async {
                      final updated = await nav.push<bool>(
                        context,
                        CategoryFormScreen(category: item.category),
                      );
                      if (updated == true) {
                        ref.invalidate(categoriesWithCountProvider);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme, WidgetRef ref) {
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
              Icons.category_outlined,
              size: 80,
              color: colorScheme.primary.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Aucune catégorie trouvée',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Commencez par créer votre première catégorie\npour organiser vos produits',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onBackground.withOpacity(0.6),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
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
                  const CategoryFormScreen()
              );
              if (created == true) {
                ref.invalidate(categoriesWithCountProvider);
              }
            },
            child: const Text('Créer une catégorie'),
          ),
        ],
      ),
    );
  }
}