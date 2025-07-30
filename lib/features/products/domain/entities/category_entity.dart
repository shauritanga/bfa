import 'package:equatable/equatable.dart';

/// Category entity representing product categories
class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final String? iconName; // Material icon name
  final String? parentCategoryId; // For subcategories
  final List<String> subcategoryIds;
  final int productCount;
  final bool isActive;
  final int sortOrder;
  final Map<String, dynamic> metadata; // Additional category-specific data
  final DateTime createdAt;
  final DateTime updatedAt;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    this.iconName,
    this.parentCategoryId,
    required this.subcategoryIds,
    required this.productCount,
    required this.isActive,
    required this.sortOrder,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if this is a root category (no parent)
  bool get isRootCategory => parentCategoryId == null;

  /// Check if this category has subcategories
  bool get hasSubcategories => subcategoryIds.isNotEmpty;

  /// Create a copy with updated fields
  CategoryEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? iconName,
    String? parentCategoryId,
    List<String>? subcategoryIds,
    int? productCount,
    bool? isActive,
    int? sortOrder,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      iconName: iconName ?? this.iconName,
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
      subcategoryIds: subcategoryIds ?? this.subcategoryIds,
      productCount: productCount ?? this.productCount,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'iconName': iconName,
      'parentCategoryId': parentCategoryId,
      'subcategoryIds': subcategoryIds,
      'productCount': productCount,
      'isActive': isActive,
      'sortOrder': sortOrder,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from map (Firestore document)
  factory CategoryEntity.fromMap(Map<String, dynamic> map) {
    return CategoryEntity(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'],
      iconName: map['iconName'],
      parentCategoryId: map['parentCategoryId'],
      subcategoryIds: List<String>.from(map['subcategoryIds'] ?? []),
      productCount: map['productCount'] ?? 0,
      isActive: map['isActive'] ?? true,
      sortOrder: map['sortOrder'] ?? 0,
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        imageUrl,
        iconName,
        parentCategoryId,
        subcategoryIds,
        productCount,
        isActive,
        sortOrder,
        metadata,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'CategoryEntity(id: $id, name: $name, productCount: $productCount, isActive: $isActive)';
  }
}

/// Predefined category types for crops
enum CropCategoryType {
  vegetables,
  fruits,
  grains,
  legumes,
  herbs,
  spices,
  nuts,
  seeds,
}

/// Extension for crop category type
extension CropCategoryTypeExtension on CropCategoryType {
  String get name {
    switch (this) {
      case CropCategoryType.vegetables:
        return 'Vegetables';
      case CropCategoryType.fruits:
        return 'Fruits';
      case CropCategoryType.grains:
        return 'Grains';
      case CropCategoryType.legumes:
        return 'Legumes';
      case CropCategoryType.herbs:
        return 'Herbs';
      case CropCategoryType.spices:
        return 'Spices';
      case CropCategoryType.nuts:
        return 'Nuts';
      case CropCategoryType.seeds:
        return 'Seeds';
    }
  }

  String get description {
    switch (this) {
      case CropCategoryType.vegetables:
        return 'Fresh vegetables from local farms';
      case CropCategoryType.fruits:
        return 'Seasonal fruits and berries';
      case CropCategoryType.grains:
        return 'Cereals and grain products';
      case CropCategoryType.legumes:
        return 'Beans, peas, and lentils';
      case CropCategoryType.herbs:
        return 'Fresh herbs and leafy greens';
      case CropCategoryType.spices:
        return 'Aromatic spices and seasonings';
      case CropCategoryType.nuts:
        return 'Tree nuts and dried fruits';
      case CropCategoryType.seeds:
        return 'Seeds for planting and consumption';
    }
  }

  String get iconName {
    switch (this) {
      case CropCategoryType.vegetables:
        return 'eco';
      case CropCategoryType.fruits:
        return 'apple';
      case CropCategoryType.grains:
        return 'grain';
      case CropCategoryType.legumes:
        return 'spa';
      case CropCategoryType.herbs:
        return 'local_florist';
      case CropCategoryType.spices:
        return 'restaurant';
      case CropCategoryType.nuts:
        return 'nature';
      case CropCategoryType.seeds:
        return 'scatter_plot';
    }
  }
}
