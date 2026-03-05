import 'package:intl/intl.dart';

extension DoubleExtensions on double {
  String toCurrency({String symbol = 'HUF ', int decimals = 2}) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimals,
    );
    return formatter.format(this);
  }

  String toSign({bool isExpense = false}) {
    final prefix = isExpense ? '-' : '+';
    return '$prefix${toCurrency()}';
  }

  String toCompactCurrency({String symbol = 'HUF '}) {
    if (abs() >= 1000000) {
      return '$symbol${(this / 1000000).toStringAsFixed(1)}M';
    } else if (abs() >= 1000) {
      return '$symbol${(this / 1000).toStringAsFixed(1)}K';
    }
    return toCurrency(symbol: symbol);
  }

  String toPercentageString() {
    return '${toStringAsFixed(1)}%';
  }
}

extension IntExtensions on int {
  String toOrdinal() {
    if (this >= 11 && this <= 13) {
      return '${this}th';
    }
    switch (this % 10) {
      case 1:
        return '${this}st';
      case 2:
        return '${this}nd';
      case 3:
        return '${this}rd';
      default:
        return '${this}th';
    }
  }
}
