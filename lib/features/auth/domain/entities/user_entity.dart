import 'package:equatable/equatable.dart';

/// User entity representing a user in the system
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? profileImageUrl;
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserRole role;
  final UserStatus status;
  final Address? address;
  final Map<String, dynamic>? preferences;

  const UserEntity({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.profileImageUrl,
    this.isEmailVerified = false,
    required this.createdAt,
    required this.updatedAt,
    this.role = UserRole.customer,
    this.status = UserStatus.active,
    this.address,
    this.preferences,
  });

  /// Get full name
  String get fullName => '$firstName $lastName';

  /// Get display name (first name or full name)
  String get displayName => firstName.isNotEmpty ? firstName : fullName;

  /// Get initials for avatar
  String get initials {
    final first = firstName.isNotEmpty ? firstName[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    return (first + last).toUpperCase();
  }

  /// Check if user is a farmer
  bool get isFarmer => role == UserRole.farmer;

  /// Check if user is an admin
  bool get isAdmin => role == UserRole.admin;

  /// Check if user is active
  bool get isActive => status == UserStatus.active;

  /// Copy with method
  UserEntity copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profileImageUrl,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserRole? role,
    UserStatus? status,
    Address? address,
    Map<String, dynamic>? preferences,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      role: role ?? this.role,
      status: status ?? this.status,
      address: address ?? this.address,
      preferences: preferences ?? this.preferences,
    );
  }

  /// Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'role': role.name,
      'status': status.name,
      'address': address?.toMap(),
      'preferences': preferences,
    };
  }

  /// Create from map (Firestore document)
  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      phoneNumber: map['phoneNumber'],
      profileImageUrl: map['profileImageUrl'],
      isEmailVerified: map['isEmailVerified'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      role: UserRole.values.firstWhere(
        (role) => role.name == map['role'],
        orElse: () => UserRole.customer,
      ),
      status: UserStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => UserStatus.active,
      ),
      address: map['address'] != null ? Address.fromMap(map['address']) : null,
      preferences: map['preferences'],
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        phoneNumber,
        profileImageUrl,
        isEmailVerified,
        createdAt,
        updatedAt,
        role,
        status,
        address,
        preferences,
      ];

  @override
  String toString() {
    return 'UserEntity(id: $id, email: $email, fullName: $fullName, role: $role, status: $status)';
  }
}

/// User roles in the system
enum UserRole {
  customer,
  farmer,
  admin,
}

/// User status
enum UserStatus {
  active,
  inactive,
  suspended,
  pending,
}

/// Address entity
class Address extends Equatable {
  final String street;
  final String city;
  final String region;
  final String postalCode;
  final String country;
  final double? latitude;
  final double? longitude;

  const Address({
    required this.street,
    required this.city,
    required this.region,
    required this.postalCode,
    this.country = 'Tanzania',
    this.latitude,
    this.longitude,
  });

  /// Get formatted address
  String get formattedAddress {
    return '$street, $city, $region $postalCode, $country';
  }

  /// Copy with method
  Address copyWith({
    String? street,
    String? city,
    String? region,
    String? postalCode,
    String? country,
    double? latitude,
    double? longitude,
  }) {
    return Address(
      street: street ?? this.street,
      city: city ?? this.city,
      region: region ?? this.region,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'street': street,
      'city': city,
      'region': region,
      'postalCode': postalCode,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// Create from map
  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      street: map['street'] ?? '',
      city: map['city'] ?? '',
      region: map['region'] ?? '',
      postalCode: map['postalCode'] ?? '',
      country: map['country'] ?? 'Tanzania',
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [
        street,
        city,
        region,
        postalCode,
        country,
        latitude,
        longitude,
      ];

  @override
  String toString() {
    return 'Address(street: $street, city: $city, region: $region, country: $country)';
  }
}

/// User preferences
class UserPreferences extends Equatable {
  final bool notificationsEnabled;
  final bool emailNotifications;
  final bool pushNotifications;
  final bool smsNotifications;
  final String language;
  final String currency;
  final bool darkMode;
  final Map<String, bool> categoryPreferences;

  const UserPreferences({
    this.notificationsEnabled = true,
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.smsNotifications = false,
    this.language = 'en',
    this.currency = 'TZS',
    this.darkMode = false,
    this.categoryPreferences = const {},
  });

  /// Copy with method
  UserPreferences copyWith({
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? pushNotifications,
    bool? smsNotifications,
    String? language,
    String? currency,
    bool? darkMode,
    Map<String, bool>? categoryPreferences,
  }) {
    return UserPreferences(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      darkMode: darkMode ?? this.darkMode,
      categoryPreferences: categoryPreferences ?? this.categoryPreferences,
    );
  }

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
      'smsNotifications': smsNotifications,
      'language': language,
      'currency': currency,
      'darkMode': darkMode,
      'categoryPreferences': categoryPreferences,
    };
  }

  /// Create from map
  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      emailNotifications: map['emailNotifications'] ?? true,
      pushNotifications: map['pushNotifications'] ?? true,
      smsNotifications: map['smsNotifications'] ?? false,
      language: map['language'] ?? 'en',
      currency: map['currency'] ?? 'TZS',
      darkMode: map['darkMode'] ?? false,
      categoryPreferences: Map<String, bool>.from(
        map['categoryPreferences'] ?? {},
      ),
    );
  }

  @override
  List<Object?> get props => [
        notificationsEnabled,
        emailNotifications,
        pushNotifications,
        smsNotifications,
        language,
        currency,
        darkMode,
        categoryPreferences,
      ];

  @override
  String toString() {
    return 'UserPreferences(language: $language, currency: $currency, darkMode: $darkMode)';
  }
}
