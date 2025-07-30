import 'package:equatable/equatable.dart';

/// Payment response entity for payment results
class PaymentResponseEntity extends Equatable {
  final String id;
  final String requestId;
  final String orderId;
  final PaymentStatus status;
  final String? transactionId;
  final String? referenceNumber;
  final String? providerTransactionId;
  final double amount;
  final String currency;
  final String? failureReason;
  final String? failureCode;
  final Map<String, dynamic> providerData;
  final DateTime? processedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PaymentResponseEntity({
    required this.id,
    required this.requestId,
    required this.orderId,
    required this.status,
    this.transactionId,
    this.referenceNumber,
    this.providerTransactionId,
    required this.amount,
    required this.currency,
    this.failureReason,
    this.failureCode,
    required this.providerData,
    this.processedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if payment was successful
  bool get isSuccessful => status == PaymentStatus.completed;

  /// Check if payment failed
  bool get isFailed => status == PaymentStatus.failed;

  /// Check if payment is pending
  bool get isPending =>
      status == PaymentStatus.pending || status == PaymentStatus.processing;

  /// Get user-friendly status message
  String get statusMessage {
    switch (status) {
      case PaymentStatus.pending:
        return 'Payment is being processed';
      case PaymentStatus.processing:
        return 'Processing your payment';
      case PaymentStatus.completed:
        return 'Payment completed successfully';
      case PaymentStatus.failed:
        return failureReason ?? 'Payment failed';
      case PaymentStatus.cancelled:
        return 'Payment was cancelled';
      case PaymentStatus.expired:
        return 'Payment request expired';
      case PaymentStatus.refunded:
        return 'Payment has been refunded';
      case PaymentStatus.partiallyRefunded:
        return 'Payment has been partially refunded';
    }
  }

  /// Create a copy with updated fields
  PaymentResponseEntity copyWith({
    String? id,
    String? requestId,
    String? orderId,
    PaymentStatus? status,
    String? transactionId,
    String? referenceNumber,
    String? providerTransactionId,
    double? amount,
    String? currency,
    String? failureReason,
    String? failureCode,
    Map<String, dynamic>? providerData,
    DateTime? processedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentResponseEntity(
      id: id ?? this.id,
      requestId: requestId ?? this.requestId,
      orderId: orderId ?? this.orderId,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      providerTransactionId:
          providerTransactionId ?? this.providerTransactionId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      failureReason: failureReason ?? this.failureReason,
      failureCode: failureCode ?? this.failureCode,
      providerData: providerData ?? this.providerData,
      processedAt: processedAt ?? this.processedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'requestId': requestId,
      'orderId': orderId,
      'status': status.name,
      'transactionId': transactionId,
      'referenceNumber': referenceNumber,
      'providerTransactionId': providerTransactionId,
      'amount': amount,
      'currency': currency,
      'failureReason': failureReason,
      'failureCode': failureCode,
      'providerData': providerData,
      'processedAt': processedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from map
  factory PaymentResponseEntity.fromMap(Map<String, dynamic> map) {
    return PaymentResponseEntity(
      id: map['id'] ?? '',
      requestId: map['requestId'] ?? '',
      orderId: map['orderId'] ?? '',
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => PaymentStatus.pending,
      ),
      transactionId: map['transactionId'],
      referenceNumber: map['referenceNumber'],
      providerTransactionId: map['providerTransactionId'],
      amount: (map['amount'] ?? 0.0).toDouble(),
      currency: map['currency'] ?? 'TZS',
      failureReason: map['failureReason'],
      failureCode: map['failureCode'],
      providerData: Map<String, dynamic>.from(map['providerData'] ?? {}),
      processedAt: map['processedAt'] != null
          ? DateTime.parse(map['processedAt'])
          : null,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  /// Create from ClickPesa API response
  factory PaymentResponseEntity.fromClickPesaResponse({
    required String id,
    required String requestId,
    required String orderId,
    required Map<String, dynamic> apiResponse,
  }) {
    final status = _parseClickPesaStatus(apiResponse['status']);
    final now = DateTime.now();

    return PaymentResponseEntity(
      id: id,
      requestId: requestId,
      orderId: orderId,
      status: status,
      transactionId: apiResponse['transaction_id'],
      referenceNumber: apiResponse['reference'],
      providerTransactionId: apiResponse['provider_transaction_id'],
      amount: (apiResponse['amount'] ?? 0.0).toDouble(),
      currency: apiResponse['currency'] ?? 'TZS',
      failureReason: apiResponse['failure_reason'],
      failureCode: apiResponse['failure_code'],
      providerData: Map<String, dynamic>.from(apiResponse),
      processedAt: status == PaymentStatus.completed ? now : null,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Parse ClickPesa status to our PaymentStatus enum
  static PaymentStatus _parseClickPesaStatus(dynamic status) {
    if (status == null) return PaymentStatus.pending;

    final statusStr = status.toString().toLowerCase();
    switch (statusStr) {
      case 'pending':
      case 'initiated':
        return PaymentStatus.pending;
      case 'processing':
      case 'in_progress':
        return PaymentStatus.processing;
      case 'completed':
      case 'success':
      case 'successful':
        return PaymentStatus.completed;
      case 'failed':
      case 'failure':
      case 'error':
        return PaymentStatus.failed;
      case 'cancelled':
      case 'canceled':
        return PaymentStatus.cancelled;
      case 'expired':
      case 'timeout':
        return PaymentStatus.expired;
      default:
        return PaymentStatus.pending;
    }
  }

  @override
  List<Object?> get props => [
    id,
    requestId,
    orderId,
    status,
    transactionId,
    referenceNumber,
    providerTransactionId,
    amount,
    currency,
    failureReason,
    failureCode,
    providerData,
    processedAt,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'PaymentResponseEntity(id: $id, orderId: $orderId, status: $status, amount: $amount)';
  }
}

/// Payment status enumeration
enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
  expired,
  refunded,
  partiallyRefunded,
}

/// Extension for payment status
extension PaymentStatusExtension on PaymentStatus {
  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.processing:
        return 'Processing';
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.cancelled:
        return 'Cancelled';
      case PaymentStatus.expired:
        return 'Expired';
      case PaymentStatus.refunded:
        return 'Refunded';
      case PaymentStatus.partiallyRefunded:
        return 'Partially Refunded';
    }
  }

  String get description {
    switch (this) {
      case PaymentStatus.pending:
        return 'Payment is waiting to be processed';
      case PaymentStatus.processing:
        return 'Payment is being processed';
      case PaymentStatus.completed:
        return 'Payment completed successfully';
      case PaymentStatus.failed:
        return 'Payment failed to process';
      case PaymentStatus.cancelled:
        return 'Payment was cancelled';
      case PaymentStatus.expired:
        return 'Payment request has expired';
      case PaymentStatus.refunded:
        return 'Payment has been refunded';
      case PaymentStatus.partiallyRefunded:
        return 'Payment has been partially refunded';
    }
  }

  bool get isTerminal =>
      this == PaymentStatus.completed ||
      this == PaymentStatus.failed ||
      this == PaymentStatus.cancelled ||
      this == PaymentStatus.expired;

  bool get isSuccessful => this == PaymentStatus.completed;
}
