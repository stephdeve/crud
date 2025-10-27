import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import '../../utils/format.dart';
import 'product_form_screen.dart';

class ProductDetailScreen extends ConsumerWidget {
  final int productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProduct = ref.watch(productByIdProvider(productId));
    return asyncProduct.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(appBar: AppBar(), body: Center(child: Text('Erreur: $e'))),
      data: (p) {
        if (p == null) return const Scaffold(body: Center(child: Text('Produit introuvable')));
        final color = Theme.of(context).colorScheme;
        return Scaffold(
          appBar: AppBar(
            title: Text(p.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () async {
                  final updated = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => ProductFormScreen(categoryId: p.categoryId, product: p),
                    ),
                  );
                  if (updated == true) {
                    ref.invalidate(productByIdProvider(productId));
                    ref.invalidate(productsByCategoryProvider(p.categoryId));
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Supprimer'),
                      content: const Text('Confirmer la suppression de ce produit ?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
                        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer')),
                      ],
                    ),
                  );
                  if (ok == true) {
                    final service = ref.read(productServiceProvider);
                    await service.delete(p.id!);
                    ref.invalidate(productsByCategoryProvider(p.categoryId));
                    // Pop back to the list after delete.
                    if (Navigator.canPop(context)) {
                      Navigator.of(context).pop(true);
                    }
                  }
                },
              ),
            ],
          ),
          body: ListView(
            children: [
              Hero(
                tag: 'product-image-${p.id ?? p.name}',
                child: AspectRatio(
                  aspectRatio: 1.2,
                  child: Container(
                    color: color.primary.withValues(alpha: 0.06),
                    child: p.image != null && p.image!.isNotEmpty
                        ? Image.file(File(p.image!), fit: BoxFit.cover)
                        : Icon(Icons.image_outlined, color: color.primary, size: 64),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatPrice(p.price),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color.primary, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                    Text(p.description, style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 16),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
