import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/presentation/widgets/product_card.dart';

class SearchResultsWidget extends StatelessWidget {
  final String query;
  final List<ProductEntity> results;
  final Function(ProductEntity) onProductTap;

  const SearchResultsWidget({
    super.key,
    required this.query,
    required this.results,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Results header
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Text(
            'Results for "$query"',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Results count
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            '${results.length} ${results.length == 1 ? 'result' : 'results'} found',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),

        SizedBox(height: 16.h),

        // Results grid
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 0.75,
            ),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final product = results[index];
              return ProductCard(
                product: product,
                onTap: () => onProductTap(product),
                onAddToCart: () {
                  // TODO: Implement add to cart from search
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} added to cart!'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                onToggleWishlist: () {
                  // TODO: Implement wishlist toggle from search
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} added to wishlist!'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
