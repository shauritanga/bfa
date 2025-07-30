import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../cart/presentation/pages/cart_page.dart';

class MainNavigationPage extends ConsumerStatefulWidget {
  const MainNavigationPage({super.key});

  @override
  ConsumerState<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends ConsumerState<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const ProductsPage(),
    const CartPage(),
    const OrdersPage(),
    const ProfilePage(),
  ];

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
    ),
    NavigationItem(
      icon: Icons.agriculture_outlined,
      activeIcon: Icons.agriculture,
      label: 'Products',
    ),
    NavigationItem(
      icon: Icons.shopping_cart_outlined,
      activeIcon: Icons.shopping_cart,
      label: 'Cart',
    ),
    NavigationItem(
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
      label: 'Orders',
    ),
    NavigationItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _navigationItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = index == _currentIndex;

                return _buildNavigationItem(
                  item: item,
                  isSelected: isSelected,
                  onTap: () => _onItemTapped(index),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItem({
    required NavigationItem item,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16.w : 12.w,
          vertical: 8.h,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? item.activeIcon : item.icon,
                key: ValueKey(isSelected),
                size: 24.sp,
                color: isSelected ? primaryColor : onSurfaceVariant,
              ),
            ),
            SizedBox(height: 4.h),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: theme.textTheme.bodySmall!.copyWith(
                color: isSelected ? primaryColor : onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 12.sp,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
    }
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

// Placeholder pages for navigation
class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.agriculture, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Products Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Browse fresh produce from local farmers'),
          ],
        ),
      ),
    );
  }
}

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Orders Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Track your orders and purchase history'),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Profile Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Manage your account and preferences'),
          ],
        ),
      ),
    );
  }
}
