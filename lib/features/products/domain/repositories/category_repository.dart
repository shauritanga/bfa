import '../../../../core/utils/result.dart';
import '../../../../core/repositories/base_repository.dart';
import '../entities/category_entity.dart';

/// Category repository interface
abstract class CategoryRepository extends BaseRepository<CategoryEntity, String> {
  /// Get all root categories (no parent)
  Future<Result<List<CategoryEntity>>> getRootCategories();

  /// Get subcategories for a parent category
  Future<Result<List<CategoryEntity>>> getSubcategories({
    required String parentCategoryId,
  });

  /// Get category hierarchy (category with its subcategories)
  Future<Result<CategoryHierarchy>> getCategoryHierarchy({
    required String categoryId,
  });

  /// Get all categories in a flat list
  Future<Result<List<CategoryEntity>>> getAllCategoriesFlat();

  /// Get categories with product counts
  Future<Result<List<CategoryEntity>>> getCategoriesWithProductCounts();

  /// Get active categories only
  Future<Result<List<CategoryEntity>>> getActiveCategories();

  /// Search categories by name
  Future<Result<List<CategoryEntity>>> searchCategories({
    required String query,
  });

  /// Get popular categories (most products)
  Future<Result<List<CategoryEntity>>> getPopularCategories({
    int limit = 10,
  });

  /// Update category product count
  Future<Result<void>> updateCategoryProductCount({
    required String categoryId,
    required int productCount,
  });

  /// Get category path (breadcrumb)
  Future<Result<List<CategoryEntity>>> getCategoryPath({
    required String categoryId,
  });

  /// Reorder categories
  Future<Result<void>> reorderCategories({
    required List<String> categoryIds,
  });
}

/// Category hierarchy data structure
class CategoryHierarchy {
  final CategoryEntity category;
  final List<CategoryEntity> subcategories;
  final CategoryEntity? parentCategory;

  const CategoryHierarchy({
    required this.category,
    required this.subcategories,
    this.parentCategory,
  });

  /// Check if category has subcategories
  bool get hasSubcategories => subcategories.isNotEmpty;

  /// Check if category has parent
  bool get hasParent => parentCategory != null;

  /// Get total product count including subcategories
  int get totalProductCount {
    int total = category.productCount;
    for (final subcategory in subcategories) {
      total += subcategory.productCount;
    }
    return total;
  }

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'category': category.toMap(),
      'subcategories': subcategories.map((c) => c.toMap()).toList(),
      'parentCategory': parentCategory?.toMap(),
    };
  }

  /// Create from map
  factory CategoryHierarchy.fromMap(Map<String, dynamic> map) {
    return CategoryHierarchy(
      category: CategoryEntity.fromMap(map['category']),
      subcategories: (map['subcategories'] as List<dynamic>)
          .map((c) => CategoryEntity.fromMap(c))
          .toList(),
      parentCategory: map['parentCategory'] != null
          ? CategoryEntity.fromMap(map['parentCategory'])
          : null,
    );
  }
}
