import 'package:bfa/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../products/presentation/providers/product_provider.dart';
import '../../../products/presentation/widgets/product_card.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  final List<String> _categories = [
    'All Products',
    'My Recents',
    'Under Tsh. 500',
    'Subscription',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    print('🏠 HomePage: _loadInitialData called');
    // Load products with refresh to ensure they load even if already loading
    print('🏠 HomePage: Calling productProvider.loadProducts(refresh: true)');
    ref.read(productProvider.notifier).loadProducts(refresh: true);
    print('🏠 HomePage: productProvider.loadProducts() called');
  }

  void _addToCart(dynamic product) {
    // Add item to cart with default quantity of 1
    ref.read(cartProvider.notifier).addItem(product: product, quantity: 1.0);

    // Show success message
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
                '${product.name} added to cart!',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Theme.of(context).colorScheme.onPrimary,
          onPressed: () {
            context.pushNamed(AppRoute.cart.name);
          },
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning!';
    } else if (hour < 17) {
      return 'Good Afternoon!';
    } else {
      return 'Good Evening!';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            _buildCustomAppBar(theme),

            // Main Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  _loadInitialData();
                },
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.h),

                      // Promotional Banner
                      _buildPromotionalBanner(),

                      SizedBox(height: 24.h),

                      // All Products Section
                      _buildAllProductsSection(),

                      SizedBox(height: 100.h), // Bottom padding for navigation
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(ThemeData theme) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18.r,
                backgroundColor: theme.colorScheme.primary,
                child: user?.profileImageUrl != null
                    ? ClipOval(
                        child: Image.network(
                          user!.profileImageUrl!,
                          width: 36.w,
                          height: 36.h,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Text(
                              user.initials,
                              style: TextStyle(
                                color: theme.colorScheme.onPrimary,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                        ),
                      )
                    : Text(
                        user?.initials ?? 'U',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authState.isLoading
                        ? 'Hello, Loading...'
                        : 'Hello, ${user?.displayName ?? 'User'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    _getGreetingMessage(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          // Cart Icon with Badge
          _buildSearchIcon(theme),
          _buildCartIcon(theme),
        ],
      ),
    );
  }

  Widget _buildCartIcon(ThemeData theme) {
    final cartState = ref.watch(cartProvider);
    final cartItemCount = cartState.cart?.itemCount ?? 0;

    return Stack(
      children: [
        IconButton(
          onPressed: () {
            context.pushNamed(AppRoute.cart.name);
          },
          icon: Icon(
            HugeIcons.strokeRoundedShoppingCart01,
            color: theme.colorScheme.onSurface,
            size: 24.sp,
          ),
        ),
        if (cartItemCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                borderRadius: BorderRadius.circular(10.r),
              ),
              constraints: BoxConstraints(minWidth: 16.w, minHeight: 16.h),
              child: Text(
                cartItemCount > 99 ? '99+' : cartItemCount.toString(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onError,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchIcon(ThemeData theme) {
    return IconButton(
      onPressed: () {
        context.pushNamed(AppRoute.search.name);
      },
      icon: Icon(
        HugeIcons.strokeRoundedSearch01,
        color: theme.colorScheme.onSurface,
        size: 24.sp,
      ),
    );
  }

  Widget _buildPromotionalBanner() {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
            theme.colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern/decoration
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.onPrimary.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -30,
            child: Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.secondary.withValues(alpha: 0.2),
              ),
            ),
          ),

          // Main content
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Discount badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.secondary.withValues(
                          alpha: 0.4,
                        ),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '🔥 LIMITED TIME',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 10.sp,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                SizedBox(height: 12.h),

                // Main offer text
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Get ',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 28.sp,
                        ),
                      ),
                      TextSpan(
                        text: '40% OFF',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 32.sp,
                          shadows: [
                            Shadow(
                              color: theme.colorScheme.onPrimary.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 4.h),

                // Subtitle
                Text(
                  'on your first order of fresh farm produce',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                    fontSize: 16.sp,
                    height: 1.3,
                  ),
                ),

                SizedBox(height: 20.h),

                // CTA Button
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.onPrimary.withValues(
                          alpha: 0.2,
                        ),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.goNamed(AppRoute.products.name);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.onPrimary,
                      foregroundColor: theme.colorScheme.primary,
                      padding: EdgeInsets.symmetric(
                        horizontal: 28.w,
                        vertical: 14.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    icon: Icon(
                      Icons.shopping_cart_outlined,
                      size: 20.sp,
                      color: theme.colorScheme.primary,
                    ),
                    label: Text(
                      'Shop Now & Save',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
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

  Widget _buildAllProductsSection() {
    return Consumer(
      builder: (context, ref, child) {
        final productState = ref.watch(productProvider);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                'All Products',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Loading state
            if (productState.isLoading && productState.products.isEmpty)
              SizedBox(
                height: 400.h,
                child: const Center(child: LoadingWidget()),
              )
            // Error state
            else if (productState.error != null &&
                productState.products.isEmpty)
              SizedBox(
                height: 400.h,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48.sp,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Failed to load products',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextButton(
                        onPressed: () => _loadInitialData(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            // Empty state
            else if (productState.products.isEmpty)
              SizedBox(
                height: 400.h,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.agriculture_outlined,
                        size: 48.sp,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No products available',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            // Products grid
            else
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: productState.products.length.clamp(0, 6),
                  itemBuilder: (context, index) {
                    final product = productState.products[index];
                    return ProductCard(
                      product: product,
                      onTap: () {
                        context.goNamed(
                          AppRoute.productDetails.name,
                          pathParameters: {'id': product.id},
                        );
                      },
                      onAddToCart: () {
                        _addToCart(product);
                      },
                      onToggleWishlist: () {
                        // Toggle wishlist logic
                      },
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
