import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/cart_entity.dart';
import '../../../../core/constants/app_constants.dart';

class CartSummaryCard extends StatefulWidget {
  final CartEntity cart;
  final Function(String, double)? onApplyCoupon;
  final VoidCallback? onRemoveCoupon;

  const CartSummaryCard({
    super.key,
    required this.cart,
    this.onApplyCoupon,
    this.onRemoveCoupon,
  });

  @override
  State<CartSummaryCard> createState() => _CartSummaryCardState();
}

class _CartSummaryCardState extends State<CartSummaryCard> {
  final TextEditingController _couponController = TextEditingController();
  bool _showCouponField = false;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.all(AppConstants.defaultPadding.w),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Title
            Text(
              'Order Summary',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16.h),

            // Price Breakdown
            _buildPriceRow(
              'Subtotal (${widget.cart.itemCount} items)',
              widget.cart.subtotal,
              theme,
            ),

            if (widget.cart.itemDiscounts > 0)
              _buildPriceRow(
                'Item Discounts',
                -widget.cart.itemDiscounts,
                theme,
                isDiscount: true,
              ),

            // Coupon Section
            if (widget.cart.couponCode != null) ...[
              _buildCouponApplied(theme),
            ] else if (_showCouponField) ...[
              _buildCouponField(theme),
            ] else ...[
              _buildCouponButton(theme),
            ],

            if (widget.cart.deliveryFeeAmount > 0)
              _buildPriceRow(
                'Delivery Fee',
                widget.cart.deliveryFeeAmount,
                theme,
              ),

            SizedBox(height: 12.h),
            Divider(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
            SizedBox(height: 12.h),

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${widget.cart.total.toStringAsFixed(2)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),

            // Total Savings
            if (widget.cart.totalSavings > 0) ...[
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'You save',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    '\$${widget.cart.totalSavings.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount,
    ThemeData theme, {
    bool isDiscount = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          Text(
            '${isDiscount ? '-' : ''}\$${amount.abs().toStringAsFixed(2)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: isDiscount 
                  ? Colors.green 
                  : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponButton(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: InkWell(
        onTap: () {
          setState(() {
            _showCouponField = true;
          });
        },
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          child: Row(
            children: [
              Icon(
                Icons.local_offer_outlined,
                size: 20.w,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: 12.w),
              Text(
                'Apply Coupon Code',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right,
                size: 20.w,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCouponField(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _couponController,
                  decoration: InputDecoration(
                    hintText: 'Enter coupon code',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 12.h,
                    ),
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
              ),
              SizedBox(width: 8.w),
              ElevatedButton(
                onPressed: _applyCoupon,
                child: const Text('Apply'),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _showCouponField = false;
                    _couponController.clear();
                  });
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCouponApplied(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 20.w,
                  color: Colors.green,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Coupon Applied',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        widget.cart.couponCode!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.green.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: widget.onRemoveCoupon,
                  child: Text(
                    'Remove',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          _buildPriceRow(
            'Coupon Discount',
            -widget.cart.couponDiscountAmount,
            theme,
            isDiscount: true,
          ),
        ],
      ),
    );
  }

  void _applyCoupon() {
    final couponCode = _couponController.text.trim().toUpperCase();
    if (couponCode.isNotEmpty && widget.onApplyCoupon != null) {
      // TODO: Validate coupon with backend and get discount amount
      // For now, apply a fixed 10% discount
      final discountAmount = widget.cart.discountedSubtotal * 0.1;
      widget.onApplyCoupon!(couponCode, discountAmount);
      
      setState(() {
        _showCouponField = false;
        _couponController.clear();
      });
    }
  }
}
