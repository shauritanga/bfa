import 'package:equatable/equatable.dart';

/// Product entity representing a crop/product in the system
class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String unit; // kg, piece, bunch, etc.
  final String categoryId;
  final String farmerId;
  final String farmerName;
  final List<String> imageUrls;
  final double quantity; // Available quantity
  final double? discountPrice;
  final bool isAvailable;
  final bool isOrganic;
  final bool isFeatured;
  final DateTime harvestDate;
  final DateTime? expiryDate;
  final String location; // Farm location
  final double rating;
  final int reviewCount;
  final Map<String, dynamic> nutritionalInfo;
  final List<String> tags; // fresh, local, seasonal, etc.
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    required this.categoryId,
    required this.farmerId,
    required this.farmerName,
    required this.imageUrls,
    required this.quantity,
    this.discountPrice,
    required this.isAvailable,
    required this.isOrganic,
    required this.isFeatured,
    required this.harvestDate,
    this.expiryDate,
    required this.location,
    required this.rating,
    required this.reviewCount,
    required this.nutritionalInfo,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get the effective price (discount price if available, otherwise regular price)
  double get effectivePrice => discountPrice ?? price;

  /// Check if product has discount
  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  /// Get discount percentage
  double get discountPercentage {
    if (!hasDiscount) return 0.0;
    return ((price - discountPrice!) / price) * 100;
  }

  /// Check if product is fresh (harvested within last 3 days)
  bool get isFresh {
    final daysSinceHarvest = DateTime.now().difference(harvestDate).inDays;
    return daysSinceHarvest <= 3;
  }

  /// Check if product is expiring soon (within next 2 days)
  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final daysUntilExpiry = expiryDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 2 && daysUntilExpiry >= 0;
  }

  /// Check if product is expired
  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  /// Get primary image URL
  String? get primaryImageUrl => imageUrls.isNotEmpty ? imageUrls.first : null;

  /// Create a copy with updated fields
  ProductEntity copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? unit,
    String? categoryId,
    String? farmerId,
    String? farmerName,
    List<String>? imageUrls,
    double? quantity,
    double? discountPrice,
    bool? isAvailable,
    bool? isOrganic,
    bool? isFeatured,
    DateTime? harvestDate,
    DateTime? expiryDate,
    String? location,
    double? rating,
    int? reviewCount,
    Map<String, dynamic>? nutritionalInfo,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      categoryId: categoryId ?? this.categoryId,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      imageUrls: imageUrls ?? this.imageUrls,
      quantity: quantity ?? this.quantity,
      discountPrice: discountPrice ?? this.discountPrice,
      isAvailable: isAvailable ?? this.isAvailable,
      isOrganic: isOrganic ?? this.isOrganic,
      isFeatured: isFeatured ?? this.isFeatured,
      harvestDate: harvestDate ?? this.harvestDate,
      expiryDate: expiryDate ?? this.expiryDate,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      nutritionalInfo: nutritionalInfo ?? this.nutritionalInfo,
      tags: tags ?? this.tags,
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
      'price': price,
      'unit': unit,
      'categoryId': categoryId,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'imageUrls': imageUrls,
      'quantity': quantity,
      'discountPrice': discountPrice,
      'isAvailable': isAvailable,
      'isOrganic': isOrganic,
      'isFeatured': isFeatured,
      'harvestDate': harvestDate.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'location': location,
      'rating': rating,
      'reviewCount': reviewCount,
      'nutritionalInfo': nutritionalInfo,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from map (Firestore document)
  factory ProductEntity.fromMap(Map<String, dynamic> map) {
    return ProductEntity(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      unit: map['unit'] ?? '',
      categoryId: map['categoryId'] ?? '',
      farmerId: map['farmerId'] ?? '',
      farmerName: map['farmerName'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      quantity: (map['quantity'] ?? 0.0).toDouble(),
      discountPrice: map['discountPrice']?.toDouble(),
      isAvailable: map['isAvailable'] ?? false,
      isOrganic: map['isOrganic'] ?? false,
      isFeatured: map['isFeatured'] ?? false,
      harvestDate: DateTime.parse(map['harvestDate']),
      expiryDate: map['expiryDate'] != null
          ? DateTime.parse(map['expiryDate'])
          : null,
      location: map['location'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      nutritionalInfo: Map<String, dynamic>.from(map['nutritionalInfo'] ?? {}),
      tags: List<String>.from(map['tags'] ?? []),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    price,
    unit,
    categoryId,
    farmerId,
    farmerName,
    imageUrls,
    quantity,
    discountPrice,
    isAvailable,
    isOrganic,
    isFeatured,
    harvestDate,
    expiryDate,
    location,
    rating,
    reviewCount,
    nutritionalInfo,
    tags,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'ProductEntity(id: $id, name: $name, price: $price, unit: $unit, isAvailable: $isAvailable)';
  }
}
