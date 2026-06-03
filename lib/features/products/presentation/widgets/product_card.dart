import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/product_entity.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../shared/widgets/loading_widget.dart';

class ProductCard extends StatelessWidget {
  final ProductEntity product;
  final bool isListView;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onToggleWishlist;
  final bool isInWishlist;

  const ProductCard({
    super.key,
    required this.product,
    this.isListView = false,
    this.onTap,
    this.onAddToCart,
    this.onToggleWishlist,
    this.isInWishlist = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        child: isListView ? _buildListLayout(theme) : _buildGridLayout(theme),
      ),
    );
  }

  Widget _buildGridLayout(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Image
        Expanded(flex: 3, child: _buildProductImage(theme)),

        // Product Info
        Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.all(8.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Product Name
                Flexible(
                  child: Text(
                    product.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 2.h),

                // Price and Unit
                Flexible(
                  child: Row(
                    children: [
                      if (product.hasDiscount) ...[
                        Flexible(
                          child: Text(
                            Helpers.formatCurrency(product.price),
                            style: theme.textTheme.bodySmall?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                              fontSize: 10.sp,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 2.w),
                      ],
                      Flexible(
                        child: Text(
                          Helpers.formatCurrency(product.effectivePrice),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: product.hasDiscount
                                ? theme.colorScheme.error
                                : theme.colorScheme.primary,
                            fontSize: 12.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          '/${product.unit}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                            fontSize: 10.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),

                // Rating and Availability
                Flexible(
                  child: Row(
                    children: [
                      Icon(Icons.star, size: 12.w, color: Colors.amber),
                      SizedBox(width: 2.w),
                      Flexible(
                        child: Text(
                          product.rating.toStringAsFixed(1),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 10.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Spacer(),
                      if (!product.isAvailable)
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 1.h,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              'Out of Stock',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.error,
                                fontSize: 8.sp,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListLayout(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.all(12.w),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: SizedBox(
              width: 80.w,
              height: 80.h,
              child: _buildProductImage(theme, fit: BoxFit.cover),
            ),
          ),
          SizedBox(width: 12.w),

          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  product.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),

                // Description
                Text(
                  product.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),

                // Price and Rating Row
                Row(
                  children: [
                    // Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (product.hasDiscount)
                          Text(
                            Helpers.formatCurrency(product.price),
                            style: theme.textTheme.bodySmall?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        Row(
                          children: [
                            Text(
                              Helpers.formatCurrency(product.effectivePrice),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: product.hasDiscount
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.primary,
                              ),
                            ),
                            Text(
                              '/${product.unit}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),

                    // Rating
                    Row(
                      children: [
                        Icon(Icons.star, size: 16.w, color: Colors.amber),
                        SizedBox(width: 4.w),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: theme.textTheme.bodyMedium,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '(${product.reviewCount})',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Buttons
          Column(
            children: [
              if (onToggleWishlist != null)
                IconButton(
                  onPressed: onToggleWishlist,
                  icon: Icon(
                    isInWishlist ? Icons.favorite : Icons.favorite_border,
                    color: isInWishlist ? Colors.red : null,
                  ),
                ),
              if (onAddToCart != null && product.isAvailable)
                IconButton(
                  onPressed: onAddToCart,
                  icon: const Icon(Icons.add_shopping_cart),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(ThemeData theme, {BoxFit? fit}) {
    return Stack(
      children: [
        // Main Image
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppConstants.defaultBorderRadius),
            ),
            color: theme.colorScheme.surfaceContainerHighest,
          ),
          child: product.primaryImageUrl != null
              ? CachedNetworkImage(
                  imageUrl: product.primaryImageUrl!,
                  fit: fit ?? BoxFit.cover,
                  placeholder: (context, url) =>
                      const Center(child: LoadingWidget()),
                  errorWidget: (context, url, error) => Icon(
                    Icons.image_not_supported,
                    size: 40.w,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                )
              : Icon(
                  Icons.image_not_supported,
                  size: 40.w,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
        ),

        // Badges
        Positioned(
          top: 8.h,
          left: 8.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (product.hasDiscount)
                _buildBadge(
                  '${product.discountPercentage.toStringAsFixed(0)}% OFF',
                  theme.colorScheme.error,
                  theme.colorScheme.onError,
                ),
              if (product.isOrganic)
                _buildBadge('ORGANIC', Colors.green, Colors.white),
              if (product.isFresh)
                _buildBadge('FRESH', Colors.blue, Colors.white),
            ],
          ),
        ),

        // Wishlist Button (Grid View Only)
        if (!isListView && onToggleWishlist != null)
          Positioned(
            top: 8.h,
            right: 8.w,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: onToggleWishlist,
                icon: Icon(
                  isInWishlist ? Icons.favorite : Icons.favorite_border,
                  color: isInWishlist ? Colors.red : null,
                  size: 20.w,
                ),
                constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.h),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBadge(String text, Color backgroundColor, Color textColor) {
    return Container(
      margin: EdgeInsets.only(bottom: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
