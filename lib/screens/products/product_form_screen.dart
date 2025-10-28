import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/product.dart';
import '../../models/category.dart';
import '../../providers.dart';
import '../../utils/overlays.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final int categoryId;
  final Product? product;
  const ProductFormScreen({super.key, required this.categoryId, this.product});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  int? _selectedCategoryId;
  String? _imagePath;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.product?.name ?? '');
    _descCtrl = TextEditingController(text: widget.product?.description ?? '');
    _priceCtrl = TextEditingController(text: widget.product?.price.toString() ?? '');
    _selectedCategoryId = widget.product?.categoryId ?? widget.categoryId;
    _imagePath = widget.product?.image;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (xfile != null) {
      setState(() {
        _imagePath = xfile.path;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      showAppSnack(context, 'Veuillez choisir une catégorie', type: SnackType.warning);
      return;
    }
    setState(() => _saving = true);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final cs = Theme.of(context).colorScheme;
    try {
      final service = ref.read(productServiceProvider);
      final product = Product(
        id: widget.product?.id,
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        price: double.parse(_priceCtrl.text.trim().replaceAll(',', '.')),
        image: _imagePath,
        categoryId: _selectedCategoryId!,
      );
      if (widget.product == null) {
        await service.create(product);
        messenger.showSnackBar(buildAppSnack(cs, 'Produit ajouté', type: SnackType.success));
      } else {
        await service.update(product);
        messenger.showSnackBar(buildAppSnack(cs, 'Produit modifié', type: SnackType.success));
      }
      ref.invalidate(productsByCategoryProvider(_selectedCategoryId!));
      ref.invalidate(categoriesWithCountProvider);
      if (navigator.canPop()) navigator.pop(true);
    } catch (e) {
      messenger.showSnackBar(buildAppSnack(cs, 'Erreur: $e', type: SnackType.error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final color = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.product == null ? 'Ajouter un produit' : 'Modifier le produit'),
        actions: [
          if (widget.product != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                final cs = Theme.of(context).colorScheme;
                final ok = await confirm(context, title: 'Supprimer', message: 'Confirmer la suppression de ce produit ?', danger: true);
                if (ok == true) {
                  final service = ref.read(productServiceProvider);
                  await service.delete(widget.product!.id!);
                  ref.invalidate(productsByCategoryProvider(widget.product!.categoryId));
                  ref.invalidate(categoriesWithCountProvider);
                  messenger.showSnackBar(buildAppSnack(cs, 'Produit supprimé', type: SnackType.success));
                  if (navigator.canPop()) navigator.pop(true);
                }
              },
            )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: color.primary.withValues(alpha: 0.1),
                  backgroundImage: _imagePath != null ? FileImage(File(_imagePath!)) : null,
                  child: _imagePath == null ? Icon(Icons.add_a_photo, color: color.primary) : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nom'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Nom requis' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _priceCtrl,
              decoration: const InputDecoration(labelText: 'Prix'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
              validator: (v) {
                final t = v?.trim();
                if (t == null || t.isEmpty) return 'Prix requis';
                return double.tryParse(t.replaceAll(',', '.')) == null ? 'Prix invalide' : null;
              },
            ),
            const SizedBox(height: 12),
            categoriesAsync.when(
              loading: () => const Center(child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  )),
              error: (e, _) => Text('Erreur de catégories: $e'),
              data: (cats) {
                return DropdownButtonFormField<int>(
                  initialValue: _selectedCategoryId,
                  items: cats
                      .map((Category c) => DropdownMenuItem<int>(
                            value: c.id,
                            child: Text(c.name),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategoryId = v),
                  decoration: const InputDecoration(labelText: 'Catégorie'),
                );
              },
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.save_outlined),
              label: Text(_saving ? 'Enregistrement...' : 'Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}
