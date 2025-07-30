import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../entities/wishlist_item_entity.dart';
import '../repositories/wishlist_repository.dart';
import '../../../products/domain/entities/product_entity.dart';

/// Use case for getting user's wishlist
class GetUserWishlistUseCase {
  final WishlistRepository _repository;

  const GetUserWishlistUseCase(this._repository);

  Future<Result<WishlistEntity?>> call(String userId) async {
    if (userId.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'User ID cannot be empty'),
      );
    }

    return await _repository.getUserWishlist(userId.trim());
  }
}

/// Use case for adding item to wishlist
class AddItemToWishlistUseCase {
  final WishlistRepository _repository;

  const AddItemToWishlistUseCase(this._repository);

  Future<Result<WishlistEntity>> call({
    required String userId,
    required ProductEntity product,
    String? notes,
  }) async {
    // Validate inputs
    if (userId.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'User ID cannot be empty'),
      );
    }

    // Create wishlist item
    final wishlistItem = WishlistItemEntity.fromProduct(
      id: '${userId}_${product.id}_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId.trim(),
      product: product,
      notes: notes,
    );

    return await _repository.addItemToWishlist(
      userId: userId.trim(),
      item: wishlistItem,
    );
  }
}

/// Use case for removing item from wishlist
class RemoveItemFromWishlistUseCase {
  final WishlistRepository _repository;

  const RemoveItemFromWishlistUseCase(this._repository);

  Future<Result<WishlistEntity>> call({
    required String userId,
    required String productId,
  }) async {
    // Validate inputs
    if (userId.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'User ID cannot be empty'),
      );
    }

    if (productId.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Product ID cannot be empty'),
      );
    }

    return await _repository.removeItemFromWishlist(
      userId: userId.trim(),
      productId: productId.trim(),
    );
  }
}

/// Use case for toggling product in wishlist
class ToggleProductInWishlistUseCase {
  final WishlistRepository _repository;

  const ToggleProductInWishlistUseCase(this._repository);

  Future<Result<WishlistEntity>> call({
    required String userId,
    required String productId,
  }) async {
    // Validate inputs
    if (userId.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'User ID cannot be empty'),
      );
    }

    if (productId.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Product ID cannot be empty'),
      );
    }

    return await _repository.toggleProductInWishlist(
      userId: userId.trim(),
      productId: productId.trim(),
    );
  }
}

/// Use case for checking if product is in wishlist
class IsProductInWishlistUseCase {
  final WishlistRepository _repository;

  const IsProductInWishlistUseCase(this._repository);

  Future<Result<bool>> call({
    required String userId,
    required String productId,
  }) async {
    // Validate inputs
    if (userId.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'User ID cannot be empty'),
      );
    }

    if (productId.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Product ID cannot be empty'),
      );
    }

    return await _repository.isProductInWishlist(
      userId: userId.trim(),
      productId: productId.trim(),
    );
  }
}

/// Use case for clearing wishlist
class ClearWishlistUseCase {
  final WishlistRepository _repository;

  const ClearWishlistUseCase(this._repository);

  Future<Result<WishlistEntity>> call(String userId) async {
    if (userId.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'User ID cannot be empty'),
      );
    }

    return await _repository.clearWishlist(userId.trim());
  }
}

/// Use case for getting wishlist item count
class GetWishlistItemCountUseCase {
  final WishlistRepository _repository;

  const GetWishlistItemCountUseCase(this._repository);

  Future<Result<int>> call(String userId) async {
    if (userId.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'User ID cannot be empty'),
      );
    }

    return await _repository.getWishlistItemCount(userId.trim());
  }
}

/// Use case for updating wishlist details
class UpdateWishlistDetailsUseCase {
  final WishlistRepository _repository;

  const UpdateWishlistDetailsUseCase(this._repository);

  Future<Result<WishlistEntity>> call({
    required String userId,
    String? name,
    String? description,
    bool? isPublic,
  }) async {
    if (userId.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'User ID cannot be empty'),
      );
    }

    return await _repository.updateWishlistDetails(
      userId: userId.trim(),
      name: name?.trim(),
      description: description?.trim(),
      isPublic: isPublic,
    );
  }
}

/// Use case for sharing wishlist
class ShareWishlistUseCase {
  final WishlistRepository _repository;

  const ShareWishlistUseCase(this._repository);

  Future<Result<String>> call(String wishlistId) async {
    if (wishlistId.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Wishlist ID cannot be empty'),
      );
    }

    return await _repository.shareWishlist(wishlistId.trim());
  }
}

/// Use case for getting shared wishlist
class GetSharedWishlistUseCase {
  final WishlistRepository _repository;

  const GetSharedWishlistUseCase(this._repository);

  Future<Result<WishlistEntity?>> call(String shareId) async {
    if (shareId.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Share ID cannot be empty'),
      );
    }

    return await _repository.getSharedWishlist(shareId.trim());
  }
}

/// Use case for moving items from wishlist to cart
class MoveItemsToCartUseCase {
  final WishlistRepository _repository;

  const MoveItemsToCartUseCase(this._repository);

  Future<Result<void>> call({
    required String userId,
    required List<String> productIds,
  }) async {
    // Validate inputs
    if (userId.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'User ID cannot be empty'),
      );
    }

    if (productIds.isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Product IDs cannot be empty'),
      );
    }

    // Validate product IDs
    final validProductIds = productIds
        .where((id) => id.trim().isNotEmpty)
        .map((id) => id.trim())
        .toList();

    if (validProductIds.isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'No valid product IDs provided'),
      );
    }

    return await _repository.moveItemsToCart(
      userId: userId.trim(),
      productIds: validProductIds,
    );
  }
}

/// Use case for getting wishlist statistics
class GetWishlistStatisticsUseCase {
  final WishlistRepository _repository;

  const GetWishlistStatisticsUseCase(this._repository);

  Future<Result<WishlistStatistics>> call(String userId) async {
    if (userId.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'User ID cannot be empty'),
      );
    }

    return await _repository.getWishlistStatistics(userId.trim());
  }
}

/// Validation failure for use case parameters
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}
