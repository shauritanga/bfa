import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/config/firebase_config.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../../products/domain/repositories/product_repository.dart';

/// Implementation of CartRepository using Firestore
class CartRepositoryImpl implements CartRepository {
  final FirestoreService _firestoreService;
  final ProductRepository _productRepository;

  CartRepositoryImpl(this._firestoreService, this._productRepository);

  @override
  Future<Result<CartEntity?>> getUserCart(String userId) async {
    try {
      final result = await _firestoreService.getDocument(
        collection: FirebaseCollections.carts,
        documentId: userId,
      );

      if (result.isSuccess && result.data != null) {
        return Result.success(CartEntity.fromMap(result.data!));
      } else if (result.isSuccess && result.data == null) {
        return const Result.success(null);
      } else {
        return Result.failure(result.failure!);
      }
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Failed to get user cart: $e'),
      );
    }
  }

  @override
  Future<Result<CartEntity>> createCart(CartEntity cart) async {
    try {
      final result = await _firestoreService.createDocument(
        collection: FirebaseCollections.carts,
        data: cart.toMap(),
        documentId: cart.userId,
      );

      if (result.isSuccess) {
        return Result.success(cart);
      } else {
        return Result.failure(result.failure!);
      }
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Failed to create cart: $e'),
      );
    }
  }

  @override
  Future<Result<CartEntity>> updateCart(CartEntity cart) async {
    try {
      final updatedCart = cart.copyWith(updatedAt: DateTime.now());

      final result = await _firestoreService.updateDocument(
        collection: FirebaseCollections.carts,
        documentId: cart.userId,
        data: updatedCart.toMap(),
      );

      if (result.isSuccess) {
        return Result.success(updatedCart);
      } else {
        return Result.failure(result.failure!);
      }
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Failed to update cart: $e'),
      );
    }
  }

  @override
  Future<Result<void>> deleteCart(String cartId) async {
    try {
      final result = await _firestoreService.deleteDocument(
        collection: FirebaseCollections.carts,
        documentId: cartId,
      );

      return result;
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Failed to delete cart: $e'),
      );
    }
  }

  @override
  Future<Result<CartEntity>> addItemToCart({
    required String userId,
    required CartItemEntity item,
  }) async {
    try {
      // Get existing cart or create new one
      final cartResult = await getUserCart(userId);
      if (cartResult.isFailure) {
        return Result.failure(cartResult.failure!);
      }

      CartEntity cart =
          cartResult.data ?? CartEntity.empty(id: userId, userId: userId);

      // Add item to cart
      cart = cart.addItem(item);

      // Save updated cart
      if (cartResult.data == null) {
        return await createCart(cart);
      } else {
        return await updateCart(cart);
      }
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Failed to add item to cart: $e'),
      );
    }
  }

  @override
  Future<Result<CartEntity>> updateItemQuantity({
    required String userId,
    required String productId,
    required double quantity,
  }) async {
    try {
      final cartResult = await getUserCart(userId);
      if (cartResult.isFailure) {
        return Result.failure(cartResult.failure!);
      }

      final cart = cartResult.data;
      if (cart == null) {
        return const Result.failure(NotFoundFailure(message: 'Cart not found'));
      }

      // Update item quantity or remove if quantity is 0
      final updatedCart = quantity > 0
          ? cart.updateItemQuantity(productId, quantity)
          : cart.removeItem(productId);

      return await updateCart(updatedCart);
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Failed to update item quantity: $e'),
      );
    }
  }

  @override
  Future<Result<CartEntity>> removeItemFromCart({
    required String userId,
    required String productId,
  }) async {
    try {
      final cartResult = await getUserCart(userId);
      if (cartResult.isFailure) {
        return Result.failure(cartResult.failure!);
      }

      final cart = cartResult.data;
      if (cart == null) {
        return const Result.failure(NotFoundFailure(message: 'Cart not found'));
      }

      final updatedCart = cart.removeItem(productId);
      return await updateCart(updatedCart);
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Failed to remove item from cart: $e'),
      );
    }
  }

  @override
  Future<Result<CartEntity>> clearCart(String userId) async {
    try {
      final cartResult = await getUserCart(userId);
      if (cartResult.isFailure) {
        return Result.failure(cartResult.failure!);
      }

      final cart = cartResult.data;
      if (cart == null) {
        return const Result.failure(NotFoundFailure(message: 'Cart not found'));
      }

      final clearedCart = cart.clearItems();
      return await updateCart(clearedCart);
    } catch (e) {
      return Result.failure(ServerFailure(message: 'Failed to clear cart: $e'));
    }
  }

  @override
  Future<Result<CartEntity>> applyCoupon({
    required String userId,
    required String couponCode,
    required double discountAmount,
  }) async {
    try {
      final cartResult = await getUserCart(userId);
      if (cartResult.isFailure) {
        return Result.failure(cartResult.failure!);
      }

      final cart = cartResult.data;
      if (cart == null) {
        return const Result.failure(NotFoundFailure(message: 'Cart not found'));
      }

      final updatedCart = cart.applyCoupon(couponCode, discountAmount);
      return await updateCart(updatedCart);
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Failed to apply coupon: $e'),
      );
    }
  }

  @override
  Future<Result<CartEntity>> removeCoupon(String userId) async {
    try {
      final cartResult = await getUserCart(userId);
      if (cartResult.isFailure) {
        return Result.failure(cartResult.failure!);
      }

      final cart = cartResult.data;
      if (cart == null) {
        return const Result.failure(NotFoundFailure(message: 'Cart not found'));
      }

      final updatedCart = cart.removeCoupon();
      return await updateCart(updatedCart);
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Failed to remove coupon: $e'),
      );
    }
  }

  @override
  Future<Result<CartEntity>> setDeliveryFee({
    required String userId,
    required double deliveryFee,
  }) async {
    try {
      final cartResult = await getUserCart(userId);
      if (cartResult.isFailure) {
        return Result.failure(cartResult.failure!);
      }

      final cart = cartResult.data;
      if (cart == null) {
        return const Result.failure(NotFoundFailure(message: 'Cart not found'));
      }

      final updatedCart = cart.setDeliveryFee(deliveryFee);
      return await updateCart(updatedCart);
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Failed to set delivery fee: $e'),
      );
    }
  }

  @override
  Future<Result<CartEntity>> setDeliveryAddress({
    required String userId,
    required String address,
  }) async {
    try {
      final cartResult = await getUserCart(userId);
      if (cartResult.isFailure) {
        return Result.failure(cartResult.failure!);
      }

      final cart = cartResult.data;
      if (cart == null) {
        return const Result.failure(NotFoundFailure(message: 'Cart not found'));
      }

      final updatedCart = cart.setDeliveryAddress(address);
      return await updateCart(updatedCart);
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Failed to set delivery address: $e'),
      );
    }
  }

  @override
  Future<Result<int>> getCartItemCount(String userId) async {
    try {
      final cartResult = await getUserCart(userId);
      if (cartResult.isFailure) {
        return Result.failure(cartResult.failure!);
      }

      final cart = cartResult.data;
      return Result.success(cart?.itemCount ?? 0);
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Failed to get cart item count: $e'),
      );
    }
  }

  @override
  Future<Result<double>> getCartTotal(String userId) async {
    try {
      final cartResult = await getUserCart(userId);
      if (cartResult.isFailure) {
        return Result.failure(cartResult.failure!);
      }

      final cart = cartResult.data;
      return Result.success(cart?.total ?? 0.0);
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Failed to get cart total: $e'),
      );
    }
  }

  @override
  Future<Result<CartValidationResult>> validateCart(String userId) async {
    try {
      final cartResult = await getUserCart(userId);
      if (cartResult.isFailure) {
        return Result.failure(cartResult.failure!);
      }

      final cart = cartResult.data;
      if (cart == null || cart.isEmpty) {
        return const Result.success(
          CartValidationResult(
            isValid: true,
            unavailableItems: [],
            itemsExceedingStock: [],
            priceChangedItems: [],
          ),
        );
      }

      final unavailableItems = <CartItemEntity>[];
      final itemsExceedingStock = <CartItemEntity>[];
      final priceChangedItems = <CartItemEntity>[];

      // Validate each item
      for (final item in cart.items) {
        // Get current product data
        final productResult = await _productRepository.getById(item.productId);
        if (productResult.isFailure) {
          unavailableItems.add(item);
          continue;
        }

        final currentProduct = productResult.data!;

        // Check availability
        if (!currentProduct.isAvailable) {
          unavailableItems.add(item);
          continue;
        }

        // Check stock
        if (item.quantity > currentProduct.quantity) {
          itemsExceedingStock.add(item);
        }

        // Check price changes
        if (item.unitPrice != currentProduct.price ||
            item.discountPrice != currentProduct.discountPrice) {
          priceChangedItems.add(item);
        }
      }

      final isValid =
          unavailableItems.isEmpty &&
          itemsExceedingStock.isEmpty &&
          priceChangedItems.isEmpty;

      return Result.success(
        CartValidationResult(
          isValid: isValid,
          unavailableItems: unavailableItems,
          itemsExceedingStock: itemsExceedingStock,
          priceChangedItems: priceChangedItems,
          message: isValid ? null : 'Cart validation failed',
        ),
      );
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Failed to validate cart: $e'),
      );
    }
  }

  @override
  Future<Result<CartEntity>> mergeGuestCart({
    required String userId,
    required CartEntity guestCart,
  }) async {
    try {
      // Get user's existing cart
      final userCartResult = await getUserCart(userId);
      if (userCartResult.isFailure) {
        return Result.failure(userCartResult.failure!);
      }

      CartEntity userCart =
          userCartResult.data ?? CartEntity.empty(id: userId, userId: userId);

      // Merge guest cart items
      for (final guestItem in guestCart.items) {
        final updatedGuestItem = guestItem.copyWith(userId: userId);
        userCart = userCart.addItem(updatedGuestItem);
      }

      // Save merged cart
      if (userCartResult.data == null) {
        return await createCart(userCart);
      } else {
        return await updateCart(userCart);
      }
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Failed to merge guest cart: $e'),
      );
    }
  }

  @override
  Future<Result<List<CartEntity>>> getAbandonedCarts({
    required Duration abandonedAfter,
    int limit = 50,
  }) async {
    try {
      final cutoffTime = DateTime.now().subtract(abandonedAfter);

      final query = FirebaseFirestore.instance
          .collection(FirebaseCollections.carts)
          .where('updatedAt', isLessThan: cutoffTime.toIso8601String())
          .limit(limit);

      final snapshot = await query.get();
      final carts = snapshot.docs
          .map((doc) => CartEntity.fromMap({'id': doc.id, ...doc.data()}))
          .where((cart) => cart.isNotEmpty)
          .toList();

      return Result.success(carts);
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Failed to get abandoned carts: $e'),
      );
    }
  }

  @override
  Future<Result<void>> saveCartForLater(String userId) async {
    try {
      // This would typically move cart items to a "saved for later" collection
      // For now, we'll just clear the cart
      final result = await clearCart(userId);
      return result.isSuccess
          ? const Result.success(null)
          : Result.failure(result.failure!);
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Failed to save cart for later: $e'),
      );
    }
  }
}
