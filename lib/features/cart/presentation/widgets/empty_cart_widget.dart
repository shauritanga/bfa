import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class EmptyCartWidget extends StatelessWidget {
  final bool wasRecentlyCleared;

  const EmptyCartWidget({super.key, this.wasRecentlyCleared = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty Cart Icon
            Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                color: wasRecentlyCleared
                    ? Colors.green.withValues(alpha: 0.1)
                    : theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                wasRecentlyCleared
                    ? Icons.check_circle_outline
                    : Icons.shopping_cart_outlined,
                size: 60.w,
                color: wasRecentlyCleared
                    ? Colors.green
                    : theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            SizedBox(height: 24.h),

            // Title
            Text(
              wasRecentlyCleared
                  ? 'Order placed successfully!'
                  : 'Your cart is empty',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: wasRecentlyCleared
                    ? Colors.green
                    : theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),

            // Description
            Text(
              wasRecentlyCleared
                  ? 'Your cart has been cleared and items moved to your orders. You can track your order progress in the orders section.'
                  : 'Looks like you haven\'t added any fresh produce to your cart yet. Start shopping to fill it up!',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),

            // Action Buttons
            Column(
              children: [
                if (wasRecentlyCleared) ...[
                  // View Orders Button (primary action when cart was cleared)
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/profile/orders'),
                      icon: const Icon(Icons.list_alt),
                      label: const Text('View My Orders'),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Continue Shopping Button (secondary action)
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/products'),
                      icon: const Icon(Icons.shopping_bag_outlined),
                      label: const Text('Continue Shopping'),
                    ),
                  ),
                ] else ...[
                  // Browse Products Button
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: () => context.push('/products'),
                      child: const Text('Browse Products'),
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: 24.h),

            // Quick Actions
            Text(
              'Quick Actions',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 16.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickAction(
                  context: context,
                  icon: Icons.local_florist,
                  label: 'Fresh',
                  onTap: () => context.push('/products?filter=fresh'),
                  theme: theme,
                ),
                _buildQuickAction(
                  context: context,
                  icon: Icons.eco,
                  label: 'Organic',
                  onTap: () => context.push('/products?filter=organic'),
                  theme: theme,
                ),
                _buildQuickAction(
                  context: context,
                  icon: Icons.star,
                  label: 'Featured',
                  onTap: () => context.push('/products?filter=featured'),
                  theme: theme,
                ),
                _buildQuickAction(
                  context: context,
                  icon: Icons.local_offer,
                  label: 'Deals',
                  onTap: () => context.push('/products?filter=discounted'),
                  theme: theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: 64.w,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Column(
          children: [
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                size: 24.w,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
