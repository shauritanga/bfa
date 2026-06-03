import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/cart_summary_card.dart';
import '../widgets/empty_cart_widget.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  @override
  void initState() {
    super.initState();
    // Load cart when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // TODO: Get current user ID from auth provider
      const userId = 'current_user_id'; // Placeholder
      ref.read(cartProvider.notifier).setUser(userId);

      // Clear the recently cleared flag after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          ref.read(cartProvider.notifier).clearRecentlyClearedFlag();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        centerTitle: false,
        actions: [
          if (cartState.cart != null && cartState.cart!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showClearCartDialog(context),
            ),
        ],
      ),
      body: _buildBody(cartState, theme),
      bottomNavigationBar: cartState.cart != null && cartState.cart!.isNotEmpty
          ? _buildCheckoutButton(cartState, theme)
          : null,
    );
  }

  Widget _buildBody(CartState cartState, ThemeData theme) {
    if (cartState.isLoading) {
      return const Center(child: LoadingWidget());
    }

    if (cartState.error != null) {
      return Center(
        child: AppErrorWidget(
          message: cartState.error!,
          onRetry: () => ref.read(cartProvider.notifier).loadCart(),
        ),
      );
    }

    if (cartState.cart == null || cartState.cart!.isEmpty) {
      return EmptyCartWidget(wasRecentlyCleared: cartState.wasRecentlyCleared);
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(cartProvider.notifier).loadCart(),
      child: Column(
        children: [
          // Validation warnings
          if (cartState.validationResult != null &&
              cartState.validationResult!.hasIssues)
            _buildValidationWarnings(cartState.validationResult!, theme),

          // Cart items
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(AppConstants.defaultPadding.w),
              itemCount: cartState.cart!.items.length,
              itemBuilder: (context, index) {
                final item = cartState.cart!.items[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: CartItemCard(
                    item: item,
                    isUpdating: cartState.isUpdating,
                    onQuantityChanged: (quantity) {
                      ref
                          .read(cartProvider.notifier)
                          .updateItemQuantity(
                            productId: item.productId,
                            quantity: quantity,
                          );
                    },
                    onRemove: () {
                      ref
                          .read(cartProvider.notifier)
                          .removeItem(item.productId);
                    },
                  ),
                );
              },
            ),
          ),

          // Cart summary
          CartSummaryCard(
            cart: cartState.cart!,
            onApplyCoupon: (couponCode, discountAmount) {
              ref
                  .read(cartProvider.notifier)
                  .applyCoupon(
                    couponCode: couponCode,
                    discountAmount: discountAmount,
                  );
            },
            onRemoveCoupon: () {
              ref.read(cartProvider.notifier).removeCoupon();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildValidationWarnings(
    CartValidationResult validation,
    ThemeData theme,
  ) {
    return Container(
      margin: EdgeInsets.all(AppConstants.defaultPadding.w),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning,
                color: theme.colorScheme.onErrorContainer,
                size: 20.w,
              ),
              SizedBox(width: 8.w),
              Text(
                'Cart Issues',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          if (validation.unavailableItems.isNotEmpty) ...[
            Text(
              '• ${validation.unavailableItems.length} item(s) no longer available',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ],

          if (validation.itemsExceedingStock.isNotEmpty) ...[
            Text(
              '• ${validation.itemsExceedingStock.length} item(s) exceed available stock',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ],

          if (validation.priceChangedItems.isNotEmpty) ...[
            Text(
              '• ${validation.priceChangedItems.length} item(s) have price changes',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ],

          SizedBox(height: 8.h),
          TextButton(
            onPressed: () => ref.read(cartProvider.notifier).validateCart(),
            child: Text(
              'Refresh Cart',
              style: TextStyle(color: theme.colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton(CartState cartState, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(AppConstants.defaultPadding.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Total summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total (${cartState.itemCount} items)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  Helpers.formatCurrency(cartState.total),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),

            if (cartState.totalSavings > 0) ...[
              SizedBox(height: 4.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'You save',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    Helpers.formatCurrency(cartState.totalSavings),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],

            SizedBox(height: 16.h),

            // Checkout button
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: cartState.isValidForCheckout && !cartState.isUpdating
                    ? () => _proceedToCheckout()
                    : null,
                child: cartState.isUpdating
                    ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Proceed to Checkout'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text(
          'Are you sure you want to remove all items from your cart?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(cartProvider.notifier).clearCart();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _proceedToCheckout() {
    // Navigate to checkout page
    context.push('/cart/checkout');
  }
}
