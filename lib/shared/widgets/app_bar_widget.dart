import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';

/// Custom app bar widget with consistent styling
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final PreferredSizeWidget? bottom;
  final bool automaticallyImplyLeading;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.showBackButton = true,
    this.onBackPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.bottom,
    this.automaticallyImplyLeading = true,
  });

  /// Create a simple app bar with just a title
  const CustomAppBar.simple({
    super.key,
    required this.title,
    this.backgroundColor,
    this.foregroundColor,
  }) : actions = null,
       leading = null,
       centerTitle = true,
       showBackButton = true,
       onBackPressed = null,
       elevation = null,
       bottom = null,
       automaticallyImplyLeading = true;

  /// Create an app bar with search functionality
  const CustomAppBar.search({
    super.key,
    required this.title,
    required this.actions,
    this.backgroundColor,
    this.foregroundColor,
  }) : leading = null,
       centerTitle = true,
       showBackButton = true,
       onBackPressed = null,
       elevation = null,
       bottom = null,
       automaticallyImplyLeading = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppBar(
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          color: foregroundColor ?? theme.appBarTheme.foregroundColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? theme.appBarTheme.backgroundColor,
      foregroundColor: foregroundColor ?? theme.appBarTheme.foregroundColor,
      elevation: elevation ?? theme.appBarTheme.elevation,
      leading: _buildLeading(context),
      actions: actions,
      bottom: bottom,
      automaticallyImplyLeading: automaticallyImplyLeading,
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;
    
    if (showBackButton && Navigator.of(context).canPop()) {
      return IconButton(
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back),
      );
    }
    
    return null;
  }

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0),
  );
}

/// App bar with search functionality
class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final String hintText;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchSubmitted;
  final VoidCallback? onSearchClosed;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;

  const SearchAppBar({
    super.key,
    required this.title,
    this.hintText = 'Search...',
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onSearchClosed,
    this.actions,
    this.automaticallyImplyLeading = true,
  });

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SearchAppBarState extends State<SearchAppBar> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isSearching) {
      return AppBar(
        leading: IconButton(
          onPressed: _closeSearch,
          icon: const Icon(Icons.arrow_back),
        ),
        title: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.appBarTheme.foregroundColor,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: theme.textTheme.titleMedium?.copyWith(
              color: theme.appBarTheme.foregroundColor?.withOpacity(0.7),
            ),
            border: InputBorder.none,
          ),
          onChanged: widget.onSearchChanged,
          onSubmitted: (_) => widget.onSearchSubmitted?.call(),
        ),
        actions: [
          IconButton(
            onPressed: _clearSearch,
            icon: const Icon(Icons.clear),
          ),
        ],
        automaticallyImplyLeading: widget.automaticallyImplyLeading,
      );
    }

    return AppBar(
      title: Text(
        widget.title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: _openSearch,
          icon: const Icon(Icons.search),
        ),
        ...?widget.actions,
      ],
      automaticallyImplyLeading: widget.automaticallyImplyLeading,
    );
  }

  void _openSearch() {
    setState(() {
      _isSearching = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  void _closeSearch() {
    setState(() {
      _isSearching = false;
    });
    _searchController.clear();
    widget.onSearchClosed?.call();
  }

  void _clearSearch() {
    _searchController.clear();
    widget.onSearchChanged?.call('');
  }
}

/// App bar with tabs
class TabbedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Tab> tabs;
  final TabController? controller;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;

  const TabbedAppBar({
    super.key,
    required this.title,
    required this.tabs,
    this.controller,
    this.actions,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
      bottom: TabBar(
        controller: controller,
        tabs: tabs,
        indicatorColor: AppColors.secondary,
        labelColor: theme.appBarTheme.foregroundColor,
        unselectedLabelColor: theme.appBarTheme.foregroundColor?.withOpacity(0.7),
        indicatorWeight: 3.0,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + kTextTabBarHeight);
}

/// App bar with profile avatar
class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? userImageUrl;
  final String? userName;
  final VoidCallback? onProfileTap;
  final List<Widget>? actions;

  const ProfileAppBar({
    super.key,
    required this.title,
    this.userImageUrl,
    this.userName,
    this.onProfileTap,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      leading: GestureDetector(
        onTap: onProfileTap,
        child: Container(
          margin: EdgeInsets.all(8.w),
          child: CircleAvatar(
            backgroundImage: userImageUrl != null 
                ? NetworkImage(userImageUrl!) 
                : null,
            backgroundColor: AppColors.primary,
            child: userImageUrl == null
                ? Text(
                    userName?.isNotEmpty == true 
                        ? userName![0].toUpperCase() 
                        : 'U',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null,
          ),
        ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// App bar with cart icon and badge
class ShoppingAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final int cartItemCount;
  final VoidCallback? onCartTap;
  final List<Widget>? actions;

  const ShoppingAppBar({
    super.key,
    required this.title,
    this.cartItemCount = 0,
    this.onCartTap,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        Stack(
          children: [
            IconButton(
              onPressed: onCartTap,
              icon: const Icon(Icons.shopping_cart_outlined),
            ),
            if (cartItemCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 16.w,
                    minHeight: 16.h,
                  ),
                  child: Text(
                    cartItemCount > 99 ? '99+' : cartItemCount.toString(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.onError,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        ...?actions,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
