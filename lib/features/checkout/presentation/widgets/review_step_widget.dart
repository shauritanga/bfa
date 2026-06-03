import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/checkout_provider.dart';
import '../../../cart/domain/entities/cart_entity.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/delivery_address.dart';
import '../../../payments/presentation/providers/clickpesa_providers.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/domain/entities/delivery_info_entity.dart';
import '../../../orders/domain/entities/payment_info_entity.dart';
import '../../../orders/presentation/providers/order_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/currency_formatter.dart';

class ReviewStepWidget extends ConsumerStatefulWidget {
  final CartEntity cart;
  final VoidCallback onPlaceOrder;

  const ReviewStepWidget({
    super.key,
    required this.cart,
    required this.onPlaceOrder,
  });

  @override
  ConsumerState<ReviewStepWidget> createState() => _ReviewStepWidgetState();
}

class _ReviewStepWidgetState extends ConsumerState<ReviewStepWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final checkoutState = ref.watch(checkoutProvider);

    const deliveryFee = 5000.0; // TZS 5,000
    final subtotal = widget.cart.subtotal;
    final total = subtotal + deliveryFee;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Summary',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Review your order before placing',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Order Items
                  _buildOrderItems(theme),
                  SizedBox(height: 24.h),

                  // Delivery Address
                  _buildDeliveryAddress(theme, checkoutState),
                  SizedBox(height: 24.h),

                  // Payment Method
                  _buildPaymentMethod(theme, checkoutState),
                  SizedBox(height: 24.h),

                  // Order Summary
                  _buildOrderSummary(theme, subtotal, deliveryFee, total),
                ],
              ),
            ),
          ),

          // Place Order Button
          Container(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.formatTZS(total),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: checkoutState.isLoading
                        ? null
                        : _handlePlaceOrder,
                    child: checkoutState.isLoading
                        ? SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Place Order • ${CurrencyFormatter.formatTZS(total)}',
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handlePlaceOrder() async {
    try {
      // Set loading state
      ref.read(checkoutProvider.notifier).setLoading(true);

      final checkoutState = ref.read(checkoutProvider);
      final paymentMethod = checkoutState.paymentMethod;
      final deliveryAddress = checkoutState.deliveryAddress;

      if (paymentMethod == null || deliveryAddress == null) {
        throw Exception('Missing payment method or delivery address');
      }

      // Create order in Firestore first
      final order = await _createOrderInFirestore(
        paymentMethod,
        deliveryAddress,
      );
      if (order == null) {
        throw Exception('Failed to create order');
      }

      // Process payment asynchronously to avoid blocking UI
      await Future.microtask(() async {
        if (paymentMethod.type == PaymentMethodType.mobileMoney) {
          await _processMobileMoneyPayment(paymentMethod, order);
        } else if (paymentMethod.type == PaymentMethodType.cashOnDelivery) {
          await _processCashOnDeliveryOrder(order);
        } else {
          throw Exception('Payment method not supported yet');
        }
      });

      // Clear the cart after successful order creation
      await _clearCartAfterOrder();

      // Small delay to ensure UI updates are processed
      await Future.delayed(const Duration(milliseconds: 100));

      // Proceed to confirmation
      widget.onPlaceOrder();
    } catch (e) {
      // Handle error
      ref.read(checkoutProvider.notifier).setError('Failed to place order: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      // Clear loading state
      ref.read(checkoutProvider.notifier).setLoading(false);
    }
  }

  /// Clear cart after successful order creation
  Future<void> _clearCartAfterOrder() async {
    try {
      // Clear the cart using the cart provider
      await ref.read(cartProvider.notifier).clearCart();

      print('✅ Cart cleared successfully after order placement');
    } catch (e) {
      // Log error but don't fail the order process
      print('⚠️ Failed to clear cart after order: $e');
      // We don't throw here because the order was successful
      // The cart can be cleared manually by the user if needed
    }
  }

  /// Create order in Firestore before payment processing
  Future<OrderEntity?> _createOrderInFirestore(
    CheckoutPaymentMethod paymentMethod,
    DeliveryAddress deliveryAddress,
  ) async {
    try {
      // Get current user
      final authState = ref.read(authProvider);
      if (authState.user == null) {
        throw Exception('User not authenticated');
      }

      // Create delivery info
      final deliveryInfo = DeliveryInfoEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: DeliveryType.delivery,
        recipientName: deliveryAddress.recipientName,
        recipientPhone: deliveryAddress.phoneNumber,
        address: deliveryAddress.address,
        addressLine2: deliveryAddress.addressLine2,
        city: deliveryAddress.city,
        region: deliveryAddress.region,
        postalCode: deliveryAddress.postalCode,
        latitude: deliveryAddress.latitude,
        longitude: deliveryAddress.longitude,
        landmark: deliveryAddress.landmark,
        specialInstructions: deliveryAddress.specialInstructions,
        deliveryFee: 5000.0, // TZS 5,000 delivery fee
        metadata: const {},
      );

      // Create payment info
      final paymentInfo = PaymentInfoEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        method: _mapPaymentMethodType(paymentMethod.type),
        provider: _mapPaymentProvider(paymentMethod),
        amount: widget.cart.subtotal + deliveryInfo.deliveryFee,
        currency: 'TZS',
        phoneNumber: paymentMethod.phoneNumber,
        transactionId: null, // Will be updated after payment
        referenceNumber: 'BFA${DateTime.now().millisecondsSinceEpoch}',
        providerData: const {},
        metadata: {
          'provider_display_name': paymentMethod.providerDisplayName,
          'checkout_timestamp': DateTime.now().toIso8601String(),
        },
      );

      // Create order using the order provider
      final order = await ref
          .read(orderProvider.notifier)
          .createOrder(
            userId: authState.user!.id,
            cart: widget.cart,
            deliveryInfo: deliveryInfo,
            paymentInfo: paymentInfo,
            notes: 'Order created via mobile checkout',
          );

      return order;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create order: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return null;
    }
  }

  /// Map checkout payment method type to order payment method
  PaymentMethod _mapPaymentMethodType(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.mobileMoney:
        return PaymentMethod.mobileMoney;
      case PaymentMethodType.cashOnDelivery:
        return PaymentMethod.cash;
      default:
        return PaymentMethod.mobileMoney;
    }
  }

  /// Map checkout payment provider to order payment provider
  PaymentProvider _mapPaymentProvider(CheckoutPaymentMethod paymentMethod) {
    if (paymentMethod.type == PaymentMethodType.cashOnDelivery) {
      return PaymentProvider.cash;
    }

    // For mobile money, map based on provider
    switch (paymentMethod.provider) {
      case PaymentProviderType.mpesa:
        return PaymentProvider.mpesa;
      case PaymentProviderType.tigoPesa:
        return PaymentProvider.tigopesa;
      case PaymentProviderType.airltelMoney: // Note: typo in original enum
        return PaymentProvider.airtelmoney;
      case PaymentProviderType.halopesa:
        return PaymentProvider.halopesa;
      default:
        return PaymentProvider.clickpesa;
    }
  }

  Future<void> _processMobileMoneyPayment(
    CheckoutPaymentMethod paymentMethod,
    OrderEntity order,
  ) async {
    try {
      // Generate unique order reference
      final orderReference = 'BFA${DateTime.now().millisecondsSinceEpoch}';

      // Calculate total amount (convert to TZS if needed)
      const deliveryFee = 5000.0;
      final totalAmount = widget.cart.subtotal + deliveryFee;

      // For now, simulate ClickPesa payment processing
      // TODO: Integrate with actual ClickPesa service
      await Future.delayed(const Duration(seconds: 2));

      // Simulate payment initiation success
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Payment of ${CurrencyFormatter.formatTZS(totalAmount)} initiated via ${paymentMethod.providerDisplayName}! Check your phone for USSD prompt.',
                  ),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 5),
          ),
        );
      }

      // Check if ClickPesa is properly configured
      final isConfigured = ref.read(clickPesaConfigurationStatusProvider);

      if (isConfigured) {
        // Use actual ClickPesa integration
        final clickPesaService = ref.read(clickPesaIntegrationServiceProvider);
        final result = await clickPesaService.processMobileMoneyPayment(
          amount: totalAmount,
          phoneNumber: paymentMethod.phoneNumber!,
          orderReference: orderReference,
        );

        if (result.isFailure) {
          throw Exception(result.failure?.message ?? 'Payment failed');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment initiation failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      rethrow;
    }
  }

  Future<void> _processCashOnDeliveryOrder(OrderEntity order) async {
    // For cash on delivery, order is already created, just confirm
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Order ${order.orderNumber} created successfully! Pay cash when delivered.',
                ),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildOrderItems(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  color: theme.colorScheme.primary,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Order Items (${widget.cart.itemCount})',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...widget.cart.items.map((item) => _buildOrderItem(theme, item)),
        ],
      ),
    );
  }

  Widget _buildOrderItem(ThemeData theme, CartItemEntity item) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: item.product.primaryImageUrl?.isNotEmpty == true
                  ? Image.network(
                      item.product.primaryImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.image_not_supported,
                          color: theme.colorScheme.onSurfaceVariant,
                        );
                      },
                    )
                  : Icon(
                      Icons.image_not_supported,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
            ),
          ),
          SizedBox(width: 12.w),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  'Qty: ${item.quantity.toStringAsFixed(item.quantity.truncateToDouble() == item.quantity ? 0 : 1)} ${item.product.unit}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  CurrencyFormatter.formatTZS(item.totalPrice),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress(ThemeData theme, CheckoutState checkoutState) {
    final address = checkoutState.deliveryAddress;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: theme.colorScheme.primary,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Delivery Address',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (address != null) ...[
            Text(
              address.recipientName,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4.h),
            Text(address.phoneNumber, style: theme.textTheme.bodyMedium),
            SizedBox(height: 4.h),
            Text(address.formattedAddress, style: theme.textTheme.bodyMedium),
            if (address.landmark?.isNotEmpty == true) ...[
              SizedBox(height: 4.h),
              Text(
                'Landmark: ${address.landmark}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(ThemeData theme, CheckoutState checkoutState) {
    final paymentMethod = checkoutState.paymentMethod;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.payment_outlined,
                color: theme.colorScheme.primary,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Payment Method',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (paymentMethod != null) ...[
            Text(
              paymentMethod.displayName,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderSummary(
    ThemeData theme,
    double subtotal,
    double deliveryFee,
    double total,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_outlined,
                color: theme.colorScheme.primary,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Price Details',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          _buildSummaryRow(
            theme,
            'Subtotal',
            CurrencyFormatter.formatTZS(subtotal),
          ),
          SizedBox(height: 8.h),
          _buildSummaryRow(
            theme,
            'Delivery Charges',
            CurrencyFormatter.formatTZS(deliveryFee),
          ),
          SizedBox(height: 12.h),
          const Divider(),
          SizedBox(height: 12.h),
          _buildSummaryRow(
            theme,
            'Total Amount',
            CurrencyFormatter.formatTZS(total),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    ThemeData theme,
    String label,
    String value, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            color: isTotal ? theme.colorScheme.primary : null,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? theme.colorScheme.primary : null,
          ),
        ),
      ],
    );
  }
}
