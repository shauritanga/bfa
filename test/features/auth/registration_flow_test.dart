import 'package:flutter_test/flutter_test.dart';
import 'package:bfa/features/auth/domain/entities/user_entity.dart';

void main() {
  group('Registration Flow Tests', () {
    test('Registration user entity should be created with all required fields', () {
      // Simulate the exact data that would be created during registration
      final registrationData = {
        'email': 'test@example.com',
        'password': 'password123',
        'firstName': 'John',
        'lastName': 'Doe',
        'phoneNumber': '+255123456789',
        'address': '123 Main Street',
      };

      // Create user entity as it would be created in the auth service
      final userEntity = UserEntity(
        id: 'test-user-id',
        email: registrationData['email']!,
        firstName: registrationData['firstName']!,
        lastName: registrationData['lastName']!,
        phoneNumber: registrationData['phoneNumber'],
        profileImageUrl: null,
        isEmailVerified: false, // New users are not verified
        address: registrationData['address'] != null && registrationData['address']!.isNotEmpty
            ? Address(
                street: registrationData['address']!,
                city: '', // Will be filled later when user updates profile
                region: '',
                postalCode: '',
                country: 'Tanzania',
              )
            : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Verify the user entity is created correctly
      expect(userEntity.id, equals('test-user-id'));
      expect(userEntity.email, equals('test@example.com'));
      expect(userEntity.firstName, equals('John'));
      expect(userEntity.lastName, equals('Doe'));
      expect(userEntity.phoneNumber, equals('+255123456789'));
      expect(userEntity.isEmailVerified, isFalse);
      expect(userEntity.role, equals(UserRole.customer)); // Default role
      expect(userEntity.status, equals(UserStatus.active)); // Default status

      // Verify address is created correctly
      expect(userEntity.address, isNotNull);
      expect(userEntity.address!.street, equals('123 Main Street'));
      expect(userEntity.address!.city, equals(''));
      expect(userEntity.address!.region, equals(''));
      expect(userEntity.address!.postalCode, equals(''));
      expect(userEntity.address!.country, equals('Tanzania'));
    });

    test('Registration user entity should serialize to Firestore format correctly', () {
      // Create user entity with registration data
      final userEntity = UserEntity(
        id: 'test-user-id',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        phoneNumber: '+255123456789',
        profileImageUrl: null,
        isEmailVerified: false,
        address: const Address(
          street: '123 Main Street',
          city: '',
          region: '',
          postalCode: '',
          country: 'Tanzania',
        ),
        createdAt: DateTime(2024, 1, 15, 10, 30),
        updatedAt: DateTime(2024, 1, 15, 10, 30),
      );

      // Convert to Firestore format
      final firestoreData = userEntity.toMap();

      // Verify all registration fields are present in Firestore format
      expect(firestoreData['id'], equals('test-user-id'));
      expect(firestoreData['email'], equals('test@example.com'));
      expect(firestoreData['firstName'], equals('John'));
      expect(firestoreData['lastName'], equals('Doe'));
      expect(firestoreData['phoneNumber'], equals('+255123456789'));
      expect(firestoreData['profileImageUrl'], isNull);
      expect(firestoreData['isEmailVerified'], equals(false));
      expect(firestoreData['role'], equals('customer'));
      expect(firestoreData['status'], equals('active'));
      expect(firestoreData['createdAt'], equals('2024-01-15T10:30:00.000'));
      expect(firestoreData['updatedAt'], equals('2024-01-15T10:30:00.000'));

      // Verify address is properly serialized
      expect(firestoreData['address'], isA<Map<String, dynamic>>());
      final addressData = firestoreData['address'] as Map<String, dynamic>;
      expect(addressData['street'], equals('123 Main Street'));
      expect(addressData['city'], equals(''));
      expect(addressData['region'], equals(''));
      expect(addressData['postalCode'], equals(''));
      expect(addressData['country'], equals('Tanzania'));
      expect(addressData['latitude'], isNull);
      expect(addressData['longitude'], isNull);

      // Verify preferences is null for new users
      expect(firestoreData['preferences'], isNull);
    });

    test('Registration with minimal data should work correctly', () {
      // Test registration with only required fields
      final userEntity = UserEntity(
        id: 'minimal-user-id',
        email: 'minimal@example.com',
        firstName: 'Jane',
        lastName: 'Smith',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        // phoneNumber, address, etc. are null
      );

      // Should serialize without errors
      expect(() => userEntity.toMap(), returnsNormally);

      final firestoreData = userEntity.toMap();

      // Verify required fields are present
      expect(firestoreData['id'], equals('minimal-user-id'));
      expect(firestoreData['email'], equals('minimal@example.com'));
      expect(firestoreData['firstName'], equals('Jane'));
      expect(firestoreData['lastName'], equals('Smith'));
      expect(firestoreData['isEmailVerified'], equals(false));
      expect(firestoreData['role'], equals('customer'));
      expect(firestoreData['status'], equals('active'));

      // Verify optional fields are null
      expect(firestoreData['phoneNumber'], isNull);
      expect(firestoreData['profileImageUrl'], isNull);
      expect(firestoreData['address'], isNull);
      expect(firestoreData['preferences'], isNull);
    });

    test('Registration data should be retrievable from Firestore format', () {
      // Simulate data as it would be stored in Firestore
      final firestoreData = {
        'id': 'test-user-id',
        'email': 'test@example.com',
        'firstName': 'John',
        'lastName': 'Doe',
        'phoneNumber': '+255123456789',
        'profileImageUrl': null,
        'isEmailVerified': false,
        'createdAt': '2024-01-15T10:30:00.000',
        'updatedAt': '2024-01-15T10:30:00.000',
        'role': 'customer',
        'status': 'active',
        'address': {
          'street': '123 Main Street',
          'city': '',
          'region': '',
          'postalCode': '',
          'country': 'Tanzania',
          'latitude': null,
          'longitude': null,
        },
        'preferences': null,
      };

      // Should deserialize without errors
      expect(() => UserEntity.fromMap(firestoreData), returnsNormally);

      final userEntity = UserEntity.fromMap(firestoreData);

      // Verify all fields are correctly retrieved
      expect(userEntity.id, equals('test-user-id'));
      expect(userEntity.email, equals('test@example.com'));
      expect(userEntity.firstName, equals('John'));
      expect(userEntity.lastName, equals('Doe'));
      expect(userEntity.phoneNumber, equals('+255123456789'));
      expect(userEntity.profileImageUrl, isNull);
      expect(userEntity.isEmailVerified, equals(false));
      expect(userEntity.role, equals(UserRole.customer));
      expect(userEntity.status, equals(UserStatus.active));

      // Verify address is correctly retrieved
      expect(userEntity.address, isNotNull);
      expect(userEntity.address!.street, equals('123 Main Street'));
      expect(userEntity.address!.city, equals(''));
      expect(userEntity.address!.region, equals(''));
      expect(userEntity.address!.postalCode, equals(''));
      expect(userEntity.address!.country, equals('Tanzania'));
      expect(userEntity.address!.latitude, isNull);
      expect(userEntity.address!.longitude, isNull);

      // Verify preferences is null
      expect(userEntity.preferences, isNull);
    });

    test('Registration should handle edge cases in field values', () {
      // Test with edge case values that might cause issues
      final userEntity = UserEntity(
        id: 'edge-case-user',
        email: 'edge.case+test@example.com',
        firstName: 'José María',
        lastName: 'García-López',
        phoneNumber: '+255 123 456 789',
        address: const Address(
          street: 'Apt 5B, 123 Main St.',
          city: 'Dar es Salaam',
          region: 'Dar es Salaam Region',
          postalCode: '12345-6789',
          country: 'United Republic of Tanzania',
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Should handle special characters and formatting
      expect(() => userEntity.toMap(), returnsNormally);

      final firestoreData = userEntity.toMap();
      
      // Should be able to deserialize back
      expect(() => UserEntity.fromMap(firestoreData), returnsNormally);

      final reconstructed = UserEntity.fromMap(firestoreData);

      // Verify special characters are preserved
      expect(reconstructed.firstName, equals('José María'));
      expect(reconstructed.lastName, equals('García-López'));
      expect(reconstructed.email, equals('edge.case+test@example.com'));
      expect(reconstructed.phoneNumber, equals('+255 123 456 789'));
      expect(reconstructed.address!.street, equals('Apt 5B, 123 Main St.'));
      expect(reconstructed.address!.country, equals('United Republic of Tanzania'));
    });
  });
}
