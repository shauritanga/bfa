import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/delivery_info_entity.dart';
import '../../domain/entities/payment_info_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/usecases/order_usecases.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../../cart/domain/entities/cart_entity.dart';
import '../../../products/presentation/providers/product_provider.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/repositories/base_repository.dart';

/// Order state
class OrderState {
  final List<OrderEntity> orders;
  final OrderEntity? currentOrder;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;

  const OrderState({
    this.orders = const [],
    this.currentOrder,
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
  });

  OrderState copyWith({
    List<OrderEntity>? orders,
    OrderEntity? currentOrder,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      currentOrder: currentOrder ?? this.currentOrder,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

/// Order notifier
class OrderNotifier extends StateNotifier<OrderState> {
  final OrderRepository _repository;
  final CreateOrderFromCartUseCase _createOrderUseCase;
  final GetUserOrdersUseCase _getUserOrdersUseCase;
  final UpdateOrderStatusUseCase _updateOrderStatusUseCase;
  final CancelOrderUseCase _cancelOrderUseCase;

  OrderNotifier(
    this._repository,
    this._createOrderUseCase,
    this._getUserOrdersUseCase,
    this._updateOrderStatusUseCase,
    this._cancelOrderUseCase,
  ) : super(const OrderState());

  /// Create a new order
  Future<OrderEntity?> createOrder({
    required String userId,
    required CartEntity cart,
    required DeliveryInfoEntity deliveryInfo,
    required PaymentInfoEntity paymentInfo,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _createOrderUseCase(
      userId: userId,
      cart: cart,
      deliveryInfo: deliveryInfo,
      paymentInfo: paymentInfo,
      notes: notes,
    );

    if (result.isSuccess) {
      state = state.copyWith(currentOrder: result.data!, isLoading: false);
      return result.data!;
    } else {
      state = state.copyWith(
        error: result.failure?.message ?? 'Failed to create order',
        isLoading: false,
      );
      return null;
    }
  }

  /// Get user orders
  Future<void> getUserOrders({
    required String userId,
    OrderStatus? status,
    bool refresh = false,
  }) async {
    if (refresh) {
      state = state.copyWith(
        orders: [],
        currentPage: 1,
        hasMore: true,
        isLoading: true,
        error: null,
      );
    } else if (state.isLoading || !state.hasMore) {
      return;
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    final result = await _getUserOrdersUseCase(
      userId: userId,
      status: status,
      page: state.currentPage,
      limit: 20,
    );

    if (result.isSuccess) {
      final paginatedResult = result.data!;
      final newOrders = refresh
          ? paginatedResult.items
          : [...state.orders, ...paginatedResult.items];

      state = state.copyWith(
        orders: newOrders,
        isLoading: false,
        hasMore: paginatedResult.hasNextPage,
        currentPage: state.currentPage + 1,
      );
    } else {
      state = state.copyWith(
        error: result.failure?.message ?? 'Failed to load orders',
        isLoading: false,
      );
    }
  }

  /// Update order status
  Future<bool> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _updateOrderStatusUseCase(
      orderId: orderId,
      status: status,
      notes: notes,
    );

    if (result.isSuccess) {
      // Update the order in the list
      final updatedOrders = state.orders.map((order) {
        return order.id == orderId ? result.data! : order;
      }).toList();

      state = state.copyWith(
        orders: updatedOrders,
        currentOrder: state.currentOrder?.id == orderId
            ? result.data!
            : state.currentOrder,
        isLoading: false,
      );
      return true;
    } else {
      state = state.copyWith(
        error: result.failure?.message ?? 'Failed to update order status',
        isLoading: false,
      );
      return false;
    }
  }

  /// Cancel order
  Future<bool> cancelOrder({
    required String orderId,
    required String reason,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _cancelOrderUseCase(orderId: orderId, reason: reason);

    if (result.isSuccess) {
      // Update the order in the list
      final updatedOrders = state.orders.map((order) {
        return order.id == orderId ? result.data! : order;
      }).toList();

      state = state.copyWith(
        orders: updatedOrders,
        currentOrder: state.currentOrder?.id == orderId
            ? result.data!
            : state.currentOrder,
        isLoading: false,
      );
      return true;
    } else {
      state = state.copyWith(
        error: result.failure?.message ?? 'Failed to cancel order',
        isLoading: false,
      );
      return false;
    }
  }

  /// Get order by ID
  Future<OrderEntity?> getOrderById(String orderId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getById(orderId);

    if (result.isSuccess) {
      state = state.copyWith(currentOrder: result.data!, isLoading: false);
      return result.data!;
    } else {
      state = state.copyWith(
        error: result.failure?.message ?? 'Failed to load order',
        isLoading: false,
      );
      return null;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Set current order
  void setCurrentOrder(OrderEntity? order) {
    state = state.copyWith(currentOrder: order);
  }

  /// Clear current order
  void clearCurrentOrder() {
    state = state.copyWith(currentOrder: null);
  }
}

// Providers
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService.instance;
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final firestoreService = ref.read(firestoreServiceProvider);
  final productRepository = ref.read(productRepositoryProvider);
  return OrderRepositoryImpl(firestoreService, productRepository);
});

// Use case providers
final createOrderUseCaseProvider = Provider<CreateOrderFromCartUseCase>((ref) {
  final repository = ref.read(orderRepositoryProvider);
  return CreateOrderFromCartUseCase(repository);
});

final getUserOrdersUseCaseProvider = Provider<GetUserOrdersUseCase>((ref) {
  final repository = ref.read(orderRepositoryProvider);
  return GetUserOrdersUseCase(repository);
});

final updateOrderStatusUseCaseProvider = Provider<UpdateOrderStatusUseCase>((
  ref,
) {
  final repository = ref.read(orderRepositoryProvider);
  return UpdateOrderStatusUseCase(repository);
});

final cancelOrderUseCaseProvider = Provider<CancelOrderUseCase>((ref) {
  final repository = ref.read(orderRepositoryProvider);
  return CancelOrderUseCase(repository);
});

// Main order provider
final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  return OrderNotifier(
    ref.read(orderRepositoryProvider),
    ref.read(createOrderUseCaseProvider),
    ref.read(getUserOrdersUseCaseProvider),
    ref.read(updateOrderStatusUseCaseProvider),
    ref.read(cancelOrderUseCaseProvider),
  );
});

// Provider for orders by status
final ordersByStatusProvider =
    FutureProvider.family<List<OrderEntity>, OrderStatus>((ref, status) async {
      final repository = ref.read(orderRepositoryProvider);
      final result = await repository.getOrdersByStatus(status: status);
      return result.isSuccess ? result.data! : [];
    });

// Provider for user orders
final userOrdersProvider =
    FutureProvider.family<PaginatedResult<OrderEntity>, String>((
      ref,
      userId,
    ) async {
      final useCase = ref.read(getUserOrdersUseCaseProvider);
      final result = await useCase(userId: userId);
      return result.isSuccess ? result.data! : PaginatedResult.empty();
    });

// Provider for single order
final singleOrderProvider = FutureProvider.family<OrderEntity?, String>((
  ref,
  orderId,
) async {
  final repository = ref.read(orderRepositoryProvider);
  final result = await repository.getById(orderId);
  return result.isSuccess ? result.data! : null;
});
