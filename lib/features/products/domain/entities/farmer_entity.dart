import 'package:equatable/equatable.dart';

/// Farmer entity representing farmers in the system
class FarmerEntity extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String? profileImageUrl;
  final String farmName;
  final String farmDescription;
  final String location;
  final double latitude;
  final double longitude;
  final List<String> specialties; // Types of crops they grow
  final double rating;
  final int reviewCount;
  final int totalProducts;
  final bool isVerified;
  final bool isActive;
  final DateTime joinedDate;
  final DateTime? lastActiveDate;
  final Map<String, dynamic> certifications; // Organic, etc.
  final Map<String, dynamic> contactInfo; // Additional contact methods
  final DateTime createdAt;
  final DateTime updatedAt;

  const FarmerEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    this.profileImageUrl,
    required this.farmName,
    required this.farmDescription,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.specialties,
    required this.rating,
    required this.reviewCount,
    required this.totalProducts,
    required this.isVerified,
    required this.isActive,
    required this.joinedDate,
    this.lastActiveDate,
    required this.certifications,
    required this.contactInfo,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get farmer's full name
  String get fullName => '$firstName $lastName';

  /// Get farmer's display name (farm name or full name)
  String get displayName => farmName.isNotEmpty ? farmName : fullName;

  /// Check if farmer is recently active (within last 7 days)
  bool get isRecentlyActive {
    if (lastActiveDate == null) return false;
    final daysSinceActive = DateTime.now().difference(lastActiveDate!).inDays;
    return daysSinceActive <= 7;
  }

  /// Check if farmer has organic certification
  bool get isOrganicCertified {
    return certifications.containsKey('organic') && 
           certifications['organic'] == true;
  }

  /// Get farmer's experience in years
  int get experienceYears {
    return DateTime.now().difference(joinedDate).inDays ~/ 365;
  }

  /// Create a copy with updated fields
  FarmerEntity copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? profileImageUrl,
    String? farmName,
    String? farmDescription,
    String? location,
    double? latitude,
    double? longitude,
    List<String>? specialties,
    double? rating,
    int? reviewCount,
    int? totalProducts,
    bool? isVerified,
    bool? isActive,
    DateTime? joinedDate,
    DateTime? lastActiveDate,
    Map<String, dynamic>? certifications,
    Map<String, dynamic>? contactInfo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FarmerEntity(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      farmName: farmName ?? this.farmName,
      farmDescription: farmDescription ?? this.farmDescription,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      specialties: specialties ?? this.specialties,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      totalProducts: totalProducts ?? this.totalProducts,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      joinedDate: joinedDate ?? this.joinedDate,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      certifications: certifications ?? this.certifications,
      contactInfo: contactInfo ?? this.contactInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'farmName': farmName,
      'farmDescription': farmDescription,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'specialties': specialties,
      'rating': rating,
      'reviewCount': reviewCount,
      'totalProducts': totalProducts,
      'isVerified': isVerified,
      'isActive': isActive,
      'joinedDate': joinedDate.toIso8601String(),
      'lastActiveDate': lastActiveDate?.toIso8601String(),
      'certifications': certifications,
      'contactInfo': contactInfo,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from map (Firestore document)
  factory FarmerEntity.fromMap(Map<String, dynamic> map) {
    return FarmerEntity(
      id: map['id'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'],
      profileImageUrl: map['profileImageUrl'],
      farmName: map['farmName'] ?? '',
      farmDescription: map['farmDescription'] ?? '',
      location: map['location'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      specialties: List<String>.from(map['specialties'] ?? []),
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      totalProducts: map['totalProducts'] ?? 0,
      isVerified: map['isVerified'] ?? false,
      isActive: map['isActive'] ?? true,
      joinedDate: DateTime.parse(map['joinedDate']),
      lastActiveDate: map['lastActiveDate'] != null 
          ? DateTime.parse(map['lastActiveDate']) 
          : null,
      certifications: Map<String, dynamic>.from(map['certifications'] ?? {}),
      contactInfo: Map<String, dynamic>.from(map['contactInfo'] ?? {}),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        email,
        phoneNumber,
        profileImageUrl,
        farmName,
        farmDescription,
        location,
        latitude,
        longitude,
        specialties,
        rating,
        reviewCount,
        totalProducts,
        isVerified,
        isActive,
        joinedDate,
        lastActiveDate,
        certifications,
        contactInfo,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'FarmerEntity(id: $id, farmName: $farmName, fullName: $fullName, rating: $rating)';
  }
}
