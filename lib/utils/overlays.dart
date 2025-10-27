import 'package:flutter/material.dart';

enum SnackType { success, info, warning, error }

void showAppSnack(BuildContext context, String message, {SnackType type = SnackType.info, String? actionLabel, VoidCallback? onAction}) {
  final cs = Theme.of(context).colorScheme;
  Color bg;
  IconData icon;
  switch (type) {
    case SnackType.success:
      bg = cs.primary.withValues(alpha: 0.90);
      icon = Icons.check_circle_rounded;
      break;
    case SnackType.warning:
      bg = cs.secondary.withValues(alpha: 0.90);
      icon = Icons.warning_amber_rounded;
      break;
    case SnackType.error:
      bg = cs.error.withValues(alpha: 0.90);
      icon = Icons.error_rounded;
      break;
    case SnackType.info:
      bg = cs.inverseSurface.withValues(alpha: 0.95);
      icon = Icons.info_rounded;
  }

  final snack = SnackBar(
    behavior: SnackBarBehavior.floating,
    backgroundColor: bg,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    content: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: cs.onPrimary, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(message, style: TextStyle(color: cs.onPrimary))),
      ],
    ),
    action: (actionLabel != null && onAction != null)
        ? SnackBarAction(label: actionLabel, onPressed: onAction, textColor: cs.onPrimary)
        : null,
    duration: const Duration(seconds: 3),
  );
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(snack);
}

Future<bool> confirm(BuildContext context, {required String title, required String message, String confirmText = 'Confirmer', String cancelText = 'Annuler', bool danger = false}) async {
  final cs = Theme.of(context).colorScheme;
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(danger ? Icons.delete_forever_rounded : Icons.help_outline_rounded, color: danger ? cs.error : cs.primary),
            const SizedBox(width: 8),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(cancelText)),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(ctx, true),
            style: danger ? FilledButton.styleFrom(backgroundColor: cs.error) : null,
            child: Text(confirmText),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
