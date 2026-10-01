import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/checkout_provider.dart';

class ConfirmationStepWidget extends ConsumerWidget {
  final VoidCallback onContinueShopping;

  const ConfirmationStepWidget({super.key, required this.onContinueShopping});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final checkoutState = ref.watch(checkoutProvider);
    final order = checkoutState.placedOrder;
    final isPaid = checkoutState.isPaid;
    final paymentMethod = checkoutState.paymentMethod;
    final transactionId =
        checkoutState.temboTransactionId ?? order?.paymentInfo.transactionId;

    final orderNumber = order?.orderNumber ??
        'BFA${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final totalAmount = order?.totalAmount ?? 0.0;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 12.h),

              // Success Icon
              Container(
                width: 100.w,
                height: 100.h,
                decoration: BoxDecoration(
                  color: isPaid
                      ? Colors.green.shade50
                      : theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isPaid ? Colors.green.shade300 : theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 56.sp,
                  color: isPaid ? Colors.green.shade600 : theme.colorScheme.primary,
                ),
              ),
              SizedBox(height: 16.h),

              // Success Title
              Text(
                isPaid ? 'Payment Received & Order Placed!' : 'Order Placed Successfully!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isPaid ? Colors.green.shade700 : theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),

              // Success Subtitle
              Text(
                isPaid
                    ? 'Your payment via TemboPlus has been verified. The seller will prepare your delivery.'
                    : 'Your order has been confirmed. Please have exact cash ready at delivery.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),

              // Payment Status Banner (PAID badge)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: isPaid ? Colors.green.shade50 : Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isPaid ? Colors.green.shade400 : Colors.amber.shade400,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPaid ? Icons.verified_user_rounded : Icons.pending_actions_rounded,
                      color: isPaid ? Colors.green.shade700 : Colors.amber.shade800,
                      size: 28.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: isPaid
                                      ? Colors.green.shade700
                                      : Colors.amber.shade700,
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  isPaid ? 'PAID' : 'PENDING PAYMENT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (isPaid) ...[
                                SizedBox(width: 6.w),
                                Text(
                                  '• TemboPlus Verified',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.green.shade800,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (transactionId != null && transactionId.isNotEmpty) ...[
                            SizedBox(height: 4.h),
                            Text(
                              'Txn ID: $transactionId',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: isPaid
                                    ? Colors.green.shade900
                                    : Colors.amber.shade900,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Order Details Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          color: theme.colorScheme.primary,
                          size: 22.sp,
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          'Order #$orderNumber',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),

                    _buildDetailRow(
                      theme,
                      'Order Date',
                      _formatDate(order?.orderDate ?? DateTime.now()),
                      Icons.calendar_today_outlined,
                    ),
                    SizedBox(height: 10.h),

                    _buildDetailRow(
                      theme,
                      'Payment Method',
                      paymentMethod?.displayName ?? 'Mobile Money',
                      Icons.payment_outlined,
                    ),
                    SizedBox(height: 10.h),

                    if (paymentMethod?.phoneNumber != null) ...[
                      _buildDetailRow(
                        theme,
                        'Payer Phone',
                        paymentMethod!.phoneNumber!,
                        Icons.phone_iphone_outlined,
                      ),
                      SizedBox(height: 10.h),
                    ],

                    _buildDetailRow(
                      theme,
                      'Amount Paid',
                      totalAmount > 0
                          ? CurrencyFormatter.formatTZS(totalAmount)
                          : 'TZS --',
                      Icons.monetization_on_outlined,
                      highlight: true,
                    ),
                    SizedBox(height: 10.h),

                    if (checkoutState.deliveryAddress != null) ...[
                      _buildDetailRow(
                        theme,
                        'Delivery Recipient',
                        '${checkoutState.deliveryAddress!.recipientName} (${checkoutState.deliveryAddress!.city})',
                        Icons.person_pin_circle_outlined,
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Cart cleared notification banner
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.green.shade700,
                      size: 18.sp,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        'Your cart has been cleared. Track this order anytime in My Orders.',
                        style: TextStyle(
                          color: Colors.green.shade800,
                          fontSize: 12.sp,
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
                      icon: const Icon(Icons.list_alt_rounded),
                      label: const Text('View My Orders'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),

                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: OutlinedButton.icon(
                      onPressed: onContinueShopping,
                      icon: const Icon(Icons.shopping_bag_outlined),
                      label: const Text('Continue Shopping'),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    ThemeData theme,
    String label,
    String value,
    IconData icon, {
    bool highlight = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: theme.colorScheme.onSurfaceVariant),
        SizedBox(width: 10.w),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Flexible(
                child: Text(
                  value,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
                    color: highlight ? theme.colorScheme.primary : null,
                  ),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
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
