import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../providers.dart';
import '../../utils/format.dart';
import 'product_form_screen.dart';
import '../../utils/overlays.dart';
import '../../utils/navigation.dart' as nav;

class ProductDetailScreen extends ConsumerWidget {
  final int productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProduct = ref.watch(productByIdProvider(productId));
    final colorScheme = Theme.of(context).colorScheme;

    return asyncProduct.when(
      loading: () => Scaffold(
        backgroundColor: colorScheme.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'Chargement du produit...',
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha:0.6),
                ),
              ),
            ],
          ),
        ),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: colorScheme.primary,
          elevation: 0,
        ),
        body: Center(
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
                'Erreur de chargement',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Erreur: $e',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha:0.6),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  ref.invalidate(productByIdProvider(productId));
                },
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
      data: (p) {
        if (p == null) {
          return Scaffold(
            backgroundColor: colorScheme.surface,
            appBar: AppBar(
              foregroundColor: colorScheme.onPrimary,
              backgroundColor: colorScheme.primary,
              elevation: 0,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: colorScheme.onSurface.withValues(alpha:0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Produit introuvable',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Le produit que vous recherchez n\'existe pas ou a été supprimé',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha:0.6),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Retour'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            foregroundColor: colorScheme.onPrimary,
            backgroundColor: colorScheme.primary,
            elevation: 0,
            centerTitle: false,
            title: Text(
              'Détails du produit',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    color: colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                onPressed: () async {
                  final updated = await nav.push<bool>(
                    context,
                    ProductFormScreen(categoryId: p.categoryId, product: p),
                  );
                  if (updated == true) {
                    ref.invalidate(productByIdProvider(productId));
                    ref.invalidate(productsByCategoryProvider(p.categoryId));
                  }
                },
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha:0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
                onPressed: () => _showDeleteDialog(context, ref, p),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              // Section Image
              Expanded(
                flex: 2,
                child: _buildImageSection(context, p, colorScheme),
              ),

              // Section Informations
              Expanded(
                flex: 3,
                child: _buildInfoSection(context, ref, p, colorScheme),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageSection(BuildContext context, Product p, ColorScheme colorScheme) {
    return Hero(
      tag: 'product-image-${p.id ?? p.name}',
      child: AspectRatio(
        aspectRatio: 1.1,
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: p.image != null && p.image!.isNotEmpty
              ? ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            child: Image.file(
              File(p.image!),
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          )
              : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha:0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    size: 48,
                    color: colorScheme.primary.withValues(alpha:0.5),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucune image',
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha:0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, WidgetRef ref, Product p, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: ListView(
        children: [
          // Nom et Prix
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha:0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              formatPrice(p.price),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.secondary.withValues(alpha:0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.shopping_bag_rounded,
                        color: colorScheme.secondary,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                // Métadonnées de création et modification
                if ((p.createdByName ?? '').isNotEmpty || (p.createdAt ?? '').isNotEmpty ||
                    (p.updatedByName ?? '').isNotEmpty || (p.updatedAt ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if ((p.createdByName ?? '').isNotEmpty || (p.createdAt ?? '').isNotEmpty)
                          _buildMetaItem(
                            context: context,
                            icon: Icons.person_outline_rounded,
                            label: 'Créé par',
                            value: '${p.createdByName ?? '-'} • ${_formatDateTime(p.createdAt)}',
                            color: const Color(0xFF10B981),
                          ),
                        if ((p.updatedByName ?? '').isNotEmpty || (p.updatedAt ?? '').isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: _buildMetaItem(
                              context: context,
                              icon: Icons.update_rounded,
                              label: 'Mis à jour',
                              value: '${_formatDateTime(p.updatedAt)} par ${p.updatedByName ?? '-'}',
                              color: const Color(0xFF8B5CF6),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Description
          if (p.description.isNotEmpty) ...[
            Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                p.description,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Informations supplémentaires
          Text(
            'Informations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _InfoItem(
                  icon: Icons.category_rounded,
                  label: 'Catégorie',
                  value: _getCategoryName(ref, p.categoryId),
                  color: const Color(0xFF10B981),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //  Ajout du paramètre BuildContext
  Widget _buildMetaItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withValues(alpha:0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 14,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha:0.6),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Méthode de formatage des dates
  String _formatDateTime(String? dateTime) {
    if (dateTime == null) return '';
    final dt = DateTime.tryParse(dateTime);
    if (dt == null) return '';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _getCategoryName(WidgetRef ref, int categoryId) {
    final categories = ref.watch(categoriesProvider);
    return categories.maybeWhen(
      data: (categories) {
        final category = categories.firstWhere(
              (cat) => cat.id == categoryId,
          orElse: () => Category(name: 'Inconnue'),
        );
        return category.name;
      },
      orElse: () => 'Chargement...',
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Product p) async {
    final result = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha:0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.delete_outline_rounded,
            color: Colors.red,
            size: 32,
          ),
        ),
        title: Text(
          'Supprimer le produit',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer définitivement "${p.name}" ? Cette action est irréversible.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.7),
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              side: BorderSide(color: Theme.of(context).colorScheme.outline),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (result == true) {
      _deleteProduct(context, ref, p);
    }
  }

  Future<void> _deleteProduct(BuildContext context, WidgetRef ref, Product p) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final cs = Theme.of(context).colorScheme;

    try {
      final service = ref.read(productServiceProvider);
      await service.delete(p.id!);
      ref.invalidate(productsByCategoryProvider(p.categoryId));
      messenger.showSnackBar(
          buildAppSnack(cs, '🗑️ Produit supprimé avec succès', type: SnackType.success)
      );
      if (navigator.canPop()) navigator.pop(true);
    } catch (e) {
      messenger.showSnackBar(
          buildAppSnack(cs, '❌ Erreur lors de la suppression: $e', type: SnackType.error)
      );
    }
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha:0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface.withValues(alpha:0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}