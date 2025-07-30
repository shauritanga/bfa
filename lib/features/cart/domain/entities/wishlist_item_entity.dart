import 'package:equatable/equatable.dart';
import '../../../products/domain/entities/product_entity.dart';

/// Wishlist item entity representing a product in the user's wishlist
class WishlistItemEntity extends Equatable {
  final String id;
  final String productId;
  final String userId;
  final ProductEntity product;
  final String? notes;
  final DateTime addedAt;

  const WishlistItemEntity({
    required this.id,
    required this.productId,
    required this.userId,
    required this.product,
    this.notes,
    required this.addedAt,
  });

  /// Check if the product is still available
  bool get isProductAvailable => product.isAvailable;

  /// Check if the product has a discount
  bool get hasDiscount => product.hasDiscount;

  /// Check if the product is fresh
  bool get isFresh => product.isFresh;

  /// Check if the product is organic
  bool get isOrganic => product.isOrganic;

  /// Get the product's effective price
  double get effectivePrice => product.effectivePrice;

  /// Create a copy with updated fields
  WishlistItemEntity copyWith({
    String? id,
    String? productId,
    String? userId,
    ProductEntity? product,
    String? notes,
    DateTime? addedAt,
  }) {
    return WishlistItemEntity(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      userId: userId ?? this.userId,
      product: product ?? this.product,
      notes: notes ?? this.notes,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  /// Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'userId': userId,
      'product': product.toMap(),
      'notes': notes,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  /// Create from map (Firestore document)
  factory WishlistItemEntity.fromMap(Map<String, dynamic> map) {
    return WishlistItemEntity(
      id: map['id'] ?? '',
      productId: map['productId'] ?? '',
      userId: map['userId'] ?? '',
      product: ProductEntity.fromMap(map['product']),
      notes: map['notes'],
      addedAt: DateTime.parse(map['addedAt']),
    );
  }

  /// Create from product
  factory WishlistItemEntity.fromProduct({
    required String id,
    required String userId,
    required ProductEntity product,
    String? notes,
  }) {
    return WishlistItemEntity(
      id: id,
      productId: product.id,
      userId: userId,
      product: product,
      notes: notes,
      addedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        userId,
        product,
        notes,
        addedAt,
      ];

  @override
  String toString() {
    return 'WishlistItemEntity(id: $id, productId: $productId, productName: ${product.name})';
  }
}

/// Wishlist entity representing a user's wishlist
class WishlistEntity extends Equatable {
  final String id;
  final String userId;
  final List<WishlistItemEntity> items;
  final String? name;
  final String? description;
  final bool isPublic;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WishlistEntity({
    required this.id,
    required this.userId,
    required this.items,
    this.name,
    this.description,
    this.isPublic = false,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if wishlist is empty
  bool get isEmpty => items.isEmpty;

  /// Check if wishlist has items
  bool get isNotEmpty => items.isNotEmpty;

  /// Get total number of items in wishlist
  int get itemCount => items.length;

  /// Get available items (products that are still available)
  List<WishlistItemEntity> get availableItems => 
      items.where((item) => item.isProductAvailable).toList();

  /// Get unavailable items
  List<WishlistItemEntity> get unavailableItems => 
      items.where((item) => !item.isProductAvailable).toList();

  /// Get items with discounts
  List<WishlistItemEntity> get discountedItems => 
      items.where((item) => item.hasDiscount).toList();

  /// Get organic items
  List<WishlistItemEntity> get organicItems => 
      items.where((item) => item.isOrganic).toList();

  /// Get fresh items
  List<WishlistItemEntity> get freshItems => 
      items.where((item) => item.isFresh).toList();

  /// Calculate total value of all items
  double get totalValue => items.fold(0.0, (sum, item) => sum + item.effectivePrice);

  /// Calculate potential savings from discounted items
  double get potentialSavings => discountedItems.fold(0.0, (sum, item) => 
      sum + (item.product.price - item.effectivePrice));

  /// Find item by product ID
  WishlistItemEntity? findItemByProductId(String productId) {
    try {
      return items.firstWhere((item) => item.productId == productId);
    } catch (e) {
      return null;
    }
  }

  /// Check if product is in wishlist
  bool containsProduct(String productId) {
    return findItemByProductId(productId) != null;
  }

  /// Add item to wishlist
  WishlistEntity addItem(WishlistItemEntity newItem) {
    // Check if item already exists
    if (containsProduct(newItem.productId)) {
      return this; // Don't add duplicate
    }

    final updatedItems = [...items, newItem];
    return copyWith(
      items: updatedItems,
      updatedAt: DateTime.now(),
    );
  }

  /// Remove item from wishlist
  WishlistEntity removeItem(String productId) {
    final updatedItems = items.where((item) => item.productId != productId).toList();
    
    return copyWith(
      items: updatedItems,
      updatedAt: DateTime.now(),
    );
  }

  /// Clear all items from wishlist
  WishlistEntity clearItems() {
    return copyWith(
      items: [],
      updatedAt: DateTime.now(),
    );
  }

  /// Update wishlist details
  WishlistEntity updateDetails({
    String? name,
    String? description,
    bool? isPublic,
  }) {
    return copyWith(
      name: name ?? this.name,
      description: description ?? this.description,
      isPublic: isPublic ?? this.isPublic,
      updatedAt: DateTime.now(),
    );
  }

  /// Create a copy with updated fields
  WishlistEntity copyWith({
    String? id,
    String? userId,
    List<WishlistItemEntity>? items,
    String? name,
    String? description,
    bool? isPublic,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WishlistEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      name: name ?? this.name,
      description: description ?? this.description,
      isPublic: isPublic ?? this.isPublic,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'name': name,
      'description': description,
      'isPublic': isPublic,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from map (Firestore document)
  factory WishlistEntity.fromMap(Map<String, dynamic> map) {
    return WishlistEntity(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      items: (map['items'] as List<dynamic>?)
          ?.map((item) => WishlistItemEntity.fromMap(item))
          .toList() ?? [],
      name: map['name'],
      description: map['description'],
      isPublic: map['isPublic'] ?? false,
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  /// Create empty wishlist
  factory WishlistEntity.empty({
    required String id,
    required String userId,
    String? name,
  }) {
    final now = DateTime.now();
    return WishlistEntity(
      id: id,
      userId: userId,
      items: [],
      name: name ?? 'My Wishlist',
      metadata: {},
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        items,
        name,
        description,
        isPublic,
        metadata,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'WishlistEntity(id: $id, userId: $userId, name: $name, itemCount: $itemCount)';
  }
}
