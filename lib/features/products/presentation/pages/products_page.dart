import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/product_filter_sheet.dart';
import '../widgets/product_search_bar.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';

class ProductsPage extends ConsumerStatefulWidget {
  final String? categoryId;
  final String? searchQuery;

  const ProductsPage({
    super.key,
    this.categoryId,
    this.searchQuery,
  });

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
    
    // Apply initial filters if provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.categoryId != null) {
        ref.read(productProvider.notifier).applyFilter(
          ref.read(productProvider).currentFilter.copyWith(
            categoryIds: [widget.categoryId!],
          ),
        );
      }
      
      if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
        ref.read(productProvider.notifier).searchProducts(widget.searchQuery!);
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

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryId != null ? 'Category Products' : 'Products'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(AppConstants.defaultPadding.w),
            child: ProductSearchBar(
              initialQuery: widget.searchQuery,
              onSearch: (query) {
                ref.read(productProvider.notifier).searchProducts(query);
              },
              onClear: () {
                ref.read(productProvider.notifier).loadProducts(refresh: true);
              },
            ),
          ),

          // Filter Chips
          if (productState.currentFilter.hasActiveFilters)
            Container(
              height: 50.h,
              padding: EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding.w),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _buildFilterChips(productState),
              ),
            ),

          // Products List/Grid
          Expanded(
            child: _buildProductsList(productState, theme),
          ),
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
          onRetry: () => ref.read(productProvider.notifier).loadProducts(refresh: true),
        ),
      );
    }

    final products = widget.searchQuery != null && widget.searchQuery!.isNotEmpty
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
      onRefresh: () => ref.read(productProvider.notifier).loadProducts(refresh: true),
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
      itemCount: products.length + (ref.watch(productProvider).isLoadingMore ? 2 : 0),
      itemBuilder: (context, index) {
        if (index >= products.length) {
          return const Center(child: LoadingWidget());
        }

        final product = products[index];
        return ProductCard(
          product: product,
          onTap: () => context.push('/products/${product.id}'),
        );
      },
    );
  }

  Widget _buildListView(List products) {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(AppConstants.defaultPadding.w),
      itemCount: products.length + (ref.watch(productProvider).isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= products.length) {
          return const Center(child: LoadingWidget());
        }

        final product = products[index];
        return ProductCard(
          product: product,
          isListView: true,
          onTap: () => context.push('/products/${product.id}'),
        );
      },
    );
  }

  List<Widget> _buildFilterChips(ProductState productState) {
    final chips = <Widget>[];
    final filter = productState.currentFilter;

    if (filter.isOrganic == true) {
      chips.add(_buildFilterChip('Organic', () {
        ref.read(productProvider.notifier).applyFilter(
          filter.copyWith(isOrganic: null),
        );
      }));
    }

    if (filter.isFeatured == true) {
      chips.add(_buildFilterChip('Featured', () {
        ref.read(productProvider.notifier).applyFilter(
          filter.copyWith(isFeatured: null),
        );
      }));
    }

    if (filter.isFresh == true) {
      chips.add(_buildFilterChip('Fresh', () {
        ref.read(productProvider.notifier).applyFilter(
          filter.copyWith(isFresh: null),
        );
      }));
    }

    if (filter.minPrice != null || filter.maxPrice != null) {
      final priceText = filter.minPrice != null && filter.maxPrice != null
          ? '\$${filter.minPrice!.toStringAsFixed(0)} - \$${filter.maxPrice!.toStringAsFixed(0)}'
          : filter.minPrice != null
              ? 'Min \$${filter.minPrice!.toStringAsFixed(0)}'
              : 'Max \$${filter.maxPrice!.toStringAsFixed(0)}';
      
      chips.add(_buildFilterChip(priceText, () {
        ref.read(productProvider.notifier).applyFilter(
          filter.copyWith(minPrice: null, maxPrice: null),
        );
      }));
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
      shape: RoundedRectangleBorder(
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
