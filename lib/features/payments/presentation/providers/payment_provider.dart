import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/payment_request_entity.dart';
import '../../domain/entities/payment_response_entity.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/usecases/payment_usecases.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../../data/services/clickpesa_service.dart';
import '../../../../core/services/firestore_service.dart';

/// Payment state
class PaymentState {
  final bool isLoading;
  final PaymentResponseEntity? currentPayment;
  final List<PaymentResponseEntity> paymentHistory;
  final List<PaymentMethodInfo> supportedMethods;
  final PaymentProviderValidation? phoneValidation;
  final PaymentFees? fees;
  final String? error;

  const PaymentState({
    this.isLoading = false,
    this.currentPayment,
    this.paymentHistory = const [],
    this.supportedMethods = const [],
    this.phoneValidation,
    this.fees,
    this.error,
  });

  PaymentState copyWith({
    bool? isLoading,
    PaymentResponseEntity? currentPayment,
    List<PaymentResponseEntity>? paymentHistory,
    List<PaymentMethodInfo>? supportedMethods,
    PaymentProviderValidation? phoneValidation,
    PaymentFees? fees,
    String? error,
  }) {
    return PaymentState(
      isLoading: isLoading ?? this.isLoading,
      currentPayment: currentPayment ?? this.currentPayment,
      paymentHistory: paymentHistory ?? this.paymentHistory,
      supportedMethods: supportedMethods ?? this.supportedMethods,
      phoneValidation: phoneValidation ?? this.phoneValidation,
      fees: fees ?? this.fees,
      error: error,
    );
  }
}

/// Payment provider
class PaymentNotifier extends StateNotifier<PaymentState> {
  final InitiatePaymentUseCase _initiatePaymentUseCase;
  final CheckPaymentStatusUseCase _checkPaymentStatusUseCase;
  final GetPaymentByOrderIdUseCase _getPaymentByOrderIdUseCase;
  final GetUserPaymentHistoryUseCase _getUserPaymentHistoryUseCase;
  final CancelPaymentUseCase _cancelPaymentUseCase;
  final ProcessRefundUseCase _processRefundUseCase;
  final VerifyPaymentCallbackUseCase _verifyPaymentCallbackUseCase;
  final GetSupportedPaymentMethodsUseCase _getSupportedPaymentMethodsUseCase;
  final ValidatePhoneNumberUseCase _validatePhoneNumberUseCase;
  final GetPaymentFeesUseCase _getPaymentFeesUseCase;

  PaymentNotifier(
    this._initiatePaymentUseCase,
    this._checkPaymentStatusUseCase,
    this._getPaymentByOrderIdUseCase,
    this._getUserPaymentHistoryUseCase,
    this._cancelPaymentUseCase,
    this._processRefundUseCase,
    this._verifyPaymentCallbackUseCase,
    this._getSupportedPaymentMethodsUseCase,
    this._validatePhoneNumberUseCase,
    this._getPaymentFeesUseCase,
  ) : super(const PaymentState());

