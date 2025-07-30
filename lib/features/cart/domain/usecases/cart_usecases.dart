import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../entities/cart_entity.dart';
import '../entities/cart_item_entity.dart';
import '../repositories/cart_repository.dart';
import '../../../products/domain/entities/product_entity.dart';

/// Use case for getting user's cart
class GetUserCartUseCase {
  final CartRepository _repository;

  const GetUserCartUseCase(this._repository);

  Future<Result<CartEntity?>> call(String userId) async {
    if (userId.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'User ID cannot be empty'),
      );
    }

    return await _repository.getUserCart(userId.trim());
  }
}

/// Use case for adding item to cart
class AddItemToCartUseCase {
  final CartRepository _repository;

  const AddItemToCartUseCase(this._repository);

  Future<Result<CartEntity>> call({
    required String userId,
    required ProductEntity product,
    required double quantity,
    String? notes,
  }) async {
    // Validate inputs
    if (userId.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'User ID cannot be empty'),
      );
    }

    if (quantity <= 0) {
      return const Result.failure(
        ValidationFailure(message: 'Quantity must be greater than 0'),
      );
    }

    if (!product.isAvailable) {
      return const Result.failure(
        ValidationFailure(message: 'Product is not available'),
      );
    }

    if (quantity > product.quantity) {
      return const Result.failure(
        ValidationFailure(message: 'Requested quantity exceeds available stock'),
      );
    }

    // Create cart item
    final cartItem = CartItemEntity.fromProduct(
      id: '${userId}_${product.id}_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId.trim(),
      product: product,
      quantity: quantity,
      notes: notes,
    );

    return await _repository.addItemToCart(
      userId: userId.trim(),
      item: cartItem,
    );
  }
}

/// Use case for updating item quantity in cart
class UpdateCartItemQuantityUseCase {
  final CartRepository _repository;

  const UpdateCartItemQuantityUseCase(this._repository);

  Future<Result<CartEntity>> call({
    required String userId,
    required String productId,
    required double quantity,
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

    if (quantity < 0) {
      return const Result.failure(
        ValidationFailure(message: 'Quantity cannot be negative'),
      );
    }

    // If quantity is 0, remove the item
    if (quantity == 0) {
      return await _repository.removeItemFromCart(
        userId: userId.trim(),
        productId: productId.trim(),
      );
    }

    return await _repository.updateItemQuantity(
      userId: userId.trim(),
      productId: productId.trim(),
      quantity: quantity,
    );
  }
}

/// Use case for removing item from cart
class RemoveItemFromCartUseCase {
  final CartRepository _repository;

  const RemoveItemFromCartUseCase(this._repository);

  Future<Result<CartEntity>> call({
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

    return await _repository.removeItemFromCart(
      userId: userId.trim(),
      productId: productId.trim(),
    );
  }
}

/// Use case for clearing cart
class ClearCartUseCase {
  final CartRepository _repository;

  const ClearCartUseCase(this._repository);

  Future<Result<CartEntity>> call(String userId) async {
    if (userId.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'User ID cannot be empty'),
      );
    }

    return await _repository.clearCart(userId.trim());
  }
}

/// Use case for applying coupon to cart
class ApplyCouponUseCase {
  final CartRepository _repository;

  const ApplyCouponUseCase(this._repository);

  Future<Result<CartEntity>> call({
    required String userId,
    required String couponCode,
    required double discountAmount,
  }) async {
    // Validate inputs
    if (userId.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'User ID cannot be empty'),
      );
    }

    if (couponCode.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Coupon code cannot be empty'),
      );
    }

    if (discountAmount < 0) {
      return const Result.failure(
        ValidationFailure(message: 'Discount amount cannot be negative'),
      );
    }

    return await _repository.applyCoupon(
      userId: userId.trim(),
      couponCode: couponCode.trim().toUpperCase(),
      discountAmount: discountAmount,
    );
  }
}

/// Use case for removing coupon from cart
class RemoveCouponUseCase {
  final CartRepository _repository;

  const RemoveCouponUseCase(this._repository);

  Future<Result<CartEntity>> call(String userId) async {
    if (userId.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'User ID cannot be empty'),
      );
    }

    return await _repository.removeCoupon(userId.trim());
  }
}

/// Use case for validating cart
class ValidateCartUseCase {
  final CartRepository _repository;

  const ValidateCartUseCase(this._repository);

  Future<Result<CartValidationResult>> call(String userId) async {
    if (userId.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'User ID cannot be empty'),
      );
    }

    return await _repository.validateCart(userId.trim());
  }
}

/// Use case for getting cart item count
class GetCartItemCountUseCase {
  final CartRepository _repository;

  const GetCartItemCountUseCase(this._repository);

  Future<Result<int>> call(String userId) async {
    if (userId.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'User ID cannot be empty'),
      );
    }

    return await _repository.getCartItemCount(userId.trim());
  }
}

/// Use case for getting cart total
class GetCartTotalUseCase {
  final CartRepository _repository;

  const GetCartTotalUseCase(this._repository);

  Future<Result<double>> call(String userId) async {
    if (userId.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'User ID cannot be empty'),
      );
    }

    return await _repository.getCartTotal(userId.trim());
  }
}

/// Validation failure for use case parameters
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}
