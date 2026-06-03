import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category_entity.dart';

/// Category state
class CategoryState {
  final List<CategoryEntity> categories;
  final String? selectedCategoryId;
  final bool isLoading;
  final String? error;

  const CategoryState({
    this.categories = const [],
    this.selectedCategoryId,
    this.isLoading = false,
    this.error,
  });

  CategoryState copyWith({
    List<CategoryEntity>? categories,
    String? selectedCategoryId,
    bool? isLoading,
    String? error,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  CategoryEntity? get selectedCategory {
    if (selectedCategoryId == null) return null;
    try {
      return categories.firstWhere((cat) => cat.id == selectedCategoryId);
    } catch (e) {
      return null;
    }
  }
}

/// Category notifier
class CategoryNotifier extends StateNotifier<CategoryState> {
  CategoryNotifier() : super(const CategoryState()) {
    _loadMockCategories();
  }

  /// Load mock categories (in real app this would come from repository)
  void _loadMockCategories() {
    state = state.copyWith(isLoading: true);

    // Mock categories based on the CropCategoryType enum
    // These IDs should match the categoryId field in your Firestore products
    final mockCategories = [
      CategoryEntity(
        id: 'all',
        name: 'All',
        description: 'All products',
        imageUrl: null,
        iconName: 'apps',
        parentCategoryId: null,
        subcategoryIds: [],
        productCount: 0,
        isActive: true,
        sortOrder: 0,
        metadata: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CategoryEntity(
        id: 'vegetable', // Common variations: 'vegetable', 'vegetables', 'Vegetable'
        name: 'Vegetables',
        description: 'Fresh vegetables from local farms',
        imageUrl: null,
        iconName: 'eco',
        parentCategoryId: null,
        subcategoryIds: [],
        productCount: 25,
        isActive: true,
        sortOrder: 1,
        metadata: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CategoryEntity(
        id: 'fruit', // Common variations: 'fruit', 'fruits', 'Fruit'
        name: 'Fruits',
        description: 'Seasonal fruits and berries',
        imageUrl: null,
        iconName: 'apple',
        parentCategoryId: null,
        subcategoryIds: [],
        productCount: 18,
        isActive: true,
        sortOrder: 2,
        metadata: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CategoryEntity(
        id: 'grains',
        name: 'Grains',
        description: 'Cereals and grain products',
        imageUrl: null,
        iconName: 'grain',
        parentCategoryId: null,
        subcategoryIds: [],
        productCount: 12,
        isActive: true,
        sortOrder: 3,
        metadata: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CategoryEntity(
        id: 'legumes',
        name: 'Legumes',
        description: 'Beans, peas, and lentils',
        imageUrl: null,
        iconName: 'circle',
        parentCategoryId: null,
        subcategoryIds: [],
        productCount: 8,
        isActive: true,
        sortOrder: 4,
        metadata: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CategoryEntity(
        id: 'herbs',
        name: 'Herbs',
        description: 'Fresh herbs and leafy greens',
        imageUrl: null,
        iconName: 'local_florist',
        parentCategoryId: null,
        subcategoryIds: [],
        productCount: 15,
        isActive: true,
        sortOrder: 5,
        metadata: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CategoryEntity(
        id: 'spices',
        name: 'Spices',
        description: 'Aromatic spices and seasonings',
        imageUrl: null,
        iconName: 'restaurant',
        parentCategoryId: null,
        subcategoryIds: [],
        productCount: 10,
        isActive: true,
        sortOrder: 6,
        metadata: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CategoryEntity(
        id: 'nuts',
        name: 'Nuts',
        description: 'Tree nuts and dried fruits',
        imageUrl: null,
        iconName: 'nature',
        parentCategoryId: null,
        subcategoryIds: [],
        productCount: 6,
        isActive: true,
        sortOrder: 7,
        metadata: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CategoryEntity(
        id: 'seeds',
        name: 'Seeds',
        description: 'Seeds for planting and consumption',
        imageUrl: null,
        iconName: 'scatter_plot',
        parentCategoryId: null,
        subcategoryIds: [],
        productCount: 4,
        isActive: true,
        sortOrder: 8,
        metadata: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    state = state.copyWith(
      categories: mockCategories,
      selectedCategoryId: 'all', // Default to "All"
      isLoading: false,
    );
  }

  /// Select a category
  void selectCategory(String categoryId) {
    state = state.copyWith(selectedCategoryId: categoryId);
  }

  /// Clear category selection (show all)
  void clearSelection() {
    state = state.copyWith(selectedCategoryId: 'all');
  }
}

/// Category provider
final categoryProvider = StateNotifierProvider<CategoryNotifier, CategoryState>(
  (ref) {
    return CategoryNotifier();
  },
);
