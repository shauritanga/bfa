import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

class ClientShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const ClientShell({required this.navigationShell, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => _onTap(context, index),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(HugeIcons.strokeRoundedHome01),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(HugeIcons.strokeRoundedTags),
            label: 'Products',
          ),
          NavigationDestination(
            icon: Icon(HugeIcons.strokeRoundedShoppingCart01),
            label: 'Cart',
          ),
          NavigationDestination(
            icon: Icon(HugeIcons.strokeRoundedUser03),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
