import 'package:flutter_test/flutter_test.dart';
import 'package:bfa/features/auth/domain/entities/user_entity.dart';

void main() {
  group('UserEntity Serialization Tests', () {
    test('UserEntity.toMap should include all fields correctly', () {
      // Create a user entity with all fields populated
      final userEntity = UserEntity(
        id: 'test-user-id',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        phoneNumber: '+255123456789',
        profileImageUrl: 'https://example.com/profile.jpg',
        isEmailVerified: true,
        createdAt: DateTime(2024, 1, 15, 10, 30),
        updatedAt: DateTime(2024, 1, 15, 10, 30),
        role: UserRole.customer,
        status: UserStatus.active,
        address: const Address(
          street: '123 Main Street',
          city: 'Dar es Salaam',
          region: 'Dar es Salaam',
          postalCode: '12345',
          country: 'Tanzania',
          latitude: -6.7924,
          longitude: 39.2083,
        ),
        preferences: {
          'language': 'en',
          'currency': 'TZS',
          'notifications': true,
        },
      );

      // Convert to map
      final map = userEntity.toMap();

      // Verify all fields are present and correct
      expect(map['id'], equals('test-user-id'));
      expect(map['email'], equals('test@example.com'));
      expect(map['firstName'], equals('John'));
      expect(map['lastName'], equals('Doe'));
      expect(map['phoneNumber'], equals('+255123456789'));
      expect(map['profileImageUrl'], equals('https://example.com/profile.jpg'));
      expect(map['isEmailVerified'], equals(true));
      expect(map['createdAt'], equals('2024-01-15T10:30:00.000'));
      expect(map['updatedAt'], equals('2024-01-15T10:30:00.000'));
      expect(map['role'], equals('customer'));
      expect(map['status'], equals('active'));
      
      // Verify address is properly serialized
      expect(map['address'], isA<Map<String, dynamic>>());
      final addressMap = map['address'] as Map<String, dynamic>;
      expect(addressMap['street'], equals('123 Main Street'));
      expect(addressMap['city'], equals('Dar es Salaam'));
      expect(addressMap['region'], equals('Dar es Salaam'));
      expect(addressMap['postalCode'], equals('12345'));
      expect(addressMap['country'], equals('Tanzania'));
      expect(addressMap['latitude'], equals(-6.7924));
      expect(addressMap['longitude'], equals(39.2083));
      
      // Verify preferences are properly serialized
      expect(map['preferences'], isA<Map<String, dynamic>>());
      final preferencesMap = map['preferences'] as Map<String, dynamic>;
      expect(preferencesMap['language'], equals('en'));
      expect(preferencesMap['currency'], equals('TZS'));
      expect(preferencesMap['notifications'], equals(true));
    });

    test('UserEntity.toMap should handle null optional fields correctly', () {
      // Create a user entity with minimal required fields
      final userEntity = UserEntity(
        id: 'test-user-id',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        createdAt: DateTime(2024, 1, 15, 10, 30),
        updatedAt: DateTime(2024, 1, 15, 10, 30),
        // phoneNumber, profileImageUrl, address, preferences are null
      );

      // Convert to map
      final map = userEntity.toMap();

      // Verify required fields are present
      expect(map['id'], equals('test-user-id'));
      expect(map['email'], equals('test@example.com'));
      expect(map['firstName'], equals('John'));
      expect(map['lastName'], equals('Doe'));
      expect(map['isEmailVerified'], equals(false)); // Default value
      expect(map['role'], equals('customer')); // Default value
      expect(map['status'], equals('active')); // Default value
      
      // Verify optional fields are null
      expect(map['phoneNumber'], isNull);
      expect(map['profileImageUrl'], isNull);
      expect(map['address'], isNull);
      expect(map['preferences'], isNull);
    });

    test('UserEntity roundtrip (toMap -> fromMap) should preserve data', () {
      // Create original user entity
      final originalUser = UserEntity(
        id: 'test-user-id',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        phoneNumber: '+255123456789',
        profileImageUrl: 'https://example.com/profile.jpg',
        isEmailVerified: true,
        createdAt: DateTime(2024, 1, 15, 10, 30),
        updatedAt: DateTime(2024, 1, 15, 10, 30),
        role: UserRole.farmer,
        status: UserStatus.active,
        address: const Address(
          street: '123 Main Street',
          city: 'Dar es Salaam',
          region: 'Dar es Salaam',
          postalCode: '12345',
          country: 'Tanzania',
        ),
        preferences: {
          'language': 'sw',
          'currency': 'TZS',
        },
      );

      // Convert to map and back
      final map = originalUser.toMap();
      final reconstructedUser = UserEntity.fromMap(map);

      // Verify all fields are preserved
      expect(reconstructedUser.id, equals(originalUser.id));
      expect(reconstructedUser.email, equals(originalUser.email));
      expect(reconstructedUser.firstName, equals(originalUser.firstName));
      expect(reconstructedUser.lastName, equals(originalUser.lastName));
      expect(reconstructedUser.phoneNumber, equals(originalUser.phoneNumber));
      expect(reconstructedUser.profileImageUrl, equals(originalUser.profileImageUrl));
      expect(reconstructedUser.isEmailVerified, equals(originalUser.isEmailVerified));
      expect(reconstructedUser.role, equals(originalUser.role));
      expect(reconstructedUser.status, equals(originalUser.status));
      
      // Verify address is preserved
      expect(reconstructedUser.address?.street, equals(originalUser.address?.street));
      expect(reconstructedUser.address?.city, equals(originalUser.address?.city));
      expect(reconstructedUser.address?.region, equals(originalUser.address?.region));
      expect(reconstructedUser.address?.postalCode, equals(originalUser.address?.postalCode));
      expect(reconstructedUser.address?.country, equals(originalUser.address?.country));
      
      // Verify preferences are preserved
      expect(reconstructedUser.preferences?['language'], equals('sw'));
      expect(reconstructedUser.preferences?['currency'], equals('TZS'));
    });

    test('Address.toMap should include all fields correctly', () {
      const address = Address(
        street: '123 Main Street',
        city: 'Dar es Salaam',
        region: 'Dar es Salaam',
        postalCode: '12345',
        country: 'Tanzania',
        latitude: -6.7924,
        longitude: 39.2083,
      );

      final map = address.toMap();

      expect(map['street'], equals('123 Main Street'));
      expect(map['city'], equals('Dar es Salaam'));
      expect(map['region'], equals('Dar es Salaam'));
      expect(map['postalCode'], equals('12345'));
      expect(map['country'], equals('Tanzania'));
      expect(map['latitude'], equals(-6.7924));
      expect(map['longitude'], equals(39.2083));
    });

    test('Registration data should serialize correctly', () {
      // Simulate registration data
      final registrationUser = UserEntity(
        id: 'new-user-123',
        email: 'newuser@example.com',
        firstName: 'Jane',
        lastName: 'Smith',
        phoneNumber: '+255987654321',
        isEmailVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        address: const Address(
          street: '456 Oak Avenue',
          city: '', // Empty as per registration logic
          region: '',
          postalCode: '',
          country: 'Tanzania',
        ),
      );

      // This should not throw any errors
      expect(() => registrationUser.toMap(), returnsNormally);

      final map = registrationUser.toMap();

      // Verify registration-specific data
      expect(map['firstName'], equals('Jane'));
      expect(map['lastName'], equals('Smith'));
      expect(map['phoneNumber'], equals('+255987654321'));
      expect(map['isEmailVerified'], equals(false));
      
      // Verify address structure
      expect(map['address'], isA<Map<String, dynamic>>());
      final addressMap = map['address'] as Map<String, dynamic>;
      expect(addressMap['street'], equals('456 Oak Avenue'));
      expect(addressMap['country'], equals('Tanzania'));
    });
  });
}
