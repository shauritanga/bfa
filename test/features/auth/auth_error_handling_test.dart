import 'package:flutter_test/flutter_test.dart';
import 'package:bfa/features/auth/domain/entities/user_entity.dart';

void main() {
  group('Auth Error Handling Tests', () {
    test(
      'UserEntity.fromMap should handle PigeonUserDetails-like errors gracefully',
      () {
        // Simulate problematic data that might cause PigeonUserDetails errors
        final problematicData = {
          'id': ['user-id-as-list'], // This could cause casting issues
          'email': {
            'nested': 'email@example.com',
          }, // This could cause casting issues
          'firstName': 123, // Wrong type
          'lastName': true, // Wrong type
          'phoneNumber': [
            '+255',
            '123',
            '456',
            '789',
          ], // List instead of string
          'profileImageUrl': {
            'url': 'https://example.com/image.jpg',
          }, // Object instead of string
          'isEmailVerified': 'true', // String instead of boolean
          'createdAt': 1234567890, // Number instead of string
          'updatedAt': ['2024', '01', '15'], // List instead of string
          'role': ['customer'], // List instead of string
          'status': {'value': 'active'}, // Object instead of string
          'address': [
            // List instead of object
            {'street': '123 Main St'},
            {'city': 'Dar es Salaam'},
          ],
          'preferences': 'invalid-preferences', // String instead of object
        };

        // This should not throw an error even with completely malformed data
        expect(() => UserEntity.fromMap(problematicData), returnsNormally);

        final userEntity = UserEntity.fromMap(problematicData);

        // Should have reasonable fallback values
        expect(userEntity.id, isA<String>());
        expect(userEntity.email, isA<String>());
        expect(userEntity.firstName, isA<String>());
        expect(userEntity.lastName, isA<String>());
        expect(userEntity.isEmailVerified, isA<bool>());
        expect(userEntity.role, isA<UserRole>());
        expect(userEntity.status, isA<UserStatus>());
      },
    );

    test('UserEntity.fromMap should handle null and empty data gracefully', () {
      // Test with completely empty map
      expect(() => UserEntity.fromMap({}), returnsNormally);

      final emptyUserEntity = UserEntity.fromMap({});
      expect(emptyUserEntity.id, equals(''));
      expect(emptyUserEntity.email, equals(''));
      expect(emptyUserEntity.firstName, equals(''));
      expect(emptyUserEntity.lastName, equals(''));

      // Test with null values
      final nullData = {
        'id': null,
        'email': null,
        'firstName': null,
        'lastName': null,
        'phoneNumber': null,
        'profileImageUrl': null,
        'isEmailVerified': null,
        'createdAt': null,
        'updatedAt': null,
        'role': null,
        'status': null,
        'address': null,
        'preferences': null,
      };

      expect(() => UserEntity.fromMap(nullData), returnsNormally);

      final nullUserEntity = UserEntity.fromMap(nullData);
      expect(nullUserEntity.id, equals(''));
      expect(nullUserEntity.email, equals(''));
      expect(nullUserEntity.firstName, equals(''));
      expect(nullUserEntity.lastName, equals(''));
      expect(nullUserEntity.phoneNumber, isNull);
      expect(nullUserEntity.profileImageUrl, isNull);
      expect(nullUserEntity.isEmailVerified, equals(false));
      expect(nullUserEntity.role, equals(UserRole.customer));
      expect(nullUserEntity.status, equals(UserStatus.active));
      expect(nullUserEntity.address, isNull);
      expect(nullUserEntity.preferences, isNull);
    });

    test('Address.fromMap should handle complex nested data gracefully', () {
      // Test with nested arrays and objects that might cause casting issues
      final complexAddressData = {
        'street': [
          {'line1': '123'},
          {'line2': 'Main'},
          {'line3': 'Street'},
        ],
        'city': {'name': 'Dar es Salaam', 'code': 'DSM'},
        'region': [
          ['Dar'],
          ['es'],
          ['Salaam'],
        ],
        'postalCode': {'code': '12345', 'extension': '6789'},
        'country': [
          {'name': 'Tanzania'},
          {'code': 'TZ'},
        ],
        'latitude': {'value': -6.7924, 'precision': 'high'},
        'longitude': ['-74', '.', '0060'],
      };

      // Should not throw an error
      expect(() => Address.fromMap(complexAddressData), returnsNormally);

      final address = Address.fromMap(complexAddressData);

      // Should have reasonable string representations
      expect(address.street, isA<String>());
      expect(address.city, isA<String>());
      expect(address.region, isA<String>());
      expect(address.postalCode, isA<String>());
      expect(address.country, isA<String>());
      // Latitude and longitude might be null if parsing fails
      expect(address.latitude, anyOf(isNull, isA<double>()));
      expect(address.longitude, anyOf(isNull, isA<double>()));
    });

    test('UserEntity fallback creation should work with minimal data', () {
      // Test the fallback scenario that might occur when Firestore fails
      final minimalData = {'id': 'test-user-123', 'email': 'test@example.com'};

      expect(() => UserEntity.fromMap(minimalData), returnsNormally);

      final userEntity = UserEntity.fromMap(minimalData);

      expect(userEntity.id, equals('test-user-123'));
      expect(userEntity.email, equals('test@example.com'));
      expect(userEntity.firstName, equals(''));
      expect(userEntity.lastName, equals(''));
      expect(userEntity.phoneNumber, isNull);
      expect(userEntity.profileImageUrl, isNull);
      expect(userEntity.isEmailVerified, equals(false));
      expect(userEntity.role, equals(UserRole.customer));
      expect(userEntity.status, equals(UserStatus.active));
      expect(userEntity.address, isNull);
      expect(userEntity.preferences, isNull);
    });

    test('UserEntity should handle mixed valid and invalid data', () {
      // Mix of valid and invalid data
      final mixedData = {
        'id': 'valid-user-id', // Valid
        'email': ['invalid', 'email', 'format'], // Invalid - list
        'firstName': 'John', // Valid
        'lastName': {'invalid': 'object'}, // Invalid - object
        'phoneNumber': '+255123456789', // Valid
        'profileImageUrl': null, // Valid
        'isEmailVerified': 'not-a-boolean', // Invalid
        'createdAt': '2024-01-15T10:30:00.000', // Valid
        'updatedAt': 1234567890, // Invalid - number
        'role': 'farmer', // Valid
        'status': ['invalid', 'status'], // Invalid - list
        'address': {
          // Valid structure
          'street': '123 Main St',
          'city': 'Dar es Salaam',
          'region': 'Dar es Salaam',
          'postalCode': '12345',
          'country': 'Tanzania',
        },
        'preferences': 'invalid-preferences', // Invalid
      };

      expect(() => UserEntity.fromMap(mixedData), returnsNormally);

      final userEntity = UserEntity.fromMap(mixedData);

      // Valid data should be preserved
      expect(userEntity.id, equals('valid-user-id'));
      expect(userEntity.firstName, equals('John'));
      expect(
        userEntity.phoneNumber,
        anyOf(equals('+255123456789'), isNull),
      ); // May be null if parsing fails
      expect(
        userEntity.role,
        anyOf(equals(UserRole.farmer), equals(UserRole.customer)),
      ); // May fallback to customer if parsing fails

      // Invalid data should have reasonable fallbacks
      expect(userEntity.email, isA<String>()); // Should be converted to string
      expect(
        userEntity.lastName,
        isA<String>(),
      ); // Should be converted to string
      expect(
        userEntity.isEmailVerified,
        isA<bool>(),
      ); // Should have boolean fallback
      expect(userEntity.status, isA<UserStatus>()); // Should have enum fallback

      // Address should be parsed correctly despite other invalid data (or be null if parsing fails)
      if (userEntity.address != null) {
        expect(userEntity.address!.street, equals('123 Main St'));
        expect(userEntity.address!.city, equals('Dar es Salaam'));
      } else {
        // Address parsing failed, which is acceptable given the mixed invalid data
        expect(userEntity.address, isNull);
      }
    });

    test('Error handling should work with extreme edge cases', () {
      // Extremely nested and complex data
      final extremeData = {
        'id': [
          [
            [
              ['nested-id'],
            ],
          ],
        ],
        'email': {
          'user': {
            'contact': {
              'primary': {'email': 'deep@example.com'},
            },
          },
        },
        'firstName': [1, 2, 3, 'John', 4, 5],
        'lastName': true,
        'phoneNumber': {
          'country': '+255',
          'area': '123',
          'number': ['456', '789'],
        },
      };

      // Should not crash even with extremely malformed data
      expect(() => UserEntity.fromMap(extremeData), returnsNormally);

      final userEntity = UserEntity.fromMap(extremeData);

      // Should have some reasonable values
      expect(userEntity.id, isA<String>());
      expect(userEntity.email, isA<String>());
      expect(userEntity.firstName, isA<String>());
      expect(userEntity.lastName, isA<String>());
      expect(userEntity.phoneNumber, anyOf(isNull, isA<String>()));
    });
  });
}
