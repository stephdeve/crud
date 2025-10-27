import 'package:intl/intl.dart';

String formatPrice(double value) {
  final format = NumberFormat.currency(locale: 'fr_FR', symbol: '€');
  return format.format(value);
}
