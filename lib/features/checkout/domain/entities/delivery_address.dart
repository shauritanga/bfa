import 'package:equatable/equatable.dart';

/// Delivery address entity for checkout
class DeliveryAddress extends Equatable {
  final String recipientName;
  final String phoneNumber;
  final String address;
  final String? addressLine2;
  final String city;
  final String region;
  final String? postalCode;
  final double? latitude;
  final double? longitude;
  final String? landmark;
  final String? specialInstructions;
  final bool isDefault;

  const DeliveryAddress({
    required this.recipientName,
    required this.phoneNumber,
    required this.address,
    this.addressLine2,
    required this.city,
    required this.region,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.landmark,
    this.specialInstructions,
    this.isDefault = false,
  });

  /// Create empty address
  factory DeliveryAddress.empty() {
    return const DeliveryAddress(
      recipientName: '',
      phoneNumber: '',
      address: '',
      city: '',
      region: '',
    );
  }

  /// Create from map
  factory DeliveryAddress.fromMap(Map<String, dynamic> map) {
    return DeliveryAddress(
      recipientName: map['recipientName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      address: map['address'] ?? '',
      addressLine2: map['addressLine2'],
      city: map['city'] ?? '',
      region: map['region'] ?? '',
      postalCode: map['postalCode'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      landmark: map['landmark'],
      specialInstructions: map['specialInstructions'],
      isDefault: map['isDefault'] ?? false,
    );
  }

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'recipientName': recipientName,
      'phoneNumber': phoneNumber,
      'address': address,
      'addressLine2': addressLine2,
      'city': city,
      'region': region,
      'postalCode': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'landmark': landmark,
      'specialInstructions': specialInstructions,
      'isDefault': isDefault,
    };
  }

  /// Create copy with updated fields
  DeliveryAddress copyWith({
    String? recipientName,
    String? phoneNumber,
    String? address,
    String? addressLine2,
    String? city,
    String? region,
    String? postalCode,
    double? latitude,
    double? longitude,
    String? landmark,
    String? specialInstructions,
    bool? isDefault,
  }) {
    return DeliveryAddress(
      recipientName: recipientName ?? this.recipientName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      region: region ?? this.region,
      postalCode: postalCode ?? this.postalCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      landmark: landmark ?? this.landmark,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  /// Get formatted address
  String get formattedAddress {
    final parts = <String>[
      address,
      if (addressLine2?.isNotEmpty == true) addressLine2!,
      city,
      region,
      if (postalCode?.isNotEmpty == true) postalCode!,
    ];
    return parts.join(', ');
  }

  /// Check if address is complete
  bool get isComplete {
    return recipientName.isNotEmpty &&
           phoneNumber.isNotEmpty &&
           address.isNotEmpty &&
           city.isNotEmpty &&
           region.isNotEmpty;
  }

  @override
  List<Object?> get props => [
        recipientName,
        phoneNumber,
        address,
        addressLine2,
        city,
        region,
        postalCode,
        latitude,
        longitude,
        landmark,
        specialInstructions,
        isDefault,
      ];

  @override
  String toString() {
    return 'DeliveryAddress(recipientName: $recipientName, address: $formattedAddress)';
  }
}
