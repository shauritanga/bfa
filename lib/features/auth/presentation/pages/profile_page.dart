import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../orders/presentation/providers/order_provider.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../cart/presentation/providers/cart_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final theme = Theme.of(context);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile'), centerTitle: true),
        body: const Center(child: Text('No user data available')),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
        title: Text(
          'Profile',
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontSize: 20.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: theme.colorScheme.onPrimary),
            onPressed: () {
              // TODO: Show more options
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header Section
            _buildCleanProfileHeader(theme, user),

            SizedBox(height: 8.h),

            // Quick Stats Section
            _buildCleanQuickStats(context, theme, ref),

            SizedBox(height: 8.h),

            // Recent Orders Section
            _buildCleanRecentOrders(context, theme, ref),

            SizedBox(height: 8.h),

            // Favorites Section
            _buildCleanFavorites(context, theme, ref),

            SizedBox(height: 8.h),

            // Settings Section
            _buildCleanSettings(theme, ref),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildCleanProfileHeader(ThemeData theme, dynamic user) {
    return Container(
      color: theme.colorScheme.surface,
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          // Profile Picture
          Stack(
            children: [
              CircleAvatar(
                radius: 35.r,
                backgroundColor: theme.colorScheme.primary,
                backgroundImage: user.profileImageUrl != null
                    ? NetworkImage(user.profileImageUrl!)
                    : null,
                child: user.profileImageUrl == null
                    ? Text(
                        user.initials,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onPrimary,
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 24.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: theme.colorScheme.onSecondary,
                    size: 14.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 16.w),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  user.email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Member since ${_formatDate(user.createdAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),

          // Edit Icon
          IconButton(
            onPressed: () {
              // TODO: Navigate to edit profile
            },
            icon: Icon(Icons.edit_outlined, color: theme.colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildCleanQuickStats(
    BuildContext context,
    ThemeData theme,
    WidgetRef ref,
  ) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return Container(
        color: theme.colorScheme.surface,
        child: const SizedBox.shrink(),
      );
    }

    // Watch user orders to get count
    final userOrdersAsync = ref.watch(userOrdersProvider(user.id));
    final cartState = ref.watch(cartProvider);

    return Container(
      color: theme.colorScheme.surface,
      child: Row(
        children: [
          Expanded(
            child: _buildCleanStatItem(
              theme: theme,
              icon: Icons.shopping_bag_outlined,
              title: 'Orders',
              value: userOrdersAsync.when(
                data: (orders) => orders.items.length.toString(),
                loading: () => '-',
                error: (_, __) => '0',
              ),
              onTap: () {
                context.go('/profile/orders');
              },
            ),
          ),
          Container(
            width: 1,
            height: 50.h,
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _buildCleanStatItem(
              theme: theme,
              icon: Icons.shopping_cart_outlined,
              title: 'Cart',
              value: cartState.itemCount.toString(),
              onTap: () {
                context.go('/cart');
              },
            ),
          ),
          Container(
            width: 1,
            height: 50.h,
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _buildCleanStatItem(
              theme: theme,
              icon: Icons.star_outline,
              title: 'Reviews',
              value: '0', // TODO: Implement reviews count
              onTap: () {
                // TODO: Navigate to reviews
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCleanStatItem({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Column(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 24.sp),
            SizedBox(height: 4.h),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCleanRecentOrders(
    BuildContext context,
    ThemeData theme,
    WidgetRef ref,
  ) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return Container(
        color: theme.colorScheme.surface,
        child: const SizedBox.shrink(),
      );
    }

    // Watch user orders
    final userOrdersAsync = ref.watch(userOrdersProvider(user.id));

    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Orders',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    context.go('/profile/orders');
                  },
                  child: Text(
                    'View All',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Orders List
          userOrdersAsync.when(
            data: (orders) {
              if (orders.items.isEmpty) {
                return Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Text(
                    'No orders yet',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                );
              }

              // Show only the first 3 orders
              final recentOrders = orders.items.take(3).toList();

              return Column(
                children: recentOrders.map((order) {
                  return _buildCleanOrderItem(
                    context: context,
                    theme: theme,
                    order: order,
                  );
                }).toList(),
              );
            },
            loading: () => Padding(
              padding: EdgeInsets.all(16.w),
              child: const CircularProgressIndicator(),
            ),
            error: (error, stack) => Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                'Failed to load orders',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCleanOrderItem({
    required BuildContext context,
    required ThemeData theme,
    required OrderEntity order,
  }) {
    // Get status color based on order status
    Color getStatusColor(OrderStatus status) {
      switch (status) {
        case OrderStatus.delivered:
          return Colors.green;
        case OrderStatus.confirmed:
        case OrderStatus.preparing:
          return Colors.orange;
        case OrderStatus.outForDelivery:
          return Colors.blue;
        case OrderStatus.cancelled:
          return Colors.red;
        default:
          return theme.colorScheme.primary;
      }
    }

    // Format date
    String formatOrderDate(DateTime date) {
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return _formatDate(date);
      }
    }

    final statusColor = getStatusColor(order.status);

    return InkWell(
      onTap: () {
        context.go('/profile/orders/${order.id}');
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            // Order Icon
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                color: statusColor,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),

            // Order Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.orderNumber,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    formatOrderDate(order.orderDate),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),

            // Status and Total
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    order.status.name.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'TZS ${order.totalAmount.toStringAsFixed(0)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCleanFavorites(
    BuildContext context,
    ThemeData theme,
    WidgetRef ref,
  ) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return Container(
        color: theme.colorScheme.surface,
        child: const SizedBox.shrink(),
      );
    }

    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Favorites',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    context.go('/profile/favorites');
                  },
                  child: Text(
                    'View All',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Favorites List - For now showing placeholder since wishlist isn't fully implemented
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(
              'Favorites feature coming soon!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCleanSettings(ThemeData theme, WidgetRef ref) {
    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          Builder(
            builder: (context) => _buildCleanSettingItem(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              onTap: () {
                // TODO: Implement edit profile screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit Profile coming soon!')),
                );
              },
            ),
          ),
          Builder(
            builder: (context) => _buildCleanSettingItem(
              icon: Icons.lock_outline,
              title: 'Change Password',
              onTap: () {
                // TODO: Implement change password screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Change Password coming soon!')),
                );
              },
            ),
          ),
          Builder(
            builder: (context) => _buildCleanSettingItem(
              icon: Icons.location_on_outlined,
              title: 'Delivery Addresses',
              onTap: () {
                // TODO: Implement addresses screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Delivery Addresses coming soon!'),
                  ),
                );
              },
            ),
          ),
          Builder(
            builder: (context) => _buildCleanSettingItem(
              icon: Icons.payment_outlined,
              title: 'Payment Methods',
              onTap: () {
                // TODO: Implement payment methods screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment Methods coming soon!')),
                );
              },
            ),
          ),
          Builder(
            builder: (context) => _buildCleanSettingItem(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              onTap: () {
                // TODO: Implement notifications screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notifications coming soon!')),
                );
              },
            ),
          ),
          Builder(
            builder: (context) => _buildCleanSettingItem(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () {
                // TODO: Implement help screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Help & Support coming soon!')),
                );
              },
            ),
          ),
          Builder(
            builder: (context) => _buildCleanSettingItem(
              icon: Icons.logout,
              title: 'Sign Out',
              textColor: theme.colorScheme.error,
              onTap: () {
                _signOut(context, ref);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCleanSettingItem({
    required IconData icon,
    required String title,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Row(
              children: [
                Icon(
                  icon,
                  color:
                      textColor ??
                      theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  size: 22.sp,
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: textColor ?? theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                if (textColor == null)
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    size: 20.sp,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await ref.read(authProvider.notifier).signOut();

      if (result.isSuccess && context.mounted) {
        context.go('/login');
      }
    }
  }
}
