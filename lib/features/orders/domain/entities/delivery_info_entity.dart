import 'package:equatable/equatable.dart';

/// Delivery information entity for orders
class DeliveryInfoEntity extends Equatable {
  final String id;
  final DeliveryType type;
  final String recipientName;
  final String recipientPhone;
  final String address;
  final String? addressLine2;
  final String city;
  final String region;
  final String? postalCode;
  final double? latitude;
  final double? longitude;
  final String? landmark;
  final String? specialInstructions;
  final DateTime? preferredDeliveryDate;
  final String? preferredTimeSlot;
  final double deliveryFee;
  final String? driverId;
  final String? driverName;
  final String? driverPhone;
  final String? vehicleInfo;
  final DateTime? estimatedArrival;
  final DateTime? actualArrival;
  final String? deliveryNotes;
  final List<String> deliveryPhotos;
  final Map<String, dynamic> metadata;

  const DeliveryInfoEntity({
    required this.id,
    required this.type,
    required this.recipientName,
    required this.recipientPhone,
    required this.address,
    this.addressLine2,
    required this.city,
    required this.region,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.landmark,
    this.specialInstructions,
    this.preferredDeliveryDate,
    this.preferredTimeSlot,
    required this.deliveryFee,
    this.driverId,
    this.driverName,
    this.driverPhone,
    this.vehicleInfo,
    this.estimatedArrival,
    this.actualArrival,
    this.deliveryNotes,
    this.deliveryPhotos = const [],
    required this.metadata,
  });

  /// Get full address string
  String get fullAddress {
    final parts = [address];
    if (addressLine2 != null && addressLine2!.isNotEmpty) {
      parts.add(addressLine2!);
    }
    parts.addAll([city, region]);
    if (postalCode != null && postalCode!.isNotEmpty) {
      parts.add(postalCode!);
    }
    return parts.join(', ');
  }

  /// Check if delivery is scheduled
  bool get isScheduled => preferredDeliveryDate != null;

  /// Check if driver is assigned
  bool get hasDriverAssigned => driverId != null;

  /// Check if delivery has location coordinates
  bool get hasCoordinates => latitude != null && longitude != null;

  /// Check if delivery is completed
  bool get isCompleted => actualArrival != null;

  /// Get estimated delivery time remaining
  Duration? get estimatedTimeRemaining {
    if (estimatedArrival == null || isCompleted) return null;
    final now = DateTime.now();
    if (estimatedArrival!.isBefore(now)) return null; // Overdue
    return estimatedArrival!.difference(now);
  }

