import '../../../../core/utils/result.dart';
import '../../../../core/repositories/base_repository.dart';
import '../entities/farmer_entity.dart';

/// Farmer repository interface
abstract class FarmerRepository extends BaseRepository<FarmerEntity, String> {
  /// Get verified farmers only
  Future<Result<List<FarmerEntity>>> getVerifiedFarmers();

  /// Get active farmers only
  Future<Result<List<FarmerEntity>>> getActiveFarmers();

  /// Get farmers by location (nearby)
  Future<Result<List<FarmerEntity>>> getFarmersByLocation({
    required double latitude,
    required double longitude,
    required double radiusKm,
  });

  /// Search farmers by name or farm name
  Future<Result<List<FarmerEntity>>> searchFarmers({
    required String query,
  });

  /// Get farmers by specialty (crop types)
  Future<Result<List<FarmerEntity>>> getFarmersBySpecialty({
    required String specialty,
  });

  /// Get top-rated farmers
  Future<Result<List<FarmerEntity>>> getTopRatedFarmers({
    int limit = 10,
  });

  /// Get recently joined farmers
  Future<Result<List<FarmerEntity>>> getRecentlyJoinedFarmers({
    int limit = 10,
  });

  /// Get organic certified farmers
  Future<Result<List<FarmerEntity>>> getOrganicCertifiedFarmers();

  /// Update farmer rating
  Future<Result<void>> updateFarmerRating({
    required String farmerId,
    required double newRating,
    required int newReviewCount,
  });

  /// Update farmer product count
  Future<Result<void>> updateFarmerProductCount({
    required String farmerId,
    required int productCount,
  });

  /// Update farmer last active date
  Future<Result<void>> updateFarmerLastActive({
    required String farmerId,
    required DateTime lastActiveDate,
  });

  /// Get farmer statistics
  Future<Result<FarmerStatistics>> getFarmerStatistics();

  /// Get farmers with pagination
  Future<Result<PaginatedResult<FarmerEntity>>> getFarmersWithPagination({
    int page = 1,
    int limit = 20,
    String? searchQuery,
    bool? isVerified,
    bool? isActive,
  });
}

/// Farmer statistics data class
class FarmerStatistics {
  final int totalFarmers;
  final int verifiedFarmers;
  final int activeFarmers;
  final int organicCertifiedFarmers;
  final double averageRating;
  final Map<String, int> farmersByLocation;
  final Map<String, int> farmersBySpecialty;

  const FarmerStatistics({
    required this.totalFarmers,
    required this.verifiedFarmers,
    required this.activeFarmers,
    required this.organicCertifiedFarmers,
    required this.averageRating,
    required this.farmersByLocation,
    required this.farmersBySpecialty,
  });

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'totalFarmers': totalFarmers,
      'verifiedFarmers': verifiedFarmers,
      'activeFarmers': activeFarmers,
      'organicCertifiedFarmers': organicCertifiedFarmers,
      'averageRating': averageRating,
      'farmersByLocation': farmersByLocation,
      'farmersBySpecialty': farmersBySpecialty,
    };
  }

  /// Create from map
  factory FarmerStatistics.fromMap(Map<String, dynamic> map) {
    return FarmerStatistics(
      totalFarmers: map['totalFarmers'] ?? 0,
      verifiedFarmers: map['verifiedFarmers'] ?? 0,
      activeFarmers: map['activeFarmers'] ?? 0,
      organicCertifiedFarmers: map['organicCertifiedFarmers'] ?? 0,
      averageRating: (map['averageRating'] ?? 0.0).toDouble(),
      farmersByLocation: Map<String, int>.from(map['farmersByLocation'] ?? {}),
      farmersBySpecialty: Map<String, int>.from(map['farmersBySpecialty'] ?? {}),
    );
  }
}
