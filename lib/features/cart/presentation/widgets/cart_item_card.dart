import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/quantity_selector.dart';

class CartItemCard extends StatelessWidget {
  final CartItemEntity item;
  final bool isUpdating;
  final Function(double) onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.item,
    this.isUpdating = false,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                _buildProductImage(theme),
                SizedBox(width: 12.w),

                // Product Details
                Expanded(child: _buildProductDetails(theme)),

                // Remove Button
                IconButton(
                  onPressed: isUpdating ? null : onRemove,
                  icon: Icon(
                    Icons.close,
                    color: theme.colorScheme.error,
                    size: 20.w,
                  ),
                  constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.h),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Quantity and Price Row
            Row(
              children: [
                // Quantity Selector
                QuantitySelector(
                  quantity: item.quantity,
                  minQuantity: 0,
                  maxQuantity: item.maxAvailableQuantity,
                  onQuantityChanged: onQuantityChanged,
                  enabled: !isUpdating && item.isProductAvailable,
                ),

                const Spacer(),

                // Price Information
                _buildPriceInfo(theme),
              ],
            ),

            // Warnings/Issues
            if (!item.isProductAvailable || item.exceedsStock)
              _buildWarnings(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(ThemeData theme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: SizedBox(
        width: 80.w,
        height: 80.h,
        child: item.product.primaryImageUrl != null
            ? CachedNetworkImage(
                imageUrl: item.product.primaryImageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const Center(child: LoadingWidget()),
                errorWidget: (context, url, error) => Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.image_not_supported,
                    size: 32.w,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              )
            : Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.image_not_supported,
                  size: 32.w,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
      ),
    );
  }

  Widget _buildProductDetails(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Name
        Text(
          item.product.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4.h),

        // Farmer Name
        Text(
          'by ${item.product.farmerName}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        SizedBox(height: 4.h),

        // Product Badges
        Wrap(
          spacing: 4.w,
          runSpacing: 4.h,
          children: [
            if (item.product.isOrganic)
              _buildBadge('Organic', Colors.green, theme),
            if (item.product.isFresh) _buildBadge('Fresh', Colors.blue, theme),
            if (item.hasDiscount)
              _buildBadge(
                '${item.discountPercentage.toStringAsFixed(0)}% OFF',
                theme.colorScheme.error,
                theme,
              ),
          ],
        ),

        // Notes
        if (item.notes != null && item.notes!.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              'Note: ${item.notes}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPriceInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Unit Price
        if (item.hasDiscount) ...[
          Text(
            Helpers.formatCurrency(item.unitPrice),
            style: theme.textTheme.bodySmall?.copyWith(
              decoration: TextDecoration.lineThrough,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
        Text(
          '${Helpers.formatCurrency(item.effectiveUnitPrice)}/${item.unit}',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: item.hasDiscount
                ? theme.colorScheme.error
                : theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 4.h),

        // Total Price
        Text(
          'Total: ${Helpers.formatCurrency(item.totalPrice)}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),

        // Savings
        if (item.totalSavings > 0) ...[
          SizedBox(height: 2.h),
          Text(
            'Save ${Helpers.formatCurrency(item.totalSavings)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildWarnings(ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(top: 12.h),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning,
            size: 16.w,
            color: theme.colorScheme.onErrorContainer,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              !item.isProductAvailable
                  ? 'This product is no longer available'
                  : 'Only ${item.maxAvailableQuantity.toStringAsFixed(0)} ${item.unit} available',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color, ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
