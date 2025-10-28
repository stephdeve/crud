import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  final ok = await confirm(context, title: 'Supprimer', message: 'Confirmer la suppression de ce produit ?', danger: true);
                  if (ok == true) {
                    final service = ref.read(productServiceProvider);
                    await service.delete(p.id!);
                    ref.invalidate(productsByCategoryProvider(p.categoryId));
                    if (navigator.canPop()) navigator.pop(true);
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
                    const SizedBox(height: 12),
                    if ((p.createdByName ?? '').isNotEmpty || (p.createdAt ?? '').isNotEmpty)
                      Text(
                        'Par ${p.createdByName ?? '-'} • ${p.createdAt != null ? DateTime.tryParse(p.createdAt!) != null ? 'Créé ${DateTime.tryParse(p.createdAt!)!.day.toString().padLeft(2, '0')}/${DateTime.tryParse(p.createdAt!)!.month.toString().padLeft(2, '0')}/${DateTime.tryParse(p.createdAt!)!.year} ${DateTime.tryParse(p.createdAt!)!.hour.toString().padLeft(2, '0')}:${DateTime.tryParse(p.createdAt!)!.minute.toString().padLeft(2, '0')}' : '' : ''}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    if ((p.updatedByName ?? '').isNotEmpty || (p.updatedAt ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          'MAJ ${p.updatedAt != null ? DateTime.tryParse(p.updatedAt!) != null ? '${DateTime.tryParse(p.updatedAt!)!.day.toString().padLeft(2, '0')}/${DateTime.tryParse(p.updatedAt!)!.month.toString().padLeft(2, '0')}/${DateTime.tryParse(p.updatedAt!)!.year} ${DateTime.tryParse(p.updatedAt!)!.hour.toString().padLeft(2, '0')}:${DateTime.tryParse(p.updatedAt!)!.minute.toString().padLeft(2, '0')}' : '' : ''} par ${p.updatedByName ?? '-'}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
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
