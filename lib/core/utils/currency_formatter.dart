import 'package:intl/intl.dart';

/// Utility class for formatting currency in Tanzania Shillings
class CurrencyFormatter {
  static const String _currencySymbol = 'TZS';
  static const String _currencyCode = 'TZS';
  
  /// Format amount to Tanzania Shillings with proper formatting
  static String formatTZS(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'sw_TZ', // Swahili Tanzania locale
      symbol: '$_currencySymbol ',
      decimalDigits: 0, // TZS typically doesn't use decimal places
    );
    return formatter.format(amount);
  }

  /// Format amount to TZS without symbol (just the number)
  static String formatTZSAmount(double amount) {
    final formatter = NumberFormat('#,##0', 'sw_TZ');
    return formatter.format(amount);
  }

  /// Format amount with custom symbol
  static String formatWithSymbol(double amount, {String symbol = 'TZS'}) {
    final formatter = NumberFormat('#,##0', 'sw_TZ');
    return '$symbol ${formatter.format(amount)}';
  }

  /// Convert USD to TZS (approximate rate - in real app, get from API)
  static double usdToTzs(double usdAmount) {
    const double exchangeRate = 2500.0; // Approximate rate
    return usdAmount * exchangeRate;
  }

  /// Parse TZS string back to double
  static double parseTZS(String tzsString) {
    // Remove currency symbols and spaces
    String cleanString = tzsString
        .replaceAll('TZS', '')
        .replaceAll(',', '')
        .trim();
    
    return double.tryParse(cleanString) ?? 0.0;
  }

  /// Get currency symbol
  static String get currencySymbol => _currencySymbol;
  
  /// Get currency code
  static String get currencyCode => _currencyCode;

  /// Format for display in lists (shorter format)
  static String formatCompact(double amount) {
    if (amount >= 1000000) {
      return 'TZS ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return 'TZS ${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return formatTZS(amount);
    }
  }

  /// Format for order summaries
  static String formatOrderAmount(double amount) {
    return formatWithSymbol(amount, symbol: 'TZS');
  }

  /// Format delivery fee
  static String formatDeliveryFee(double fee) {
    if (fee == 0) {
      return 'Free';
    }
    return formatTZS(fee);
  }
}
