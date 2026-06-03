import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../providers/order_provider.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_item_entity.dart';
import '../../../../core/utils/helpers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    // Load orders when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authProvider);
      if (authState.user != null) {
        ref
            .read(orderProvider.notifier)
            .getUserOrders(userId: authState.user!.id, refresh: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orderState = ref.watch(orderProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
        title: Text(
          'My Orders',
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontSize: 20.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final authState = ref.read(authProvider);
          if (authState.user != null) {
            await ref
                .read(orderProvider.notifier)
                .getUserOrders(userId: authState.user!.id, refresh: true);
          }
        },
        child: _buildBody(theme, orderState),
      ),
    );
  }

  Widget _buildBody(ThemeData theme, OrderState orderState) {
    if (orderState.isLoading && orderState.orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (orderState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.w,
              color: theme.colorScheme.error,
            ),
            SizedBox(height: 16.h),
            Text('Error loading orders', style: theme.textTheme.headlineSmall),
            SizedBox(height: 8.h),
            Text(
              orderState.error!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () {
                final authState = ref.read(authProvider);
                if (authState.user != null) {
                  ref
                      .read(orderProvider.notifier)
                      .getUserOrders(userId: authState.user!.id, refresh: true);
                }
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (orderState.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64.w,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            SizedBox(height: 16.h),
            Text('No orders yet', style: theme.textTheme.headlineSmall),
            SizedBox(height: 8.h),
            Text(
              'Your orders will appear here once you make a purchase',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () {
                context.go('/products');
              },
              child: const Text('Start Shopping'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: orderState.orders.length,
      itemBuilder: (context, index) {
        final order = orderState.orders[index];
        return _buildOrderCard(theme, order);
      },
    );
  }

  Widget _buildOrderCard(ThemeData theme, OrderEntity order) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      child: InkWell(
        onTap: () {
          // Navigate to order details
          _showOrderDetails(order);
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.orderNumber}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStatusChip(theme, order.status),
                ],
              ),
              SizedBox(height: 8.h),

              // Order date
              Text(
                'Placed on ${Helpers.formatDate(order.orderDate)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: 12.h),

              // Order items preview
              Text(
                '${order.items.length} item${order.items.length > 1 ? 's' : ''}',
                style: theme.textTheme.bodyMedium,
              ),
              SizedBox(height: 8.h),

              // Total amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: theme.textTheme.titleMedium),
                  Text(
                    Helpers.formatCurrency(order.totalAmount),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(ThemeData theme, OrderStatus status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case OrderStatus.pending:
        backgroundColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange;
        break;
      case OrderStatus.confirmed:
        backgroundColor = Colors.blue.withValues(alpha: 0.1);
        textColor = Colors.blue;
        break;
      case OrderStatus.preparing:
        backgroundColor = Colors.purple.withValues(alpha: 0.1);
        textColor = Colors.purple;
        break;
      case OrderStatus.readyForPickup:
        backgroundColor = Colors.indigo.withValues(alpha: 0.1);
        textColor = Colors.indigo;
        break;
      case OrderStatus.outForDelivery:
        backgroundColor = Colors.teal.withValues(alpha: 0.1);
        textColor = Colors.teal;
        break;
      case OrderStatus.delivered:
        backgroundColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green;
        break;
      case OrderStatus.cancelled:
        backgroundColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        status.displayName,
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showOrderDetails(OrderEntity order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _OrderDetailsBottomSheet(order: order),
    );
  }
}

class _OrderDetailsBottomSheet extends StatelessWidget {
  final OrderEntity order;

  const _OrderDetailsBottomSheet({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Details',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          Divider(height: 1.h),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order info
                  _buildOrderInfo(theme),
                  SizedBox(height: 24.h),

                  // Items
                  _buildOrderItems(theme),
                  SizedBox(height: 24.h),

                  // Delivery info
                  _buildDeliveryInfo(theme),
                  SizedBox(height: 24.h),

                  // Payment summary
                  _buildPaymentSummary(theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Information',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        _buildInfoRow(theme, 'Order Number', order.orderNumber),
        _buildInfoRow(theme, 'Order Date', Helpers.formatDate(order.orderDate)),
        _buildInfoRow(theme, 'Status', order.status.displayName),
        if (order.estimatedDeliveryDate != null)
          _buildInfoRow(
            theme,
            'Estimated Delivery',
            Helpers.formatDate(order.estimatedDeliveryDate!),
          ),
      ],
    );
  }

  Widget _buildOrderItems(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Items (${order.items.length})',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        ...order.items.map((item) => _buildItemRow(theme, item)),
      ],
    );
  }

  Widget _buildItemRow(ThemeData theme, OrderItemEntity item) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          // Product image placeholder
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.image,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(width: 12.w),

          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${item.quantity} ${item.unit} × ${Helpers.formatCurrency(item.unitPrice)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),

          // Total price
          Text(
            Helpers.formatCurrency(item.totalPrice),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delivery Information',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        _buildInfoRow(theme, 'Address', order.deliveryInfo.fullAddress),
        _buildInfoRow(theme, 'Phone', order.deliveryInfo.recipientPhone),
        if (order.deliveryInfo.specialInstructions?.isNotEmpty == true)
          _buildInfoRow(
            theme,
            'Instructions',
            order.deliveryInfo.specialInstructions!,
          ),
      ],
    );
  }

  Widget _buildPaymentSummary(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Summary',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        _buildInfoRow(
          theme,
          'Subtotal',
          Helpers.formatCurrency(order.subtotal),
        ),
        if (order.discountAmount > 0)
          _buildInfoRow(
            theme,
            'Discount',
            '-${Helpers.formatCurrency(order.discountAmount)}',
          ),
        _buildInfoRow(
          theme,
          'Delivery Fee',
          Helpers.formatCurrency(order.deliveryFee),
        ),
        _buildInfoRow(theme, 'Tax', Helpers.formatCurrency(order.taxAmount)),
        Divider(height: 24.h),
        _buildInfoRow(
          theme,
          'Total',
          Helpers.formatCurrency(order.totalAmount),
          isTotal: true,
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    ThemeData theme,
    String label,
    String value, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: isTotal ? FontWeight.bold : null,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? theme.colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}