  /// Create a copy with updated fields
  DeliveryInfoEntity copyWith({
    String? id,
    DeliveryType? type,
    String? recipientName,
    String? recipientPhone,
    String? address,
    String? addressLine2,
    String? city,
    String? region,
    String? postalCode,
    double? latitude,
    double? longitude,
    String? landmark,
    String? specialInstructions,
    DateTime? preferredDeliveryDate,
    String? preferredTimeSlot,
    double? deliveryFee,
    String? driverId,
    String? driverName,
    String? driverPhone,
    String? vehicleInfo,
    DateTime? estimatedArrival,
    DateTime? actualArrival,
    String? deliveryNotes,
    List<String>? deliveryPhotos,
    Map<String, dynamic>? metadata,
  }) {
    return DeliveryInfoEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      recipientName: recipientName ?? this.recipientName,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      address: address ?? this.address,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      region: region ?? this.region,
      postalCode: postalCode ?? this.postalCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      landmark: landmark ?? this.landmark,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      preferredDeliveryDate: preferredDeliveryDate ?? this.preferredDeliveryDate,
      preferredTimeSlot: preferredTimeSlot ?? this.preferredTimeSlot,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      estimatedArrival: estimatedArrival ?? this.estimatedArrival,
      actualArrival: actualArrival ?? this.actualArrival,
      deliveryNotes: deliveryNotes ?? this.deliveryNotes,
      deliveryPhotos: deliveryPhotos ?? this.deliveryPhotos,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'recipientName': recipientName,
      'recipientPhone': recipientPhone,
      'address': address,
      'addressLine2': addressLine2,
      'city': city,
      'region': region,
      'postalCode': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'landmark': landmark,
      'specialInstructions': specialInstructions,
      'preferredDeliveryDate': preferredDeliveryDate?.toIso8601String(),
      'preferredTimeSlot': preferredTimeSlot,
      'deliveryFee': deliveryFee,
      'driverId': driverId,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'vehicleInfo': vehicleInfo,
      'estimatedArrival': estimatedArrival?.toIso8601String(),
      'actualArrival': actualArrival?.toIso8601String(),
      'deliveryNotes': deliveryNotes,
      'deliveryPhotos': deliveryPhotos,
      'metadata': metadata,
    };
  }

  /// Create from map (Firestore document)
  factory DeliveryInfoEntity.fromMap(Map<String, dynamic> map) {
    return DeliveryInfoEntity(
      id: map['id'] ?? '',
      type: DeliveryType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => DeliveryType.delivery,
      ),
      recipientName: map['recipientName'] ?? '',
      recipientPhone: map['recipientPhone'] ?? '',
      address: map['address'] ?? '',
      addressLine2: map['addressLine2'],
      city: map['city'] ?? '',
      region: map['region'] ?? '',
      postalCode: map['postalCode'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      landmark: map['landmark'],
      specialInstructions: map['specialInstructions'],
      preferredDeliveryDate: map['preferredDeliveryDate'] != null
          ? DateTime.parse(map['preferredDeliveryDate'])
          : null,
      preferredTimeSlot: map['preferredTimeSlot'],
      deliveryFee: (map['deliveryFee'] ?? 0.0).toDouble(),
      driverId: map['driverId'],
      driverName: map['driverName'],
      driverPhone: map['driverPhone'],
      vehicleInfo: map['vehicleInfo'],
      estimatedArrival: map['estimatedArrival'] != null
          ? DateTime.parse(map['estimatedArrival'])
          : null,
      actualArrival: map['actualArrival'] != null
          ? DateTime.parse(map['actualArrival'])
          : null,
      deliveryNotes: map['deliveryNotes'],
      deliveryPhotos: List<String>.from(map['deliveryPhotos'] ?? []),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        recipientName,
        recipientPhone,
        address,
        addressLine2,
        city,
        region,
        postalCode,
        latitude,
        longitude,
        landmark,
        specialInstructions,
        preferredDeliveryDate,
        preferredTimeSlot,
        deliveryFee,
        driverId,
        driverName,
        driverPhone,
        vehicleInfo,
        estimatedArrival,
        actualArrival,
        deliveryNotes,
        deliveryPhotos,
        metadata,
      ];

  @override
  String toString() {
    return 'DeliveryInfoEntity(id: $id, type: $type, address: $fullAddress)';
  }
}

/// Delivery type enumeration
enum DeliveryType {
  delivery,
  pickup,
  express,
  scheduled,
}

/// Extension for delivery type
extension DeliveryTypeExtension on DeliveryType {
  String get displayName {
    switch (this) {
      case DeliveryType.delivery:
        return 'Standard Delivery';
      case DeliveryType.pickup:
        return 'Pickup';
      case DeliveryType.express:
        return 'Express Delivery';
      case DeliveryType.scheduled:
        return 'Scheduled Delivery';
    }
  }

  String get description {
    switch (this) {
      case DeliveryType.delivery:
        return 'Standard delivery to your address';
      case DeliveryType.pickup:
        return 'Pick up from farmer or collection point';
      case DeliveryType.express:
        return 'Fast delivery within 2-4 hours';
      case DeliveryType.scheduled:
        return 'Delivery at your preferred time';
    }
  }

  Duration get estimatedDuration {
    switch (this) {
      case DeliveryType.delivery:
        return const Duration(hours: 24);
      case DeliveryType.pickup:
        return const Duration(hours: 2);
      case DeliveryType.express:
        return const Duration(hours: 3);
      case DeliveryType.scheduled:
        return const Duration(hours: 48);
    }
  }
}
