import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/config/firebase_config.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/payment_request_entity.dart';
import '../../domain/entities/payment_response_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../services/clickpesa_service.dart';

/// Implementation of PaymentRepository using ClickPesa and Firestore
class PaymentRepositoryImpl implements PaymentRepository {
  final FirestoreService _firestoreService;
  final ClickPesaService _clickPesaService;

  PaymentRepositoryImpl(this._firestoreService, this._clickPesaService);

  @override
  Future<Result<PaymentResponseEntity>> initiatePayment({
    required PaymentRequestEntity request,
  }) async {
    try {
      // Save payment request to Firestore
      await _savePaymentRequest(request);

      // Initiate payment based on method
      Result<PaymentResponseEntity> result;
      switch (request.method) {
        case PaymentMethod.mobileMoney:
          result = await _clickPesaService.initiateMobileMoneyPayment(
            request: request,
          );
          break;
        case PaymentMethod.card:
          // TODO: Implement card payment
          result = const Result.failure(
            ServerFailure(message: 'Card payments not yet implemented'),
          );
          break;
        case PaymentMethod.bankTransfer:
          // TODO: Implement bank transfer
          result = const Result.failure(
            ServerFailure(message: 'Bank transfers not yet implemented'),
          );
          break;
        case PaymentMethod.cash:
          // Cash payments are handled offline
          result = Result.success(
            PaymentResponseEntity(
              id: request.id,
              requestId: request.id,
              orderId: request.orderId,
              status: PaymentStatus.pending,
              amount: request.amount,
              currency: request.currency,
              providerData: const {'method': 'cash'},
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
          break;
      }

      // Save payment response to Firestore
      if (result.isSuccess) {
        await _savePaymentResponse(result.data!);
      }

      return result;
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Failed to initiate payment: $e'),
      );
    }
  }

  @override
  Future<Result<PaymentResponseEntity>> checkPaymentStatus({
    required String paymentId,
  }) async {
    try {
      // First check local database
      final localResult = await _getPaymentFromFirestore(paymentId);
      if (localResult.isSuccess && localResult.data != null) {
        final localPayment = localResult.data!;

        // If payment is terminal, return local data
        if (localPayment.status.isTerminal) {
          return Result.success(localPayment);
        }
      }

      // Check with ClickPesa for latest status
      final clickPesaResult = await _clickPesaService.checkPaymentStatus(
        paymentId: paymentId,
      );

      if (clickPesaResult.isSuccess) {
        // Update local database with latest status
        await _savePaymentResponse(clickPesaResult.data!);
        return clickPesaResult;
      }

      // If ClickPesa fails but we have local data, return local data
      if (localResult.isSuccess && localResult.data != null) {
        return Result.success(localResult.data!);
      }

      return clickPesaResult;
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Failed to check payment status: $e'),
      );
    }
  }

