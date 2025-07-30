import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../products/presentation/providers/product_provider.dart';
import '../../../products/presentation/widgets/product_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    // Load products
    ref.read(productProvider.notifier).loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          _loadInitialData();
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // App Bar with search
            SliverAppBar(
              expandedHeight: 120.h,
              floating: true,
              pinned: true,
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'FreshCrops',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(60.h),
                child: Container(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                  child: _buildSearchBar(theme),
                ),
              ),
            ),

            // Main content
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),

                  // Welcome banner
                  _buildWelcomeBanner(),

                  SizedBox(height: 24.h),

                  // Recent products
                  _buildRecentProductsSection(),

                  SizedBox(height: 100.h), // Bottom padding for navigation
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search fresh produce...',
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
          prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 20.sp),
          suffixIcon: Icon(Icons.tune, color: Colors.grey[600], size: 20.sp),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
        ),
        onTap: () {
          // Navigate to search page
          Navigator.pushNamed(context, '/search');
        },
        readOnly: true,
      ),
    );
  }

  Widget _buildRecentProductsSection() {
    return Consumer(
      builder: (context, ref, child) {
        final productState = ref.watch(productProvider);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recently Added',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/products');
                    },
                    child: Text(
                      'View All',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12.h),

            if (productState.isLoading)
              const Center(child: LoadingWidget())
            else if (productState.error != null)
              Center(
                child: Column(
                  children: [
                    Icon(Icons.error, size: 48.sp, color: Colors.red),
                    SizedBox(height: 16.h),
                    Text(productState.error!),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(productProvider.notifier).loadProducts();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else if (productState.products.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(32.w),
                  child: Column(
                    children: [
                      Icon(
                        Icons.agriculture,
                        size: 64.sp,
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
            else
              SizedBox(
                height: 280.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: productState.products.length.clamp(0, 10),
                  itemBuilder: (context, index) {
                    final product = productState.products[index];
                    return Container(
                      width: 200.w,
                      margin: EdgeInsets.only(right: 12.w),
                      child: ProductCard(
                        product: product,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/product-details',
                            arguments: product,
                          );
                        },
                        onAddToCart: () {
                          // Add to cart logic
                        },
                        onToggleWishlist: () {
                          // Toggle wishlist logic
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fresh from Farm to Table',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Discover the freshest produce from local farmers',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.agriculture,
            size: 48.sp,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ],
      ),
    );
  }
}
