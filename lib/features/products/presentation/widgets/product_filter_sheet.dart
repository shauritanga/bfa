import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/product_filter.dart';
import '../../../../core/constants/app_constants.dart';

class ProductFilterSheet extends StatefulWidget {
  final ProductFilter currentFilter;
  final Function(ProductFilter) onApplyFilter;

  const ProductFilterSheet({
    super.key,
    required this.currentFilter,
    required this.onApplyFilter,
  });

  @override
  State<ProductFilterSheet> createState() => _ProductFilterSheetState();
}

class _ProductFilterSheetState extends State<ProductFilterSheet> {
  late ProductFilter _filter;
  RangeValues _priceRange = const RangeValues(0, 100);

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
    
    // Initialize price range
    _priceRange = RangeValues(
      _filter.minPrice ?? 0,
      _filter.maxPrice ?? 100,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.defaultBorderRadius),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(top: 12.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Text(
                  'Filter Products',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _clearAllFilters,
                  child: Text(
                    'Clear All',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filter Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price Range
                  _buildSectionTitle('Price Range'),
                  _buildPriceRangeFilter(),
                  SizedBox(height: 24.h),

                  // Product Type
                  _buildSectionTitle('Product Type'),
                  _buildProductTypeFilters(),
                  SizedBox(height: 24.h),

                  // Availability
                  _buildSectionTitle('Availability'),
                  _buildAvailabilityFilters(),
                  SizedBox(height: 24.h),

                  // Sort By
                  _buildSectionTitle('Sort By'),
                  _buildSortByFilter(),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),

          // Apply Button
          Padding(
            padding: EdgeInsets.all(16.w),
            child: SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: _applyFilters,
                child: const Text('Apply Filters'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPriceRangeFilter() {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          children: [
            Text(
              '\$${_priceRange.start.toStringAsFixed(0)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              '\$${_priceRange.end.toStringAsFixed(0)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        RangeSlider(
          values: _priceRange,
          min: 0,
          max: 200,
          divisions: 40,
          onChanged: (values) {
            setState(() {
              _priceRange = values;
            });
          },
        ),
      ],
    );
  }

  Widget _buildProductTypeFilters() {
    return Column(
      children: [
        CheckboxListTile(
          title: const Text('Organic'),
          value: _filter.isOrganic ?? false,
          onChanged: (value) {
            setState(() {
              _filter = _filter.copyWith(isOrganic: value);
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: const Text('Featured'),
          value: _filter.isFeatured ?? false,
          onChanged: (value) {
            setState(() {
              _filter = _filter.copyWith(isFeatured: value);
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: const Text('Fresh (Recently Harvested)'),
          value: _filter.isFresh ?? false,
          onChanged: (value) {
            setState(() {
              _filter = _filter.copyWith(isFresh: value);
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildAvailabilityFilters() {
    return CheckboxListTile(
      title: const Text('In Stock Only'),
      value: _filter.isAvailable ?? false,
      onChanged: (value) {
        setState(() {
          _filter = _filter.copyWith(isAvailable: value);
        });
      },
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSortByFilter() {
    return Column(
      children: ProductSortBy.values.map((sortBy) {
        return RadioListTile<ProductSortBy>(
          title: Text(sortBy.displayName),
          value: sortBy,
          groupValue: _filter.sortBy,
          onChanged: (value) {
            setState(() {
              _filter = _filter.copyWith(sortBy: value);
            });
          },
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _filter = ProductFilter.empty();
      _priceRange = const RangeValues(0, 100);
    });
  }

  void _applyFilters() {
    final updatedFilter = _filter.copyWith(
      minPrice: _priceRange.start > 0 ? _priceRange.start : null,
      maxPrice: _priceRange.end < 200 ? _priceRange.end : null,
    );
    
    widget.onApplyFilter(updatedFilter);
  }
}
