import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../providers/product_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/product_filter_sheet.dart';
import '../widgets/category_chips_widget.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/app_bar_widget.dart';

class ProductsPage extends ConsumerStatefulWidget {
  final String? categoryId;
  final String? searchQuery;

  const ProductsPage({super.key, this.categoryId, this.searchQuery});

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Load initial products and apply filters if provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.categoryId != null) {
        // Set the category in the category provider
        ref.read(categoryProvider.notifier).selectCategory(widget.categoryId!);
        // Apply filter to products
        ref
            .read(productProvider.notifier)
            .applyFilter(
              ref
                  .read(productProvider)
                  .currentFilter
                  .copyWith(categoryIds: [widget.categoryId!]),
            );
      } else {
        // Load all products by default
        ref.read(productProvider.notifier).loadProducts(refresh: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(productProvider.notifier).loadMoreProducts();
    }
  }

  void _onCategorySelected(String categoryId) {
    if (categoryId == 'all') {
      // Show all products - clear category filter
      ref
          .read(productProvider.notifier)
          .applyFilter(
            ref
                .read(productProvider)
                .currentFilter
                .copyWith(
                  categoryIds: [], // Clear category filter
                ),
          );
    } else {
      // Filter by selected category
      ref
          .read(productProvider.notifier)
          .applyFilter(
            ref
                .read(productProvider)
                .currentFilter
                .copyWith(categoryIds: [categoryId]),
          );
    }
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
            context.pushNamed('/cart'); // Navigate to cart page
          },
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: ShoppingAppBar(
        title: widget.categoryId != null ? 'Category Products' : 'Products',

        actions: [
          IconButton(
            icon: const Icon(HugeIcons.strokeRoundedSearch01),
            onPressed: () {
              context.pushNamed(AppRoute.search.name);
            },
          ),
          IconButton(
            icon: Icon(
              _isGridView ? Icons.list : HugeIcons.strokeRoundedGridView,
            ),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          IconButton(
            icon: const Icon(HugeIcons.strokeRoundedFilter),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Chips
          CategoryChipsWidget(
            onCategorySelected: (categoryId) {
              _onCategorySelected(categoryId);
            },
          ),

          // Filter Chips - Only show for non-category filters to maintain consistent spacing
          if (productState.currentFilter.hasActiveFiltersExcludingCategory)
            Container(
              height: 50.h,
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding.w,
              ),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _buildFilterChips(productState),
              ),
            ),

          // Products List/Grid
          Expanded(child: _buildProductsList(productState, theme)),
        ],
      ),
    );
  }

  Widget _buildProductsList(ProductState productState, ThemeData theme) {
    if (productState.isLoading && productState.products.isEmpty) {
      return const Center(child: LoadingWidget());
    }

    if (productState.error != null && productState.products.isEmpty) {
      return Center(
        child: AppErrorWidget(
          message: productState.error!,
          onRetry: () =>
              ref.read(productProvider.notifier).loadProducts(refresh: true),
        ),
      );
    }

    final products =
        widget.searchQuery != null && widget.searchQuery!.isNotEmpty
        ? productState.searchResults
        : productState.products;

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 80.w,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            SizedBox(height: 16.h),
            Text(
              'No products found',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Try adjusting your filters or search terms',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () => ref.read(productProvider.notifier).clearFilter(),
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(productProvider.notifier).loadProducts(refresh: true),
      child: _isGridView ? _buildGridView(products) : _buildListView(products),
    );
  }

  Widget _buildGridView(List products) {
    return GridView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(AppConstants.defaultPadding.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemCount:
          products.length + (ref.watch(productProvider).isLoadingMore ? 2 : 0),
      itemBuilder: (context, index) {
        if (index >= products.length) {
          return const Center(child: LoadingWidget());
        }

        final product = products[index];
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
        );
      },
    );
  }

  Widget _buildListView(List products) {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(AppConstants.defaultPadding.w),
      itemCount:
          products.length + (ref.watch(productProvider).isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= products.length) {
          return const Center(child: LoadingWidget());
        }

        final product = products[index];
        return ProductCard(
          product: product,
          isListView: true,
          onTap: () {
            context.goNamed(
              AppRoute.productDetails.name,
              pathParameters: {'id': product.id},
            );
          },
          onAddToCart: () {
            _addToCart(product);
          },
        );
      },
    );
  }

  List<Widget> _buildFilterChips(ProductState productState) {
    final chips = <Widget>[];
    final filter = productState.currentFilter;

    if (filter.isOrganic == true) {
      chips.add(
        _buildFilterChip('Organic', () {
          ref
              .read(productProvider.notifier)
              .applyFilter(filter.copyWith(isOrganic: null));
        }),
      );
    }

    if (filter.isFeatured == true) {
      chips.add(
        _buildFilterChip('Featured', () {
          ref
              .read(productProvider.notifier)
              .applyFilter(filter.copyWith(isFeatured: null));
        }),
      );
    }

    if (filter.isFresh == true) {
      chips.add(
        _buildFilterChip('Fresh', () {
          ref
              .read(productProvider.notifier)
              .applyFilter(filter.copyWith(isFresh: null));
        }),
      );
    }

    if (filter.minPrice != null || filter.maxPrice != null) {
      final priceText = filter.minPrice != null && filter.maxPrice != null
          ? '\$${filter.minPrice!.toStringAsFixed(0)} - \$${filter.maxPrice!.toStringAsFixed(0)}'
          : filter.minPrice != null
          ? 'Min \$${filter.minPrice!.toStringAsFixed(0)}'
          : 'Max \$${filter.maxPrice!.toStringAsFixed(0)}';

      chips.add(
        _buildFilterChip(priceText, () {
          ref
              .read(productProvider.notifier)
              .applyFilter(filter.copyWith(minPrice: null, maxPrice: null));
        }),
      );
    }

    if (chips.isNotEmpty) {
      chips.add(
        Padding(
          padding: EdgeInsets.only(left: 8.w),
          child: TextButton(
            onPressed: () => ref.read(productProvider.notifier).clearFilter(),
            child: const Text('Clear All'),
          ),
        ),
      );
    }

    return chips;
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: Chip(
        label: Text(label),
        deleteIcon: const Icon(Icons.close, size: 18),
        onDeleted: onRemove,
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.defaultBorderRadius),
        ),
      ),
      builder: (context) => ProductFilterSheet(
        currentFilter: ref.read(productProvider).currentFilter,
        onApplyFilter: (filter) {
          ref.read(productProvider.notifier).applyFilter(filter);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
