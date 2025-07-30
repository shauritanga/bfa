import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Badge to display discount information
class DiscountBadge extends StatelessWidget {
  final double originalPrice;
  final double discountPrice;
  final double size;
  final EdgeInsetsGeometry? padding;
  final bool showPercentage;
  final bool showAmount;

  const DiscountBadge({
    super.key,
    required this.originalPrice,
    required this.discountPrice,
    this.size = 24.0,
    this.padding,
    this.showPercentage = true,
    this.showAmount = false,
  });

  @override
  Widget build(BuildContext context) {
    if (discountPrice >= originalPrice) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final discountPercentage = ((originalPrice - discountPrice) / originalPrice * 100).round();
    final discountAmount = originalPrice - discountPrice;

    return Container(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.red.shade600,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        _getDiscountText(discountPercentage, discountAmount),
        style: theme.textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: (size * 0.6).sp,
        ),
      ),
    );
  }

  String _getDiscountText(int percentage, double amount) {
    if (showPercentage && showAmount) {
      return '-$percentage% (${amount.toStringAsFixed(0)} TZS)';
    } else if (showAmount) {
      return '-${amount.toStringAsFixed(0)} TZS';
    } else {
      return '-$percentage%';
    }
  }
}

/// Price display with discount
class PriceDisplay extends StatelessWidget {
  final double price;
  final double? originalPrice;
  final String currency;
  final double fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final Color? originalPriceColor;
  final bool showCurrency;
  final MainAxisAlignment alignment;

  const PriceDisplay({
    super.key,
    required this.price,
    this.originalPrice,
    this.currency = 'TZS',
    this.fontSize = 16.0,
    this.fontWeight,
    this.color,
    this.originalPriceColor,
    this.showCurrency = true,
    this.alignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDiscount = originalPrice != null && originalPrice! > price;

    return Row(
      mainAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Current price
        Text(
          _formatPrice(price),
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: fontSize.sp,
            fontWeight: fontWeight ?? FontWeight.bold,
            color: color ?? (hasDiscount ? Colors.red.shade600 : null),
          ),
        ),

        // Original price (crossed out)
        if (hasDiscount) ...[
          SizedBox(width: 8.w),
          Text(
            _formatPrice(originalPrice!),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: (fontSize * 0.8).sp,
              color: originalPriceColor ?? theme.colorScheme.onSurfaceVariant,
              decoration: TextDecoration.lineThrough,
              decorationColor: originalPriceColor ?? theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  String _formatPrice(double price) {
    final formattedPrice = price.toStringAsFixed(0);
    if (showCurrency) {
      return '$formattedPrice $currency';
    }
    return formattedPrice;
  }
}

/// Savings display
class SavingsDisplay extends StatelessWidget {
  final double originalPrice;
  final double discountPrice;
  final String currency;
  final double fontSize;
  final Color? color;
  final bool showPercentage;
  final bool showAmount;

  const SavingsDisplay({
    super.key,
    required this.originalPrice,
    required this.discountPrice,
    this.currency = 'TZS',
    this.fontSize = 12.0,
    this.color,
    this.showPercentage = true,
    this.showAmount = true,
  });

  @override
  Widget build(BuildContext context) {
    if (discountPrice >= originalPrice) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final savings = originalPrice - discountPrice;
    final savingsPercentage = (savings / originalPrice * 100).round();

    return Text(
      _getSavingsText(savings, savingsPercentage),
      style: theme.textTheme.bodySmall?.copyWith(
        fontSize: fontSize.sp,
        color: color ?? Colors.green.shade600,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  String _getSavingsText(double savings, int percentage) {
    final parts = <String>[];
    
    if (showAmount) {
      parts.add('Save ${savings.toStringAsFixed(0)} $currency');
    }
    
    if (showPercentage) {
      parts.add('($percentage% off)');
    }
    
    return parts.join(' ');
  }
}

/// Bulk discount badge
class BulkDiscountBadge extends StatelessWidget {
  final int minQuantity;
  final double discountPercentage;
  final double size;
  final EdgeInsetsGeometry? padding;

  const BulkDiscountBadge({
    super.key,
    required this.minQuantity,
    required this.discountPercentage,
    this.size = 20.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.purple.shade100,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.purple.shade300,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_cart,
            size: size.sp,
            color: Colors.purple.shade700,
          ),
          SizedBox(width: 4.w),
          Text(
            'Buy $minQuantity+ get ${discountPercentage.toInt()}% off',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.purple.shade700,
              fontWeight: FontWeight.w600,
              fontSize: (size * 0.6).sp,
            ),
          ),
        ],
      ),
    );
  }
}

/// Limited time offer badge
class LimitedOfferBadge extends StatelessWidget {
  final DateTime expiryDate;
  final double size;
  final EdgeInsetsGeometry? padding;

  const LimitedOfferBadge({
    super.key,
    required this.expiryDate,
    this.size = 20.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    if (now.isAfter(expiryDate)) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final timeLeft = expiryDate.difference(now);
    
    return Container(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.red.shade300,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            size: size.sp,
            color: Colors.red.shade700,
          ),
          SizedBox(width: 4.w),
          Text(
            _formatTimeLeft(timeLeft),
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.red.shade700,
              fontWeight: FontWeight.w600,
              fontSize: (size * 0.6).sp,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeLeft(Duration timeLeft) {
    if (timeLeft.inDays > 0) {
      return '${timeLeft.inDays}d left';
    } else if (timeLeft.inHours > 0) {
      return '${timeLeft.inHours}h left';
    } else if (timeLeft.inMinutes > 0) {
      return '${timeLeft.inMinutes}m left';
    } else {
      return 'Ending soon';
    }
  }
}
