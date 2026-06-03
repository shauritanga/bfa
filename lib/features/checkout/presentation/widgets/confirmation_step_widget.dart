import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';

class ConfirmationStepWidget extends ConsumerWidget {
  final VoidCallback onContinueShopping;

  const ConfirmationStepWidget({super.key, required this.onContinueShopping});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20.h), // Add some top spacing
              // Success Icon
              Container(
                width: 120.w,
                height: 120.h,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  size: 60.sp,
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(height: 24.h),

              // Success Title
              Text(
                'Order Placed Successfully!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),

              // Success Message
              Text(
                'Your order has been confirmed and will be processed soon.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 6.h),

              Text(
                'You will receive a confirmation email shortly.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),

              // Order Details Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          color: theme.colorScheme.primary,
                          size: 24.sp,
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'Order #BFA${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    _buildDetailRow(
                      theme,
                      'Order Date',
                      _formatDate(DateTime.now()),
                      Icons.calendar_today_outlined,
                    ),
                    SizedBox(height: 12.h),

                    _buildDetailRow(
                      theme,
                      'Estimated Delivery',
                      _formatDate(DateTime.now().add(const Duration(days: 2))),
                      Icons.local_shipping_outlined,
                    ),
                    SizedBox(height: 12.h),

                    _buildDetailRow(
                      theme,
                      'Payment Method',
                      'Cash on Delivery', // This should come from checkout state
                      Icons.payment_outlined,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Cart cleared notification
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.green,
                      size: 20.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Your cart has been cleared. Items are now in your orders.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Action Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.pushNamed(AppRoute.orders.name);
                      },
                      icon: const Icon(Icons.list_alt),
                      label: const Text('View Orders'),
                    ),
                  ),
                  SizedBox(height: 8.h),

                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: OutlinedButton.icon(
                      onPressed: onContinueShopping,
                      icon: const Icon(Icons.shopping_bag_outlined),
                      label: const Text('Continue Shopping'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h), // Add some bottom spacing
            ], // Close children
          ), // Close Column
        ), // Close SingleChildScrollView
      ), // Close SafeArea
    ); // Close Scaffold
  }

  Widget _buildDetailRow(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: theme.colorScheme.onSurfaceVariant),
        SizedBox(width: 12.w),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
