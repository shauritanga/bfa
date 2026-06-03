import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../providers/product_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';

// State providers for local state management
final selectedQuantityProvider = StateProvider.family<int, String>(
  (ref, productId) => 1,
);
final currentImageIndexProvider = StateProvider.family<int, String>(
  (ref, productId) => 0,
);

class ProductDetailsScreen extends ConsumerStatefulWidget {
  const ProductDetailsScreen({required this.productId, super.key});

  final String productId;

  @override
  ConsumerState<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Load the product immediately when the screen is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProduct();
    });
  }

  @override
  void didUpdateWidget(ProductDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the productId changed, load the new product
    if (oldWidget.productId != widget.productId) {
      _loadProduct();
    }
  }

  void _loadProduct() {
    final currentProduct = ref.read(productProvider).selectedProduct;
    // Only load if we don't have the right product or no product at all
    if (currentProduct == null || currentProduct.id != widget.productId) {
      ref.read(productProvider.notifier).selectProduct(widget.productId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productState = ref.watch(productProvider);
    final product = productState.selectedProduct;

    if (productState.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Product Details'),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
        body: const Center(child: LoadingWidget()),
      );
    }

    if (productState.error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Product Details'),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64.sp,
                color: theme.colorScheme.error,
              ),
              SizedBox(height: 16.h),
              Text(
                'Error loading product',
                style: theme.textTheme.headlineSmall,
              ),
              SizedBox(height: 8.h),
              Text(
                productState.error!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(productProvider.notifier)
                      .selectProduct(widget.productId);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (product == null || product.id != widget.productId) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Product Details'),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 64.sp,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              SizedBox(height: 16.h),
              Text('Product not found', style: theme.textTheme.headlineSmall),
              SizedBox(height: 8.h),
              Text(
                'The product you\'re looking for doesn\'t exist.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // App Bar with Product Images
          _buildSliverAppBar(theme, product, ref),

          // Product Details Content
          SliverToBoxAdapter(child: _buildProductContent(theme, product, ref)),
        ],
      ),

      // Bottom Action Bar
      bottomNavigationBar: _buildBottomActionBar(context, theme, product, ref),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme, dynamic product, WidgetRef ref) {
    final currentImageIndex = ref.watch(
      currentImageIndexProvider(widget.productId),
    );
    return SliverAppBar(
      expandedHeight: 300.h,
      pinned: true,
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Product Images Carousel
            PageView.builder(
              onPageChanged: (index) {
                ref
                        .read(
                          currentImageIndexProvider(widget.productId).notifier,
                        )
                        .state =
                    index;
              },
              itemCount: product.imageUrls.length,
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  imageUrl: product.imageUrls[index],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.image_not_supported,
                      size: 64.sp,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),

            // Image Indicators
            if (product.imageUrls.length > 1)
              Positioned(
                bottom: 16.h,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    product.imageUrls.length,
                    (index) => Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      width: 8.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentImageIndex == index
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onPrimary.withValues(
                                alpha: 0.5,
                              ),
                      ),
                    ),
                  ),
                ),
              ),

            // Discount Badge
            if (product.hasDiscount)
              Positioned(
                top: 16.h,
                right: 16.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '${((product.price - product.effectivePrice) / product.price * 100).round()}% OFF',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onError,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductContent(ThemeData theme, dynamic product, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Name and Rating
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 16.sp, color: Colors.amber),
                    SizedBox(width: 4.w),
                    Text(
                      product.rating.toStringAsFixed(1),
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      ' (${product.reviewCount})',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Farmer Info
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: theme.colorScheme.primary,
                  child: Icon(
                    Icons.person,
                    color: theme.colorScheme.onPrimary,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Farmer',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                      Text(
                        product.farmerName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.location_on_outlined,
                  size: 16.sp,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: 4.w),
                Text(
                  product.location,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Price Section
          _buildPriceSection(theme, product),

          SizedBox(height: 16.h),

          // Quantity Selector
          _buildQuantitySection(theme, product, ref),

          SizedBox(height: 20.h),

          // Product Details
          _buildProductDetails(theme, product),

          SizedBox(height: 20.h),

          // Description
          if (product.description.isNotEmpty) ...[
            Text(
              'Description',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              product.description,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            SizedBox(height: 20.h),
          ],

          // Tags
          if (product.tags.isNotEmpty) ...[
            Text(
              'Tags',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: product.tags.map<Widget>((tag) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Text(
                    tag,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          SizedBox(height: 100.h), // Space for bottom bar
        ],
      ),
    );
  }

  Widget _buildPriceSection(ThemeData theme, dynamic product) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (product.hasDiscount) ...[
                  Text(
                    Helpers.formatCurrency(product.price),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  SizedBox(height: 4.h),
                ],
                Row(
                  children: [
                    Text(
                      Helpers.formatCurrency(product.effectivePrice),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      '/${product.unit}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (product.isAvailable)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'Available',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'Out of Stock',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onError,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuantitySection(
    ThemeData theme,
    dynamic product,
    WidgetRef ref,
  ) {
    final selectedQuantity = ref.watch(
      selectedQuantityProvider(widget.productId),
    );
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Text(
            'Quantity',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: selectedQuantity > 1
                      ? () {
                          ref
                              .read(
                                selectedQuantityProvider(
                                  widget.productId,
                                ).notifier,
                              )
                              .state--;
                        }
                      : null,
                  icon: const Icon(Icons.remove),
                  iconSize: 20.sp,
                ),
                Container(
                  width: 50.w,
                  alignment: Alignment.center,
                  child: Text(
                    selectedQuantity.toString(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: selectedQuantity < product.quantity
                      ? () {
                          ref
                              .read(
                                selectedQuantityProvider(
                                  widget.productId,
                                ).notifier,
                              )
                              .state++;
                        }
                      : null,
                  icon: const Icon(Icons.add),
                  iconSize: 20.sp,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetails(ThemeData theme, dynamic product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Details',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: [
              _buildDetailRow(theme, 'Category', product.categoryId),
              _buildDetailRow(
                theme,
                'Harvest Date',
                '${product.harvestDate.day}/${product.harvestDate.month}/${product.harvestDate.year}',
              ),
              if (product.expiryDate != null)
                _buildDetailRow(
                  theme,
                  'Best Before',
                  '${product.expiryDate!.day}/${product.expiryDate!.month}/${product.expiryDate!.year}',
                ),
              _buildDetailRow(
                theme,
                'Available Quantity',
                '${product.quantity} ${product.unit}',
              ),
              if (product.isOrganic) _buildDetailRow(theme, 'Organic', 'Yes'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(
    BuildContext context,
    ThemeData theme,
    dynamic product,
    WidgetRef ref,
  ) {
    final selectedQuantity = ref.watch(
      selectedQuantityProvider(widget.productId),
    );
    return Container(
      padding: EdgeInsets.all(16.w),
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
        child: Row(
          children: [
            // Total Price
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    Helpers.formatCurrency(
                      product.effectivePrice * selectedQuantity,
                    ),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 16.w),
            // Add to Cart Button
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: product.isAvailable
                    ? () {
                        // Add to cart logic
                        _addToCart(context, product);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                icon: Icon(Icons.shopping_cart_outlined, size: 20.sp),
                label: Text(
                  'Add to Cart',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart(BuildContext context, dynamic product) {
    final selectedQuantity = ref.read(
      selectedQuantityProvider(widget.productId),
    );

    // Add item to cart
    ref
        .read(cartProvider.notifier)
        .addItem(product: product, quantity: selectedQuantity.toDouble());

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
                '$selectedQuantity x ${product.name} added to cart!',
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
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
