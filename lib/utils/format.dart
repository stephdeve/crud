import 'package:intl/intl.dart';

String formatPrice(double value) {
  final format = NumberFormat.currency(locale: 'fr_FR', symbol: '€');
  return format.format(value);
}

String formatDateTime(String? iso) {
  if (iso == null || iso.isEmpty) return '';
  final dt = DateTime.tryParse(iso);
  if (dt == null) return iso;
  final fmt = DateFormat('dd/MM/yyyy HH:mm');
  return fmt.format(dt);
}