  /// Initialize payment methods
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getSupportedPaymentMethodsUseCase();
    if (result.isSuccess) {
      state = state.copyWith(supportedMethods: result.data!, isLoading: false);
    } else {
      state = state.copyWith(
        error: result.failure?.message ?? 'Failed to load payment methods',
        isLoading: false,
      );
    }
  }

  /// Initiate payment
  Future<PaymentResponseEntity?> initiatePayment({
    required OrderEntity order,
    required PaymentMethod method,
    required PaymentProvider provider,
    required String phoneNumber,
    String? email,
    String? customerName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _initiatePaymentUseCase(
      order: order,
      method: method,
      provider: provider,
      phoneNumber: phoneNumber,
      email: email,
      customerName: customerName,
    );

    if (result.isSuccess) {
      state = state.copyWith(currentPayment: result.data!, isLoading: false);
      return result.data!;
    } else {
      state = state.copyWith(
        error: result.failure?.message ?? 'Failed to initiate payment',
        isLoading: false,
      );
      return null;
    }
  }

  /// Check payment status
  Future<PaymentResponseEntity?> checkPaymentStatus(String paymentId) async {
    final result = await _checkPaymentStatusUseCase(paymentId);

    if (result.isSuccess) {
      state = state.copyWith(currentPayment: result.data!);
      return result.data!;
    } else {
      state = state.copyWith(
        error: result.failure?.message ?? 'Failed to check payment status',
      );
      return null;
    }
  }

  /// Get payment by order ID
  Future<PaymentResponseEntity?> getPaymentByOrderId(String orderId) async {
    final result = await _getPaymentByOrderIdUseCase(orderId);

    if (result.isSuccess) {
      if (result.data != null) {
        state = state.copyWith(currentPayment: result.data!);
      }
      return result.data;
    } else {
      state = state.copyWith(
        error: result.failure?.message ?? 'Failed to get payment',
      );
      return null;
    }
  }

  /// Get user payment history
  Future<void> getUserPaymentHistory({
    required String userId,
    int limit = 20,
    String? startAfter,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getUserPaymentHistoryUseCase(
      userId: userId,
      limit: limit,
      startAfter: startAfter,
    );

    if (result.isSuccess) {
      state = state.copyWith(paymentHistory: result.data!, isLoading: false);
    } else {
      state = state.copyWith(
        error: result.failure?.message ?? 'Failed to get payment history',
        isLoading: false,
      );
    }
  }

  /// Cancel payment
  Future<bool> cancelPayment({
    required String paymentId,
    required String reason,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _cancelPaymentUseCase(
      paymentId: paymentId,
      reason: reason,
    );

    if (result.isSuccess) {
      state = state.copyWith(currentPayment: result.data!, isLoading: false);
      return true;
    } else {
      state = state.copyWith(
        error: result.failure?.message ?? 'Failed to cancel payment',
        isLoading: false,
      );
      return false;
    }
  }

  /// Process refund
  Future<bool> processRefund({
    required String originalPaymentId,
    required double amount,
    required String reason,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _processRefundUseCase(
      originalPaymentId: originalPaymentId,
      amount: amount,
      reason: reason,
    );

    if (result.isSuccess) {
      state = state.copyWith(isLoading: false);
      return true;
    } else {
      state = state.copyWith(
        error: result.failure?.message ?? 'Failed to process refund',
        isLoading: false,
      );
      return false;
    }
  }

  /// Validate phone number
  Future<void> validatePhoneNumber({
    required String phoneNumber,
    PaymentProvider? preferredProvider,
  }) async {
    final result = await _validatePhoneNumberUseCase(
      phoneNumber: phoneNumber,
      preferredProvider: preferredProvider,
    );

    if (result.isSuccess) {
      state = state.copyWith(phoneValidation: result.data!);
    } else {
      state = state.copyWith(
        phoneValidation: PaymentProviderValidation(
          isValid: false,
          supportedProviders: const [],
          errorMessage: result.failure?.message ?? 'Invalid phone number',
        ),
      );
    }
  }

  /// Get payment fees
  Future<void> getPaymentFees({
    required double amount,
    required PaymentMethod method,
    required PaymentProvider provider,
  }) async {
    final result = await _getPaymentFeesUseCase(
      amount: amount,
      method: method,
      provider: provider,
    );

    if (result.isSuccess) {
      state = state.copyWith(fees: result.data!);
    } else {
      state = state.copyWith(
        error: result.failure?.message ?? 'Failed to get payment fees',
      );
    }
  }

  /// Verify payment callback
  Future<PaymentResponseEntity?> verifyPaymentCallback({
    required Map<String, dynamic> callbackData,
    required String signature,
  }) async {
    final result = await _verifyPaymentCallbackUseCase(
      callbackData: callbackData,
      signature: signature,
    );

    if (result.isSuccess) {
      state = state.copyWith(currentPayment: result.data!);
      return result.data!;
    } else {
      state = state.copyWith(
        error: result.failure?.message ?? 'Failed to verify callback',
      );
      return null;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Clear current payment
  void clearCurrentPayment() {
    state = state.copyWith(currentPayment: null);
  }
}

// Providers
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService.instance;
});

final clickPesaServiceProvider = Provider<ClickPesaService>((ref) {
  // TODO: Get these from environment variables or secure storage
  final config = ClickPesaConfig.sandbox(
    apiKey: 'your_clickpesa_api_key',
    secretKey: 'your_clickpesa_secret_key',
  );

  return ClickPesaService(
    baseUrl: config.baseUrl,
    apiKey: config.apiKey,
    secretKey: config.secretKey,
  );
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final firestoreService = ref.read(firestoreServiceProvider);
  final clickPesaService = ref.read(clickPesaServiceProvider);
  return PaymentRepositoryImpl(firestoreService, clickPesaService);
});

// Use case providers
final initiatePaymentUseCaseProvider = Provider<InitiatePaymentUseCase>((ref) {
  final repository = ref.read(paymentRepositoryProvider);
  return InitiatePaymentUseCase(repository);
});

final checkPaymentStatusUseCaseProvider = Provider<CheckPaymentStatusUseCase>((
  ref,
) {
  final repository = ref.read(paymentRepositoryProvider);
  return CheckPaymentStatusUseCase(repository);
});

final getPaymentByOrderIdUseCaseProvider = Provider<GetPaymentByOrderIdUseCase>(
  (ref) {
    final repository = ref.read(paymentRepositoryProvider);
    return GetPaymentByOrderIdUseCase(repository);
  },
);

final getUserPaymentHistoryUseCaseProvider =
    Provider<GetUserPaymentHistoryUseCase>((ref) {
      final repository = ref.read(paymentRepositoryProvider);
      return GetUserPaymentHistoryUseCase(repository);
    });

final cancelPaymentUseCaseProvider = Provider<CancelPaymentUseCase>((ref) {
  final repository = ref.read(paymentRepositoryProvider);
  return CancelPaymentUseCase(repository);
});

final processRefundUseCaseProvider = Provider<ProcessRefundUseCase>((ref) {
  final repository = ref.read(paymentRepositoryProvider);
  return ProcessRefundUseCase(repository);
});

final verifyPaymentCallbackUseCaseProvider =
    Provider<VerifyPaymentCallbackUseCase>((ref) {
      final repository = ref.read(paymentRepositoryProvider);
      return VerifyPaymentCallbackUseCase(repository);
    });

final getSupportedPaymentMethodsUseCaseProvider =
    Provider<GetSupportedPaymentMethodsUseCase>((ref) {
      final repository = ref.read(paymentRepositoryProvider);
      return GetSupportedPaymentMethodsUseCase(repository);
    });

final validatePhoneNumberUseCaseProvider = Provider<ValidatePhoneNumberUseCase>(
  (ref) {
    final repository = ref.read(paymentRepositoryProvider);
    return ValidatePhoneNumberUseCase(repository);
  },
);

final getPaymentFeesUseCaseProvider = Provider<GetPaymentFeesUseCase>((ref) {
  final repository = ref.read(paymentRepositoryProvider);
  return GetPaymentFeesUseCase(repository);
});

final updatePaymentStatusUseCaseProvider = Provider<UpdatePaymentStatusUseCase>(
  (ref) {
    final repository = ref.read(paymentRepositoryProvider);
    return UpdatePaymentStatusUseCase(repository);
  },
);

// Main payment provider
final paymentProvider = StateNotifierProvider<PaymentNotifier, PaymentState>((
  ref,
) {
  return PaymentNotifier(
    ref.read(initiatePaymentUseCaseProvider),
    ref.read(checkPaymentStatusUseCaseProvider),
    ref.read(getPaymentByOrderIdUseCaseProvider),
    ref.read(getUserPaymentHistoryUseCaseProvider),
    ref.read(cancelPaymentUseCaseProvider),
    ref.read(processRefundUseCaseProvider),
    ref.read(verifyPaymentCallbackUseCaseProvider),
    ref.read(getSupportedPaymentMethodsUseCaseProvider),
    ref.read(validatePhoneNumberUseCaseProvider),
    ref.read(getPaymentFeesUseCaseProvider),
  );
});
