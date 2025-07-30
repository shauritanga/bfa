import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/firestore_service.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/usecases/cart_usecases.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../../products/presentation/providers/product_provider.dart';
import '../../../products/domain/entities/product_entity.dart';

/// Cart state for managing cart data and UI state
class CartState {
  final CartEntity? cart;
  final bool isLoading;
  final bool isUpdating;
  final String? error;
  final CartValidationResult? validationResult;

  const CartState({
    this.cart,
    this.isLoading = false,
    this.isUpdating = false,
    this.error,
    this.validationResult,
  });

  /// Get cart item count
  int get itemCount => cart?.itemCount ?? 0;

  /// Get cart total
  double get total => cart?.total ?? 0.0;

  /// Get cart subtotal
  double get subtotal => cart?.subtotal ?? 0.0;

  /// Get total savings
  double get totalSavings => cart?.totalSavings ?? 0.0;

  /// Check if cart is empty
  bool get isEmpty => cart?.isEmpty ?? true;

  /// Check if cart is valid for checkout
  bool get isValidForCheckout => cart?.isValidForCheckout ?? false;

  /// Get cart items
  List<CartItemEntity> get items => cart?.items ?? [];

  CartState copyWith({
    CartEntity? cart,
    bool? isLoading,
    bool? isUpdating,
    String? error,
    CartValidationResult? validationResult,
  }) {
    return CartState(
      cart: cart ?? this.cart,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      error: error,
      validationResult: validationResult ?? this.validationResult,
    );
  }
}

/// Cart notifier for managing cart state
class CartNotifier extends StateNotifier<CartState> {
  final CartRepository _repository;
  final GetUserCartUseCase _getUserCartUseCase;
  final AddItemToCartUseCase _addItemToCartUseCase;
  final UpdateCartItemQuantityUseCase _updateCartItemQuantityUseCase;
  final RemoveItemFromCartUseCase _removeItemFromCartUseCase;
  final ClearCartUseCase _clearCartUseCase;
  final ApplyCouponUseCase _applyCouponUseCase;
  final RemoveCouponUseCase _removeCouponUseCase;
  final ValidateCartUseCase _validateCartUseCase;

  String? _currentUserId;

  CartNotifier(
    this._repository,
    this._getUserCartUseCase,
    this._addItemToCartUseCase,
    this._updateCartItemQuantityUseCase,
    this._removeItemFromCartUseCase,
    this._clearCartUseCase,
    this._applyCouponUseCase,
    this._removeCouponUseCase,
    this._validateCartUseCase,
  ) : super(const CartState());

  /// Set current user and load their cart
  Future<void> setUser(String userId) async {
    if (_currentUserId == userId) return;
    
    _currentUserId = userId;
    await loadCart();
  }

