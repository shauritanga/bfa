import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../features/cart/presentation/providers/cart_provider.dart';
import '../../core/router/app_routes.dart';

/// Floating Action Button for cart with badge showing item count
class CartFAB extends ConsumerWidget {
  final String? heroTag;
  final VoidCallback? onPressed;

  const CartFAB({
    super.key,
    this.heroTag,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final cartItemCount = cartState.cart?.itemCount ?? 0;
    final theme = Theme.of(context);

    return Stack(
      children: [
        FloatingActionButton(
          heroTag: heroTag,
          onPressed: onPressed ?? () {
            context.pushNamed(AppRoute.cart.name);
          },
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          child: const Icon(Icons.shopping_cart),
        ),
        if (cartItemCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                borderRadius: BorderRadius.circular(12.r),
              ),
              constraints: BoxConstraints(
                minWidth: 20.w,
                minHeight: 20.h,
              ),
              child: Text(
                cartItemCount > 99 ? '99+' : cartItemCount.toString(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onError,
                  fontWeight: FontWeight.bold,
                  fontSize: 10.sp,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

/// Mini cart widget that can be used in app bars or other places
class MiniCartWidget extends ConsumerWidget {
  final VoidCallback? onTap;
  final Color? iconColor;
  final double? iconSize;

  const MiniCartWidget({
    super.key,
    this.onTap,
    this.iconColor,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final cartItemCount = cartState.cart?.itemCount ?? 0;
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap ?? () {
        context.pushNamed(AppRoute.cart.name);
      },
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.all(8.w),
        child: Stack(
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              color: iconColor ?? theme.colorScheme.onSurface,
              size: iconSize ?? 24.sp,
            ),
            if (cartItemCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 14.w,
                    minHeight: 14.h,
                  ),
                  child: Text(
                    cartItemCount > 99 ? '99+' : cartItemCount.toString(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onError,
                      fontWeight: FontWeight.bold,
                      fontSize: 8.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Cart summary widget showing total items and price
class CartSummaryWidget extends ConsumerWidget {
  final VoidCallback? onTap;
  final bool showPrice;

  const CartSummaryWidget({
    super.key,
    this.onTap,
    this.showPrice = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final cart = cartState.cart;
    final theme = Theme.of(context);

    if (cart == null || cart.isEmpty) {
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: onTap ?? () {
        context.pushNamed(AppRoute.cart.name);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart,
              color: theme.colorScheme.onPrimaryContainer,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              '${cart.itemCount} item${cart.itemCount != 1 ? 's' : ''}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (showPrice) ...[
              SizedBox(width: 8.w),
              Text(
                '•',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '\$${cart.total.toStringAsFixed(2)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            SizedBox(width: 4.w),
            Icon(
              Icons.arrow_forward_ios,
              color: theme.colorScheme.onPrimaryContainer,
              size: 14.sp,
            ),
          ],
        ),
      ),
    );
  }
}
