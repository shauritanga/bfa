import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/category_entity.dart';
import '../providers/category_provider.dart';

class CategoryChipsWidget extends ConsumerWidget {
  final Function(String categoryId) onCategorySelected;

  const CategoryChipsWidget({super.key, required this.onCategorySelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categoryState = ref.watch(categoryProvider);

    if (categoryState.isLoading) {
      return SizedBox(
        height: 50.h,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (categoryState.categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 50.h,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: categoryState.categories.length,
        separatorBuilder: (context, index) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final category = categoryState.categories[index];
          final isSelected = category.id == categoryState.selectedCategoryId;

          return _buildCategoryChip(context, theme, category, isSelected, () {
            ref.read(categoryProvider.notifier).selectCategory(category.id);
            onCategorySelected(category.id);
          });
        },
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    ThemeData theme,
    CategoryEntity category,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category name
            Text(
              category.name,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
