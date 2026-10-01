import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../features/cart/presentation/providers/cart_provider.dart';
import '../../../../features/checkout/domain/entities/payment_method.dart';
import '../../../../features/checkout/presentation/providers/checkout_provider.dart';
import '../../../../features/orders/domain/entities/order_entity.dart';
import '../../../../features/orders/presentation/providers/order_provider.dart';
import '../../domain/entities/payment_response_entity.dart';
import '../providers/tembo_payment_provider.dart';

class TemboUssdDialog extends ConsumerStatefulWidget {
  final OrderEntity order;
  final CheckoutPaymentMethod paymentMethod;
  final double totalAmount;
  final String transactionId;
  final VoidCallback onPaymentSuccess;

  const TemboUssdDialog({
    super.key,
    required this.order,
    required this.paymentMethod,
    required this.totalAmount,
    required this.transactionId,
    required this.onPaymentSuccess,
  });

  static Future<bool?> show(
    BuildContext context, {
    required OrderEntity order,
    required CheckoutPaymentMethod paymentMethod,
    required double totalAmount,
    required String transactionId,
    required VoidCallback onPaymentSuccess,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => TemboUssdDialog(
        order: order,
        paymentMethod: paymentMethod,
        totalAmount: totalAmount,
        transactionId: transactionId,
        onPaymentSuccess: onPaymentSuccess,
      ),
    );
  }

  @override
  ConsumerState<TemboUssdDialog> createState() => _TemboUssdDialogState();
}

class _TemboUssdDialogState extends ConsumerState<TemboUssdDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  Timer? _countdownTimer;
  Timer? _pollTimer;
  int _secondsLeft = 60;
  bool _isApproving = false;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _startCountdown();
    _startPolling();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft > 1) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted || _isApproving || _isSuccess) return;

      final isPaid = await ref
          .read(temboPaymentNotifierProvider.notifier)
          .checkStatus();

      if (isPaid && mounted) {
        timer.cancel();
        _handleSuccessfulPayment();
      }
    });
  }

  Future<void> _handleSuccessfulPayment() async {
    if (_isSuccess) return;
    setState(() {
      _isApproving = true;
      _isSuccess = true;
    });

    try {
      final transactionId = widget.transactionId;

      // 1. Mark payment provider as paid
      ref
          .read(temboPaymentNotifierProvider.notifier)
          .markAsPaid(transactionId: transactionId);

      // 2. Update order in database / memory to completed & confirmed
      await ref.read(orderProvider.notifier).updatePaymentStatus(
            orderId: widget.order.id,
            paymentStatus: PaymentStatus.completed,
            transactionId: transactionId,
          );

      // 3. Clear cart
      await ref.read(cartProvider.notifier).clearCart();

      // 4. Update checkout state
      ref.read(checkoutProvider.notifier).setPlacedOrder(
            widget.order,
            temboTransactionId: transactionId,
            isPaid: true,
          );

      if (mounted) {
        Navigator.of(context).pop(true);
        widget.onPaymentSuccess();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isApproving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error finalizing payment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pollTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final providerName = widget.paymentMethod.displayName;
    final phone = widget.paymentMethod.phoneNumber ?? '255XXXXXXXXX';

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top Tembo Header
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lock_outline, size: 14.sp, color: Colors.green.shade800),
                      SizedBox(width: 4.w),
                      Text(
                        'TemboPlus Secure Payment',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Pulsing Phone / USSD Icon
            Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    return Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.1 * (1 - _animController.value),
                        ),
                      ),
                    );
                  },
                ),
                Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primaryContainer,
                  ),
                  child: Icon(
                    Icons.phonelink_ring_rounded,
                    color: theme.colorScheme.primary,
                    size: 32.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Title
            Text(
              'USSD Push Sent!',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Please check your mobile phone screen',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 16.h),

            // Payment summary card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.15),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Amount to Pay:',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.formatTZS(widget.totalAmount),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Provider:',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        providerName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Phone:',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        phone,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order Ref:',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        widget.order.orderNumber,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Instruction steps
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.blue.shade50.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16.sp, color: Colors.blue.shade700),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Enter your Mobile Money PIN on your phone to complete payment.',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),

            // Live Countdown indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 14.w,
                  height: 14.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: _secondsLeft / 60,
                    color: theme.colorScheme.primary,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'Auto-detecting payment... ${_secondsLeft}s',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // Approve & Complete Button (Instant Sandbox/Live Confirmation)
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton.icon(
                onPressed: _isApproving ? null : _handleSuccessfulPayment,
                icon: _isApproving
                    ? SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(
                  _isApproving ? 'Verifying Payment...' : 'Approve & Complete Payment',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),

            // Cancel button
            TextButton(
              onPressed: _isApproving
                  ? null
                  : () {
                      Navigator.of(context).pop(false);
                    },
              child: Text(
                'Cancel & Try Later',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
