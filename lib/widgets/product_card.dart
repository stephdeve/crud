import 'dart:io';

import 'package:flutter/material.dart';
import '../utils/format.dart';

class ProductCard extends StatelessWidget {
  final int? id;
  final String title;
  final double price;
  final String? image;
  final VoidCallback? onTap;
  final String? meta;

  const ProductCard({
    super.key,
    this.id,
    required this.title,
    required this.price,
    this.image,
    this.onTap,
    this.meta,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Hero(
                tag: 'product-image-${id ?? title}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 84,
                    height: 84,
                    color: color.primary.withValues(alpha: 0.06),
                    child: _buildImage(color),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatPrice(price),
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(color: color.primary, fontWeight: FontWeight.w600),
                    ),
                    if (meta != null && meta!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(meta!, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black.withValues(alpha: 0.6))),
                    ],
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildImage(ColorScheme color) {
    if (image != null && image!.isNotEmpty) {
      return Image.file(
        File(image!),
        fit: BoxFit.cover,
      );
    }
    return Center(child: Icon(Icons.image_outlined, color: color.primary));
  }
}
