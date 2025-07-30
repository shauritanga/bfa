import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Badge to indicate organic products
class OrganicBadge extends StatelessWidget {
  final bool isOrganic;
  final double size;
  final EdgeInsetsGeometry? padding;
  final bool showText;

  const OrganicBadge({
    super.key,
    required this.isOrganic,
    this.size = 24.0,
    this.padding,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOrganic) return const SizedBox.shrink();

    final theme = Theme.of(context);
    
    return Container(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.green.shade300,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.eco,
            size: size.sp,
            color: Colors.green.shade700,
          ),
          if (showText) ...[
            SizedBox(width: 4.w),
            Text(
              'Organic',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
                fontSize: (size * 0.6).sp,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Featured product badge
class FeaturedBadge extends StatelessWidget {
  final bool isFeatured;
  final double size;
  final EdgeInsetsGeometry? padding;

  const FeaturedBadge({
    super.key,
    required this.isFeatured,
    this.size = 24.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (!isFeatured) return const SizedBox.shrink();

    final theme = Theme.of(context);
    
    return Container(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.orange.shade300,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: size.sp,
            color: Colors.orange.shade700,
          ),
          SizedBox(width: 4.w),
          Text(
            'Featured',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.orange.shade700,
              fontWeight: FontWeight.w600,
              fontSize: (size * 0.6).sp,
            ),
          ),
        ],
      ),
    );
  }
}

/// Fresh product badge
class FreshBadge extends StatelessWidget {
  final DateTime harvestDate;
  final double size;
  final EdgeInsetsGeometry? padding;
  final int freshDaysThreshold;

  const FreshBadge({
    super.key,
    required this.harvestDate,
    this.size = 24.0,
    this.padding,
    this.freshDaysThreshold = 3,
  });

  @override
  Widget build(BuildContext context) {
    final daysSinceHarvest = DateTime.now().difference(harvestDate).inDays;
    
    if (daysSinceHarvest > freshDaysThreshold) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    
    return Container(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.lightGreen.shade100,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.lightGreen.shade300,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule,
            size: size.sp,
            color: Colors.lightGreen.shade700,
          ),
          SizedBox(width: 4.w),
          Text(
            _getFreshText(daysSinceHarvest),
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.lightGreen.shade700,
              fontWeight: FontWeight.w600,
              fontSize: (size * 0.6).sp,
            ),
          ),
        ],
      ),
    );
  }

  String _getFreshText(int days) {
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    return '${days}d ago';
  }
}

/// Local product badge
class LocalBadge extends StatelessWidget {
  final String location;
  final double size;
  final EdgeInsetsGeometry? padding;

  const LocalBadge({
    super.key,
    required this.location,
    this.size = 24.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.blue.shade300,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on,
            size: size.sp,
            color: Colors.blue.shade700,
          ),
          SizedBox(width: 4.w),
          Text(
            'Local',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.blue.shade700,
              fontWeight: FontWeight.w600,
              fontSize: (size * 0.6).sp,
            ),
          ),
        ],
      ),
    );
  }
}

/// Availability badge
class AvailabilityBadge extends StatelessWidget {
  final bool isAvailable;
  final double quantity;
  final String unit;
  final double size;
  final EdgeInsetsGeometry? padding;

  const AvailabilityBadge({
    super.key,
    required this.isAvailable,
    required this.quantity,
    required this.unit,
    this.size = 24.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (!isAvailable) {
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
        child: Text(
          'Out of Stock',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.red.shade700,
            fontWeight: FontWeight.w600,
            fontSize: (size * 0.6).sp,
          ),
        ),
      );
    }

    // Show low stock warning
    if (quantity <= 5) {
      return Container(
        padding: padding ?? EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: Colors.orange.shade100,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Colors.orange.shade300,
            width: 1,
          ),
        ),
        child: Text(
          'Only ${quantity.toInt()} $unit left',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.orange.shade700,
            fontWeight: FontWeight.w600,
            fontSize: (size * 0.6).sp,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

/// Combined product badges widget
class ProductBadges extends StatelessWidget {
  final bool isOrganic;
  final bool isFeatured;
  final DateTime? harvestDate;
  final String? location;
  final bool isAvailable;
  final double quantity;
  final String unit;
  final double size;
  final Axis direction;
  final double spacing;

  const ProductBadges({
    super.key,
    required this.isOrganic,
    required this.isFeatured,
    this.harvestDate,
    this.location,
    required this.isAvailable,
    required this.quantity,
    required this.unit,
    this.size = 20.0,
    this.direction = Axis.horizontal,
    this.spacing = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    final badges = <Widget>[];

    // Add organic badge
    if (isOrganic) {
      badges.add(OrganicBadge(isOrganic: true, size: size));
    }

    // Add featured badge
    if (isFeatured) {
      badges.add(FeaturedBadge(isFeatured: true, size: size));
    }

    // Add fresh badge
    if (harvestDate != null) {
      badges.add(FreshBadge(harvestDate: harvestDate!, size: size));
    }

    // Add local badge
    if (location != null && location!.isNotEmpty) {
      badges.add(LocalBadge(location: location!, size: size));
    }

    // Add availability badge
    badges.add(AvailabilityBadge(
      isAvailable: isAvailable,
      quantity: quantity,
      unit: unit,
      size: size,
    ));

    if (badges.isEmpty) return const SizedBox.shrink();

    if (direction == Axis.horizontal) {
      return Wrap(
        spacing: spacing.w,
        runSpacing: spacing.h,
        children: badges,
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: badges
            .map((badge) => Padding(
                  padding: EdgeInsets.only(bottom: spacing.h),
                  child: badge,
                ))
            .toList(),
      );
    }
  }
}
