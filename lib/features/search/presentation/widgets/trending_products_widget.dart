import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TrendingProductsWidget extends StatelessWidget {
  final List<String> trendingSearches;
  final List<String> searchHistory;
  final Function(String) onSearchTap;
  final Function(String) onHistoryTap;
  final VoidCallback onClearHistory;

  const TrendingProductsWidget({
    super.key,
    required this.trendingSearches,
    required this.searchHistory,
    required this.onSearchTap,
    required this.onHistoryTap,
    required this.onClearHistory,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent searches section
          if (searchHistory.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent searches',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: onClearHistory,
                  child: Text(
                    'Clear all',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            ...searchHistory.take(5).map((search) => _buildHistoryItem(
              context,
              search,
              onHistoryTap,
            )),
            SizedBox(height: 24.h),
          ],

          // Trending products section
          Text(
            'Trending products',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16.h),

          // Trending products grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 2.5,
            ),
            itemCount: trendingSearches.length,
            itemBuilder: (context, index) {
              final search = trendingSearches[index];
              return _buildTrendingItem(context, search, onSearchTap);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    String search,
    Function(String) onTap,
  ) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => onTap(search),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            Icon(
              Icons.history,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 20.w,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                search,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            Icon(
              Icons.north_west,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              size: 16.w,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingItem(
    BuildContext context,
    String search,
    Function(String) onTap,
  ) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => onTap(search),
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            // Product placeholder image
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                color: theme.colorScheme.primary,
                size: 16.w,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                search,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
