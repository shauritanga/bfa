import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_constants.dart';

class QuantitySelector extends StatelessWidget {
  final double quantity;
  final double minQuantity;
  final double maxQuantity;
  final double step;
  final Function(double) onQuantityChanged;
  final bool enabled;
  final bool showTextField;

  const QuantitySelector({
    super.key,
    required this.quantity,
    this.minQuantity = 0,
    this.maxQuantity = 999,
    this.step = 1,
    required this.onQuantityChanged,
    this.enabled = true,
    this.showTextField = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (showTextField) {
      return _buildTextFieldSelector(theme);
    } else {
      return _buildButtonSelector(theme);
    }
  }

  Widget _buildButtonSelector(ThemeData theme) {
    final canDecrease = enabled && quantity > minQuantity;
    final canIncrease = enabled && quantity < maxQuantity;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrease Button
          _buildQuantityButton(
            icon: Icons.remove,
            onPressed: canDecrease ? () => _decreaseQuantity() : null,
            theme: theme,
          ),

          // Quantity Display
          Container(
            constraints: BoxConstraints(minWidth: 48.w),
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            child: Text(
              _formatQuantity(quantity),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Increase Button
          _buildQuantityButton(
            icon: Icons.add,
            onPressed: canIncrease ? () => _increaseQuantity() : null,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldSelector(ThemeData theme) {
    final controller = TextEditingController(text: _formatQuantity(quantity));

    return SizedBox(
      width: 80.w,
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.defaultBorderRadius,
            ),
          ),
          suffixIcon: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: enabled && quantity < maxQuantity
                    ? _increaseQuantity
                    : null,
                child: Icon(
                  Icons.keyboard_arrow_up,
                  size: 16.w,
                  color: enabled && quantity < maxQuantity
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ),
              InkWell(
                onTap: enabled && quantity > minQuantity
                    ? _decreaseQuantity
                    : null,
                child: Icon(
                  Icons.keyboard_arrow_down,
                  size: 16.w,
                  color: enabled && quantity > minQuantity
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
        ),
        onChanged: (value) {
          final newQuantity = double.tryParse(value);
          if (newQuantity != null &&
              newQuantity >= minQuantity &&
              newQuantity <= maxQuantity) {
            onQuantityChanged(newQuantity);
          }
        },
        onFieldSubmitted: (value) {
          final newQuantity = double.tryParse(value);
          if (newQuantity != null) {
            final clampedQuantity = newQuantity.clamp(minQuantity, maxQuantity);
            onQuantityChanged(clampedQuantity);
            controller.text = _formatQuantity(clampedQuantity);
          } else {
            controller.text = _formatQuantity(quantity);
          }
        },
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      child: Container(
        width: 32.w,
        height: 32.h,
        decoration: BoxDecoration(
          color: onPressed != null
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        child: Icon(
          icon,
          size: 16.w,
          color: onPressed != null
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  void _increaseQuantity() {
    final newQuantity = (quantity + step).clamp(minQuantity, maxQuantity);
    if (newQuantity != quantity) {
      onQuantityChanged(newQuantity);
    }
  }

  void _decreaseQuantity() {
    final newQuantity = (quantity - step).clamp(minQuantity, maxQuantity);
    if (newQuantity != quantity) {
      onQuantityChanged(newQuantity);
    }
  }

  String _formatQuantity(double quantity) {
    if (quantity == quantity.roundToDouble()) {
      return quantity.toInt().toString();
    } else {
      return quantity.toStringAsFixed(1);
    }
  }
}

/// Compact quantity selector for product cards
class CompactQuantitySelector extends StatelessWidget {
  final double quantity;
  final double maxQuantity;
  final Function(double) onQuantityChanged;
  final bool enabled;

  const CompactQuantitySelector({
    super.key,
    required this.quantity,
    this.maxQuantity = 999,
    required this.onQuantityChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (quantity == 0) {
      return _buildAddButton(theme);
    } else {
      return _buildQuantityControls(theme);
    }
  }

  Widget _buildAddButton(ThemeData theme) {
    return SizedBox(
      width: 80.w,
      height: 32.h,
      child: ElevatedButton(
        onPressed: enabled ? () => onQuantityChanged(1) : null,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.defaultBorderRadius,
            ),
          ),
        ),
        child: Text(
          'Add',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityControls(ThemeData theme) {
    return Container(
      width: 80.w,
      height: 32.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Row(
        children: [
          // Decrease Button
          Expanded(
            child: InkWell(
              onTap: enabled ? () => _decreaseQuantity() : null,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(AppConstants.defaultBorderRadius),
              ),
              child: SizedBox(
                height: double.infinity,
                child: Icon(
                  Icons.remove,
                  size: 16.w,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ),

          // Quantity Display
          SizedBox(
            width: 32.w,
            child: Text(
              quantity.toInt().toString(),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Increase Button
          Expanded(
            child: InkWell(
              onTap: enabled && quantity < maxQuantity
                  ? () => _increaseQuantity()
                  : null,
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(AppConstants.defaultBorderRadius),
              ),
              child: SizedBox(
                height: double.infinity,
                child: Icon(
                  Icons.add,
                  size: 16.w,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _increaseQuantity() {
    if (quantity < maxQuantity) {
      onQuantityChanged(quantity + 1);
    }
  }

  void _decreaseQuantity() {
    if (quantity > 0) {
      onQuantityChanged(quantity - 1);
    }
  }
}