  @override
  Future<Result<PaymentResponseEntity?>> getPaymentByTransactionId({
    required String transactionId,
  }) async {
    try {
      final query = FirebaseFirestore.instance
          .collection(FirebaseCollections.payments)
          .where('transactionId', isEqualTo: transactionId)
          .limit(1);

      final snapshot = await query.get();
      if (snapshot.docs.isEmpty) {
        return const Result.success(null);
      }

      final doc = snapshot.docs.first;
      final payment = PaymentResponseEntity.fromMap({
        'id': doc.id,
        ...doc.data(),
      });

      return Result.success(payment);
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Failed to get payment by transaction ID: $e'),
      );
    }
  }

  @override
  Future<Result<PaymentResponseEntity?>> getPaymentByOrderId({
    required String orderId,
  }) async {
    try {
      final query = FirebaseFirestore.instance
          .collection(FirebaseCollections.payments)
          .where('orderId', isEqualTo: orderId)
          .orderBy('createdAt', descending: true)
          .limit(1);

      final snapshot = await query.get();
      if (snapshot.docs.isEmpty) {
        return const Result.success(null);
      }

      final doc = snapshot.docs.first;
      final payment = PaymentResponseEntity.fromMap({
        'id': doc.id,
        ...doc.data(),
      });

      return Result.success(payment);
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Failed to get payment by order ID: $e'),
      );
    }
  }

  @override
  Future<Result<List<PaymentResponseEntity>>> getUserPaymentHistory({
    required String userId,
    int limit = 20,
    String? startAfter,
  }) async {
    try {
      Query query = FirebaseFirestore.instance
          .collection(FirebaseCollections.payments)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (startAfter != null) {
        final startDoc = await FirebaseFirestore.instance
            .collection(FirebaseCollections.payments)
            .doc(startAfter)
            .get();
        if (startDoc.exists) {
          query = query.startAfterDocument(startDoc);
        }
      }

      final snapshot = await query.get();
      final payments = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return PaymentResponseEntity.fromMap({'id': doc.id, ...data});
      }).toList();

      return Result.success(payments);
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Failed to get user payment history: $e'),
      );
    }
  }

  @override
  Future<Result<PaymentResponseEntity>> cancelPayment({
    required String paymentId,
    required String reason,
  }) async {
    try {
      final result = await _clickPesaService.cancelPayment(
        paymentId: paymentId,
        reason: reason,
      );

      if (result.isSuccess) {
        await _savePaymentResponse(result.data!);
      }

      return result;
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Failed to cancel payment: $e'),
      );
    }
  }

  @override
  Future<Result<PaymentResponseEntity>> processRefund({
    required String originalPaymentId,
    required double amount,
    required String reason,
  }) async {
    try {
      final result = await _clickPesaService.processRefund(
        originalPaymentId: originalPaymentId,
        amount: amount,
        reason: reason,
      );

      if (result.isSuccess) {
        await _savePaymentResponse(result.data!);
      }

      return result;
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Failed to process refund: $e'),
      );
    }
  }

  @override
  Future<Result<PaymentResponseEntity>> verifyPaymentCallback({
    required Map<String, dynamic> callbackData,
    required String signature,
  }) async {
    try {
      final result = await _clickPesaService.verifyCallback(
        callbackData: callbackData,
        receivedSignature: signature,
      );

      if (result.isSuccess) {
        await _savePaymentResponse(result.data!);
      }

      return result;
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Failed to verify payment callback: $e'),
      );
    }
  }

  @override
  Future<Result<List<PaymentMethodInfo>>> getSupportedPaymentMethods() async {
    try {
      // Return supported payment methods for Tanzania
      final methods = [
        const PaymentMethodInfo(
          method: PaymentMethod.mobileMoney,
          providers: [
            PaymentProvider.clickpesa,
            PaymentProvider.mpesa,
            PaymentProvider.tigopesa,
            PaymentProvider.airtelmoney,
            PaymentProvider.halopesa,
          ],
          isEnabled: true,
          minimumAmount: 1000.0, // 1,000 TZS
          maximumAmount: 10000000.0, // 10,000,000 TZS
          description: 'Pay using your mobile money account',
        ),
        const PaymentMethodInfo(
          method: PaymentMethod.cash,
          providers: [],
          isEnabled: true,
          minimumAmount: 1000.0,
          maximumAmount: 1000000.0, // 1,000,000 TZS for cash
          description: 'Pay cash when your order is delivered',
        ),
        const PaymentMethodInfo(
          method: PaymentMethod.card,
          providers: [PaymentProvider.clickpesa],
          isEnabled: false, // TODO: Enable when implemented
          minimumAmount: 1000.0,
          maximumAmount: 10000000.0,
          description: 'Pay with your credit or debit card',
        ),
      ];

      return Result.success(methods);
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Failed to get supported payment methods: $e'),
      );
    }
  }

  @override
  Future<Result<PaymentProviderValidation>> validatePhoneNumber({
    required String phoneNumber,
    PaymentProvider? preferredProvider,
  }) async {
    try {
      final supportedProviders = <PaymentProvider>[];
      PaymentProvider? recommendedProvider;

      // Check which providers support this phone number
      for (final provider in PaymentProvider.values) {
        if (provider.supportsPhoneNumber(phoneNumber)) {
          supportedProviders.add(provider);
          recommendedProvider ??= provider;
        }
      }

      // If preferred provider is specified and supported, use it
      if (preferredProvider != null &&
          supportedProviders.contains(preferredProvider)) {
        recommendedProvider = preferredProvider;
      }

      final isValid = supportedProviders.isNotEmpty;
      final errorMessage = isValid
          ? null
          : 'Phone number is not supported by any payment provider';

      return Result.success(
        PaymentProviderValidation(
          isValid: isValid,
          recommendedProvider: recommendedProvider,
          supportedProviders: supportedProviders,
          errorMessage: errorMessage,
        ),
      );
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Failed to validate phone number: $e'),
      );
    }
  }

  @override
  Future<Result<PaymentFees>> getPaymentFees({
    required double amount,
    required PaymentMethod method,
    required PaymentProvider provider,
  }) async {
    try {
      // Calculate fees based on method and provider
      double transactionFee = 0.0;
      double processingFee = 0.0;
      String feeStructure = '';

      switch (method) {
        case PaymentMethod.mobileMoney:
          // Mobile money fees (example rates)
          if (amount <= 10000) {
            transactionFee = 300.0;
          } else if (amount <= 50000) {
            transactionFee = 500.0;
          } else {
            transactionFee = amount * 0.01; // 1%
          }
          feeStructure = 'Mobile money transaction fee';
          break;
        case PaymentMethod.card:
          // Card processing fees
          transactionFee = amount * 0.035; // 3.5%
          feeStructure = 'Card processing fee (3.5%)';
          break;
        case PaymentMethod.cash:
          // No fees for cash
          transactionFee = 0.0;
          feeStructure = 'No fees for cash payments';
          break;
        case PaymentMethod.bankTransfer:
          // Bank transfer fees
          transactionFee = 1000.0; // Flat fee
          feeStructure = 'Bank transfer fee';
          break;
      }

      final totalFees = transactionFee + processingFee;
      final netAmount = amount - totalFees;

      return Result.success(
        PaymentFees(
          transactionFee: transactionFee,
          processingFee: processingFee,
          totalFees: totalFees,
          netAmount: netAmount,
          currency: 'TZS',
          feeStructure: feeStructure,
        ),
      );
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Failed to calculate payment fees: $e'),
      );
    }
  }

  @override
  Future<Result<void>> savePaymentRequest({
    required PaymentRequestEntity request,
  }) async {
    return _savePaymentRequest(request);
  }

  @override
  Future<Result<PaymentResponseEntity>> updatePaymentStatus({
    required String paymentId,
    required PaymentStatus status,
    String? transactionId,
    String? failureReason,
    Map<String, dynamic>? providerData,
  }) async {
    try {
      final paymentResult = await _getPaymentFromFirestore(paymentId);
      if (paymentResult.isFailure || paymentResult.data == null) {
        return const Result.failure(
          NotFoundFailure(message: 'Payment not found'),
        );
      }

      final payment = paymentResult.data!;
      final updatedPayment = payment.copyWith(
        status: status,
        transactionId: transactionId,
        failureReason: failureReason,
        providerData: providerData ?? payment.providerData,
        processedAt: status == PaymentStatus.completed ? DateTime.now() : null,
        updatedAt: DateTime.now(),
      );

      await _savePaymentResponse(updatedPayment);
      return Result.success(updatedPayment);
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Failed to update payment status: $e'),
      );
    }
  }

  // Helper methods
  Future<Result<void>> _savePaymentRequest(PaymentRequestEntity request) async {
    try {
      final result = await _firestoreService.createDocument(
        collection: FirebaseCollections.paymentRequests,
        data: request.toMap(),
        documentId: request.id,
      );

      return result;
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Failed to save payment request: $e'),
      );
    }
  }

  Future<Result<void>> _savePaymentResponse(
    PaymentResponseEntity response,
  ) async {
    try {
      final result = await _firestoreService.updateDocument(
        collection: FirebaseCollections.payments,
        documentId: response.id,
        data: response.toMap(),
        merge: true,
      );

      return result;
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Failed to save payment response: $e'),
      );
    }
  }

  Future<Result<PaymentResponseEntity?>> _getPaymentFromFirestore(
    String paymentId,
  ) async {
    try {
      final result = await _firestoreService.getDocument(
        collection: FirebaseCollections.payments,
        documentId: paymentId,
      );

      if (result.isSuccess && result.data != null) {
        return Result.success(PaymentResponseEntity.fromMap(result.data!));
      } else {
        return const Result.success(null);
      }
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Failed to get payment from Firestore: $e'),
      );
    }
  }
}