  /// Load user's cart
  Future<void> loadCart() async {
    if (_currentUserId == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _getUserCartUseCase(_currentUserId!);

      if (result.isSuccess) {
        state = state.copyWith(
          cart: result.data,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.failure?.message ?? 'Failed to load cart',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load cart: $e',
      );
    }
  }

  /// Add item to cart
  Future<void> addItem({
    required ProductEntity product,
    required double quantity,
    String? notes,
  }) async {
    if (_currentUserId == null) return;

    state = state.copyWith(isUpdating: true, error: null);

    try {
      final result = await _addItemToCartUseCase(
        userId: _currentUserId!,
        product: product,
        quantity: quantity,
        notes: notes,
      );

      if (result.isSuccess) {
        state = state.copyWith(
          cart: result.data,
          isUpdating: false,
        );
      } else {
        state = state.copyWith(
          isUpdating: false,
          error: result.failure?.message ?? 'Failed to add item to cart',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Failed to add item to cart: $e',
      );
    }
  }

  /// Update item quantity
  Future<void> updateItemQuantity({
    required String productId,
    required double quantity,
  }) async {
    if (_currentUserId == null) return;

    state = state.copyWith(isUpdating: true, error: null);

    try {
      final result = await _updateCartItemQuantityUseCase(
        userId: _currentUserId!,
        productId: productId,
        quantity: quantity,
      );

      if (result.isSuccess) {
        state = state.copyWith(
          cart: result.data,
          isUpdating: false,
        );
      } else {
        state = state.copyWith(
          isUpdating: false,
          error: result.failure?.message ?? 'Failed to update item quantity',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Failed to update item quantity: $e',
      );
    }
  }

  /// Remove item from cart
  Future<void> removeItem(String productId) async {
    if (_currentUserId == null) return;

    state = state.copyWith(isUpdating: true, error: null);

    try {
      final result = await _removeItemFromCartUseCase(
        userId: _currentUserId!,
        productId: productId,
      );

      if (result.isSuccess) {
        state = state.copyWith(
          cart: result.data,
          isUpdating: false,
        );
      } else {
        state = state.copyWith(
          isUpdating: false,
          error: result.failure?.message ?? 'Failed to remove item from cart',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Failed to remove item from cart: $e',
      );
    }
  }

  /// Clear cart
  Future<void> clearCart() async {
    if (_currentUserId == null) return;

    state = state.copyWith(isUpdating: true, error: null);

    try {
      final result = await _clearCartUseCase(_currentUserId!);

      if (result.isSuccess) {
        state = state.copyWith(
          cart: result.data,
          isUpdating: false,
        );
      } else {
        state = state.copyWith(
          isUpdating: false,
          error: result.failure?.message ?? 'Failed to clear cart',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Failed to clear cart: $e',
      );
    }
  }

  /// Apply coupon
  Future<void> applyCoupon({
    required String couponCode,
    required double discountAmount,
  }) async {
    if (_currentUserId == null) return;

    state = state.copyWith(isUpdating: true, error: null);

    try {
      final result = await _applyCouponUseCase(
        userId: _currentUserId!,
        couponCode: couponCode,
        discountAmount: discountAmount,
      );

      if (result.isSuccess) {
        state = state.copyWith(
          cart: result.data,
          isUpdating: false,
        );
      } else {
        state = state.copyWith(
          isUpdating: false,
          error: result.failure?.message ?? 'Failed to apply coupon',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Failed to apply coupon: $e',
      );
    }
  }

  /// Remove coupon
  Future<void> removeCoupon() async {
    if (_currentUserId == null) return;

    state = state.copyWith(isUpdating: true, error: null);

    try {
      final result = await _removeCouponUseCase(_currentUserId!);

      if (result.isSuccess) {
        state = state.copyWith(
          cart: result.data,
          isUpdating: false,
        );
      } else {
        state = state.copyWith(
          isUpdating: false,
          error: result.failure?.message ?? 'Failed to remove coupon',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Failed to remove coupon: $e',
      );
    }
  }

  /// Validate cart
  Future<void> validateCart() async {
    if (_currentUserId == null) return;

    try {
      final result = await _validateCartUseCase(_currentUserId!);

      if (result.isSuccess) {
        state = state.copyWith(validationResult: result.data);
      }
    } catch (e) {
      // Silently fail validation
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Check if product is in cart
  bool isProductInCart(String productId) {
    return state.cart?.containsProduct(productId) ?? false;
  }

  /// Get product quantity in cart
  double getProductQuantity(String productId) {
    return state.cart?.getProductQuantity(productId) ?? 0.0;
  }
}

/// Cart repository provider
final cartRepositoryProvider = Provider<CartRepository>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final productRepository = ref.watch(productRepositoryProvider);
  return CartRepositoryImpl(firestoreService, productRepository);
});

/// Use case providers
final getUserCartUseCaseProvider = Provider<GetUserCartUseCase>((ref) {
  final repository = ref.watch(cartRepositoryProvider);
  return GetUserCartUseCase(repository);
});

final addItemToCartUseCaseProvider = Provider<AddItemToCartUseCase>((ref) {
  final repository = ref.watch(cartRepositoryProvider);
  return AddItemToCartUseCase(repository);
});

final updateCartItemQuantityUseCaseProvider = Provider<UpdateCartItemQuantityUseCase>((ref) {
  final repository = ref.watch(cartRepositoryProvider);
  return UpdateCartItemQuantityUseCase(repository);
});

final removeItemFromCartUseCaseProvider = Provider<RemoveItemFromCartUseCase>((ref) {
  final repository = ref.watch(cartRepositoryProvider);
  return RemoveItemFromCartUseCase(repository);
});

final clearCartUseCaseProvider = Provider<ClearCartUseCase>((ref) {
  final repository = ref.watch(cartRepositoryProvider);
  return ClearCartUseCase(repository);
});

final applyCouponUseCaseProvider = Provider<ApplyCouponUseCase>((ref) {
  final repository = ref.watch(cartRepositoryProvider);
  return ApplyCouponUseCase(repository);
});

final removeCouponUseCaseProvider = Provider<RemoveCouponUseCase>((ref) {
  final repository = ref.watch(cartRepositoryProvider);
  return RemoveCouponUseCase(repository);
});

final validateCartUseCaseProvider = Provider<ValidateCartUseCase>((ref) {
  final repository = ref.watch(cartRepositoryProvider);
  return ValidateCartUseCase(repository);
});

/// Cart state provider
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  final repository = ref.watch(cartRepositoryProvider);
  final getUserCartUseCase = ref.watch(getUserCartUseCaseProvider);
  final addItemToCartUseCase = ref.watch(addItemToCartUseCaseProvider);
  final updateCartItemQuantityUseCase = ref.watch(updateCartItemQuantityUseCaseProvider);
  final removeItemFromCartUseCase = ref.watch(removeItemFromCartUseCaseProvider);
  final clearCartUseCase = ref.watch(clearCartUseCaseProvider);
  final applyCouponUseCase = ref.watch(applyCouponUseCaseProvider);
  final removeCouponUseCase = ref.watch(removeCouponUseCaseProvider);
  final validateCartUseCase = ref.watch(validateCartUseCaseProvider);

  return CartNotifier(
    repository,
    getUserCartUseCase,
    addItemToCartUseCase,
    updateCartItemQuantityUseCase,
    removeItemFromCartUseCase,
    clearCartUseCase,
    applyCouponUseCase,
    removeCouponUseCase,
    validateCartUseCase,
  );
});

/// Convenience providers
final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).itemCount;
});

final cartTotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).total;
});

final cartIsEmptyProvider = Provider<bool>((ref) {
  return ref.watch(cartProvider).isEmpty;
});

final cartItemsProvider = Provider<List<CartItemEntity>>((ref) {
  return ref.watch(cartProvider).items;
});
