import 'dart:io';

import 'package:flutter/material.dart';
import '../utils/format.dart';

class ProductCard extends StatelessWidget {
  final int? id;
  final String title;
  final double price;
  final String? image;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    this.id,
    required this.title,
    required this.price,
    this.image,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline,
          width: 0.2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image du produit
              _buildImageSection(colorScheme, context),
              const SizedBox(width: 16),

              // Informations du produit (nom + prix en colonne)
              Expanded(
                child: _buildInfoSection(colorScheme, context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(ColorScheme colorScheme, BuildContext context) {
    return Hero(
      tag: 'product-image-${id ?? title}',
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: colorScheme.primary.withOpacity(0.05),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.1),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: image != null && image!.isNotEmpty
              ? Image.file(
            File(image!),
            fit: BoxFit.cover,
            width: 80,
            height: 80,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholderIcon(colorScheme);
            },
          )
              : _buildPlaceholderIcon(colorScheme),
        ),
      ),
    );
  }

  Widget _buildInfoSection(ColorScheme colorScheme, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
            height: 1.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            formatPrice(price),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderIcon(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_rounded,
            size: 24,
            color: colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 4),
          Text(
            'Image',
            style: TextStyle(
              fontSize: 9,
              color: colorScheme.primary.withOpacity(0.3),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}