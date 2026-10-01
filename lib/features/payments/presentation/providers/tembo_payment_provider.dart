import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/tembo_payment_service.dart';

/// Provider for TemboPaymentService
final temboPaymentServiceProvider = Provider<TemboPaymentService>((ref) {
  return TemboPaymentService();
});

/// State for active payment transaction
class TemboPaymentState {
  final bool isProcessing;
  final bool isUssdPromptActive;
  final bool isPaid;
  final String? transactionId;
  final String? transactionRef;
  final String? error;
  final int remainingSeconds;

  const TemboPaymentState({
    this.isProcessing = false,
    this.isUssdPromptActive = false,
    this.isPaid = false,
    this.transactionId,
    this.transactionRef,
    this.error,
    this.remainingSeconds = 60,
  });

  TemboPaymentState copyWith({
    bool? isProcessing,
    bool? isUssdPromptActive,
    bool? isPaid,
    String? transactionId,
    String? transactionRef,
    String? error,
    int? remainingSeconds,
  }) {
    return TemboPaymentState(
      isProcessing: isProcessing ?? this.isProcessing,
      isUssdPromptActive: isUssdPromptActive ?? this.isUssdPromptActive,
      isPaid: isPaid ?? this.isPaid,
      transactionId: transactionId ?? this.transactionId,
      transactionRef: transactionRef ?? this.transactionRef,
      error: error,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    );
  }
}

class TemboPaymentNotifier extends StateNotifier<TemboPaymentState> {
  final TemboPaymentService _service;

  TemboPaymentNotifier(this._service) : super(const TemboPaymentState());

  void reset() {
    state = const TemboPaymentState();
  }

  /// Initiate MOMO collection
  Future<TemboCollectionResult> initiatePayment({
    required String channel,
    required String phoneNumber,
    required int amount,
    required String transactionRef,
    required String narration,
  }) async {
    state = state.copyWith(isProcessing: true, error: null);

    final result = await _service.initiateCollection(
      channel: channel,
      phoneNumber: phoneNumber,
      amount: amount,
      transactionRef: transactionRef,
      narration: narration,
    );

    if (result.isSuccess) {
      state = state.copyWith(
        isProcessing: false,
        isUssdPromptActive: true,
        transactionId: result.transactionId,
        transactionRef: result.transactionRef,
        remainingSeconds: 60,
      );
    } else {
      state = state.copyWith(
        isProcessing: false,
        error: result.message ?? 'Payment initiation failed',
      );
    }

    return result;
  }

  /// Mark payment as confirmed / paid
  void markAsPaid({String? transactionId}) {
    state = state.copyWith(
      isProcessing: false,
      isUssdPromptActive: false,
      isPaid: true,
      transactionId: transactionId ?? state.transactionId,
    );
  }

  /// Check payment status
  Future<bool> checkStatus() async {
    if (state.transactionId == null || state.transactionRef == null) return false;

    final result = await _service.checkStatus(
      transactionId: state.transactionId!,
      transactionRef: state.transactionRef!,
    );

    if (result.isAccepted) {
      markAsPaid(transactionId: result.transactionId);
      return true;
    }
    return false;
  }
}

final temboPaymentNotifierProvider =
    StateNotifierProvider<TemboPaymentNotifier, TemboPaymentState>((ref) {
  final service = ref.watch(temboPaymentServiceProvider);
  return TemboPaymentNotifier(service);
});
