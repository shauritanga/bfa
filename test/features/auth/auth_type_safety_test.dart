import 'package:flutter_test/flutter_test.dart';
import 'package:bfa/features/auth/domain/entities/user_entity.dart';

void main() {
  group('Authentication Type Safety Tests', () {
    test('UserEntity.fromMap should handle list type casting safely', () {
      // Test case that would previously cause "list of type is not of subtype string" error
      final problematicMap = {
        'id': 'test-id',
        'email': 'test@example.com',
        'firstName': ['John'], // This could be a list instead of string
        'lastName': ['Doe', 'Smith'], // This could be a list instead of string
        'phoneNumber': ['+255', '123', '456789'], // This could be a list
        'profileImageUrl': null,
        'isEmailVerified': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'role': 'customer',
        'status': 'active',
        'address': null,
        'preferences': null,
      };

      // This should not throw an error
      expect(() => UserEntity.fromMap(problematicMap), returnsNormally);

      final userEntity = UserEntity.fromMap(problematicMap);

      // Verify that lists are properly converted to strings
      expect(userEntity.firstName, equals('John'));
      expect(userEntity.lastName, equals('Doe Smith'));
      expect(userEntity.phoneNumber, equals('+255 123 456789'));
    });

    test('UserEntity.fromMap should handle null values safely', () {
      final mapWithNulls = {
        'id': 'test-id',
        'email': 'test@example.com',
        'firstName': null,
        'lastName': null,
        'phoneNumber': null,
        'profileImageUrl': null,
        'isEmailVerified': false,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'role': 'customer',
        'status': 'active',
        'address': null,
        'preferences': null,
      };

      expect(() => UserEntity.fromMap(mapWithNulls), returnsNormally);

      final userEntity = UserEntity.fromMap(mapWithNulls);

      expect(userEntity.firstName, equals(''));
      expect(userEntity.lastName, equals(''));
      expect(userEntity.phoneNumber, isNull);
    });

    test('UserEntity.fromMap should handle invalid date strings safely', () {
      final mapWithInvalidDates = {
        'id': 'test-id',
        'email': 'test@example.com',
        'firstName': 'John',
        'lastName': 'Doe',
        'phoneNumber': '+255123456789',
        'profileImageUrl': null,
        'isEmailVerified': true,
        'createdAt': 'invalid-date-string',
        'updatedAt': 'another-invalid-date',
        'role': 'customer',
        'status': 'active',
        'address': null,
        'preferences': null,
      };

      expect(() => UserEntity.fromMap(mapWithInvalidDates), returnsNormally);

      final userEntity = UserEntity.fromMap(mapWithInvalidDates);

      // Should use current time as fallback for invalid dates
      expect(userEntity.createdAt, isA<DateTime>());
      expect(userEntity.updatedAt, isA<DateTime>());
    });

    test('UserEntity.fromMap should handle malformed address data safely', () {
      final mapWithBadAddress = {
        'id': 'test-id',
        'email': 'test@example.com',
        'firstName': 'John',
        'lastName': 'Doe',
        'phoneNumber': '+255123456789',
        'profileImageUrl': null,
        'isEmailVerified': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'role': 'customer',
        'status': 'active',
        'address': 'invalid-address-format', // Should be a Map
        'preferences': 'invalid-preferences-format', // Should be a Map
      };

      expect(() => UserEntity.fromMap(mapWithBadAddress), returnsNormally);

      final userEntity = UserEntity.fromMap(mapWithBadAddress);

      // Should handle invalid address gracefully
      expect(userEntity.address, isNull);
      expect(userEntity.preferences, isNull);
    });

    test('UserEntity.fromMap should handle completely malformed data', () {
      final malformedMap = {
        'id': 123, // Should be string
        'email': ['test', '@', 'example.com'], // Should be string
        'firstName': {'name': 'John'}, // Should be string
        'lastName': true, // Should be string
        'phoneNumber': 255123456789, // Should be string
        'isEmailVerified': 'true', // Should be boolean
        'createdAt': 1234567890, // Should be string
        'updatedAt': null,
        'role': 'invalid-role',
        'status': 'invalid-status',
      };

      // Should not throw an error even with completely malformed data
      expect(() => UserEntity.fromMap(malformedMap), returnsNormally);

      final userEntity = UserEntity.fromMap(malformedMap);

      // Should have reasonable fallback values
      expect(userEntity.id, isA<String>());
      expect(userEntity.email, isA<String>());
      expect(userEntity.firstName, isA<String>());
      expect(userEntity.lastName, isA<String>());
      expect(userEntity.role, equals(UserRole.customer)); // Default role
      expect(userEntity.status, equals(UserStatus.active)); // Default status
    });

    test('Safe string extraction should handle various types', () {
      // Test the _safeString method behavior
      expect(
        UserEntity.fromMap({'id': 'string-value'}).id,
        equals('string-value'),
      );
      expect(
        UserEntity.fromMap({
          'id': ['list', 'value'],
        }).id,
        equals('list value'),
      );
      expect(UserEntity.fromMap({'id': 123}).id, equals('123'));
      expect(UserEntity.fromMap({'id': null}).id, equals(''));
      expect(UserEntity.fromMap({}).id, equals(''));
    });

    test('Address.fromMap should handle list type casting safely', () {
      // Test case that would previously cause "list of object is not sub type string" error
      final problematicAddressMap = {
        'street': [
          '123',
          'Main',
          'Street',
        ], // This could be a list instead of string
        'city': ['New', 'York'], // This could be a list instead of string
        'region': ['NY'], // This could be a list instead of string
        'postalCode': [1, 0, 0, 0, 1], // This could be a list of numbers
        'country': [
          'United',
          'States',
        ], // This could be a list instead of string
        'latitude': ['40.7128'], // This could be a list instead of number
        'longitude': ['-74.0060'], // This could be a list instead of number
      };

      // This should not throw an error
      expect(() => Address.fromMap(problematicAddressMap), returnsNormally);

      final address = Address.fromMap(problematicAddressMap);

      // Verify that lists are properly converted to strings
      expect(address.street, equals('123 Main Street'));
      expect(address.city, equals('New York'));
      expect(address.region, equals('NY'));
      expect(address.postalCode, equals('1 0 0 0 1'));
      expect(address.country, equals('United States'));
      expect(address.latitude, equals(40.7128));
      expect(address.longitude, equals(-74.0060));
    });

    test('Address.fromMap should handle null values safely', () {
      final mapWithNulls = {
        'street': null,
        'city': null,
        'region': null,
        'postalCode': null,
        'country': null,
        'latitude': null,
        'longitude': null,
      };

      expect(() => Address.fromMap(mapWithNulls), returnsNormally);

      final address = Address.fromMap(mapWithNulls);

      expect(address.street, equals(''));
      expect(address.city, equals(''));
      expect(address.region, equals(''));
      expect(address.postalCode, equals(''));
      expect(address.country, equals('Tanzania')); // Default value
      expect(address.latitude, isNull);
      expect(address.longitude, isNull);
    });

    test('Address.fromMap should handle malformed data gracefully', () {
      final malformedMap = {
        'street': 123, // Should be string
        'city': true, // Should be string
        'region': {'name': 'NY'}, // Should be string
        'postalCode': 10001.5, // Should be string
        'country': null,
        'latitude': 'invalid-number', // Should be number
        'longitude': {'value': -74.0060}, // Should be number
      };

      // Should not throw an error even with completely malformed data
      expect(() => Address.fromMap(malformedMap), returnsNormally);

      final address = Address.fromMap(malformedMap);

      // Should have reasonable fallback values
      expect(address.street, isA<String>());
      expect(address.city, isA<String>());
      expect(address.region, isA<String>());
      expect(address.postalCode, isA<String>());
      expect(address.country, equals('Tanzania')); // Default value
      expect(address.latitude, isNull); // Invalid number should be null
      expect(address.longitude, isNull); // Invalid number should be null
    });
  });
}
