import 'package:flutter/material.dart';

// CategoryCard avec support des couleurs personnalisées
class CategoryCard extends StatelessWidget {
  final String title;
  final String? image;
  final int productCount;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Color? backgroundColor;
  final Color? accentColor;

  const CategoryCard({
    super.key,
    required this.title,
    this.image,
    required this.productCount,
    required this.onTap,
    required this.onLongPress,
    this.backgroundColor,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = backgroundColor ?? colorScheme.surface;
    final accent = accentColor ?? colorScheme.primary;

    return Card(
      elevation: 0,
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outline,
          width: 0.2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icone de la catégorie avec couleur d'accent
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.category_rounded,
                  color: accent,
                  size: 24,
                ),
              ),
              const Spacer(),
              // Titre de la catégorie
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Compteur de produits
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$productCount produit${productCount > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}