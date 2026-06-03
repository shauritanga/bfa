import 'package:flutter_test/flutter_test.dart';
import 'package:bfa/features/auth/domain/entities/user_entity.dart';

void main() {
  group('Registration Debug Tests', () {
    test('UserEntity should serialize all fields correctly', () {
      // Test that UserEntity.toMap() includes all the fields from registration
      final testUser = UserEntity(
        id: 'test-user-123',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        phoneNumber: '+255123456789',
        isEmailVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        address: Address(
          street: '123 Main Street, Dar es Salaam',
          city: '',
          region: '',
          postalCode: '',
          country: 'Tanzania',
        ),
      );

      final userMap = testUser.toMap();

      // Debug: Print the map to see what's being serialized
      print('UserEntity.toMap() result:');
      userMap.forEach((key, value) {
        print('  $key: $value (${value.runtimeType})');
      });

      // Verify all expected fields are present
      expect(userMap['id'], equals('test-user-123'));
      expect(userMap['email'], equals('test@example.com'));
      expect(userMap['firstName'], equals('John'));
      expect(userMap['lastName'], equals('Doe'));
      expect(userMap['phoneNumber'], equals('+255123456789'));
      expect(userMap['isEmailVerified'], equals(false));
      expect(userMap['role'], equals('customer'));
      expect(userMap['status'], equals('active'));
      
      // Check address serialization
      expect(userMap['address'], isNotNull);
      expect(userMap['address'], isA<Map<String, dynamic>>());
      
      final addressMap = userMap['address'] as Map<String, dynamic>;
      expect(addressMap['street'], equals('123 Main Street, Dar es Salaam'));
      expect(addressMap['country'], equals('Tanzania'));
    });

    test('Address should serialize correctly', () {
      final address = Address(
        street: '456 Test Street',
        city: 'Arusha',
        region: 'Arusha',
        postalCode: '12345',
        country: 'Tanzania',
      );

      final addressMap = address.toMap();

      print('Address.toMap() result:');
      addressMap.forEach((key, value) {
        print('  $key: $value');
      });

      expect(addressMap['street'], equals('456 Test Street'));
      expect(addressMap['city'], equals('Arusha'));
      expect(addressMap['region'], equals('Arusha'));
      expect(addressMap['postalCode'], equals('12345'));
      expect(addressMap['country'], equals('Tanzania'));
      expect(addressMap['latitude'], isNull);
      expect(addressMap['longitude'], isNull);
    });

    test('UserEntity should handle null address correctly', () {
      final testUser = UserEntity(
        id: 'test-user-no-address',
        email: 'noaddress@example.com',
        firstName: 'Jane',
        lastName: 'Smith',
        phoneNumber: null,
        isEmailVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        address: null, // No address provided
      );

      final userMap = testUser.toMap();

      print('UserEntity.toMap() with null address:');
      userMap.forEach((key, value) {
        print('  $key: $value');
      });

      expect(userMap['id'], equals('test-user-no-address'));
      expect(userMap['email'], equals('noaddress@example.com'));
      expect(userMap['firstName'], equals('Jane'));
      expect(userMap['lastName'], equals('Smith'));
      expect(userMap['phoneNumber'], isNull);
      expect(userMap['address'], isNull);
    });

    test('UserEntity should handle empty string fields correctly', () {
      final testUser = UserEntity(
        id: 'test-user-empty',
        email: 'empty@example.com',
        firstName: '', // Empty first name
        lastName: '', // Empty last name
        phoneNumber: '', // Empty phone number
        isEmailVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        address: null,
      );

      final userMap = testUser.toMap();

      print('UserEntity.toMap() with empty strings:');
      userMap.forEach((key, value) {
        print('  $key: $value');
      });

      expect(userMap['firstName'], equals(''));
      expect(userMap['lastName'], equals(''));
      expect(userMap['phoneNumber'], equals(''));
    });

    test('Registration data flow should work correctly', () {
      // Simulate the exact data flow from registration form
      
      // 1. Form data (what comes from the UI)
      final formData = {
        'email': 'register@example.com',
        'password': 'password123',
        'firstName': 'Registration',
        'lastName': 'Test',
        'phoneNumber': '+255987654321',
        'address': 'Mwanza, Tanzania',
      };

      print('Form data:');
      formData.forEach((key, value) {
        print('  $key: $value');
      });

      // 2. Address conversion (what happens in auth service)
      Address? addressObject;
      if (formData['address'] != null && formData['address']!.isNotEmpty) {
        addressObject = Address(
          street: formData['address']!,
          city: '',
          region: '',
          postalCode: '',
          country: 'Tanzania',
        );
      }

      print('Address object created: ${addressObject?.toMap()}');

      // 3. UserEntity creation (what happens in auth service)
      final userEntity = UserEntity(
        id: 'registration-test-user',
        email: formData['email']!,
        firstName: formData['firstName']!,
        lastName: formData['lastName']!,
        phoneNumber: formData['phoneNumber'],
        isEmailVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        address: addressObject,
      );

      print('UserEntity created: ${userEntity.toMap()}');

      // 4. Verify all data is preserved
      final userMap = userEntity.toMap();
      expect(userMap['email'], equals('register@example.com'));
      expect(userMap['firstName'], equals('Registration'));
      expect(userMap['lastName'], equals('Test'));
      expect(userMap['phoneNumber'], equals('+255987654321'));
      
      expect(userMap['address'], isNotNull);
      final savedAddress = userMap['address'] as Map<String, dynamic>;
      expect(savedAddress['street'], equals('Mwanza, Tanzania'));
      expect(savedAddress['country'], equals('Tanzania'));
    });

    test('UserEntity fromMap should recreate object correctly', () {
      // Test the round-trip: toMap -> fromMap
      final originalUser = UserEntity(
        id: 'roundtrip-test',
        email: 'roundtrip@example.com',
        firstName: 'Round',
        lastName: 'Trip',
        phoneNumber: '+255111222333',
        isEmailVerified: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        address: Address(
          street: 'Round Trip Street',
          city: 'Dodoma',
          region: 'Dodoma',
          postalCode: '54321',
          country: 'Tanzania',
        ),
      );

      // Convert to map (what gets saved to Firestore)
      final userMap = originalUser.toMap();
      print('Original user map: $userMap');

      // Convert back from map (what gets loaded from Firestore)
      final recreatedUser = UserEntity.fromMap(userMap);

      // Verify all fields are preserved
      expect(recreatedUser.id, equals(originalUser.id));
      expect(recreatedUser.email, equals(originalUser.email));
      expect(recreatedUser.firstName, equals(originalUser.firstName));
      expect(recreatedUser.lastName, equals(originalUser.lastName));
      expect(recreatedUser.phoneNumber, equals(originalUser.phoneNumber));
      expect(recreatedUser.isEmailVerified, equals(originalUser.isEmailVerified));
      expect(recreatedUser.role, equals(originalUser.role));
      expect(recreatedUser.status, equals(originalUser.status));
      
      // Verify address is preserved
      expect(recreatedUser.address, isNotNull);
      expect(recreatedUser.address!.street, equals(originalUser.address!.street));
      expect(recreatedUser.address!.city, equals(originalUser.address!.city));
      expect(recreatedUser.address!.country, equals(originalUser.address!.country));
    });

    test('Registration should handle all edge cases', () {
      // Test various edge cases that might occur during registration
      
      // Case 1: Minimal data (only required fields)
      final minimalUser = UserEntity(
        id: 'minimal-user',
        email: 'minimal@example.com',
        firstName: 'Min',
        lastName: 'User',
        isEmailVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final minimalMap = minimalUser.toMap();
      expect(minimalMap['phoneNumber'], isNull);
      expect(minimalMap['address'], isNull);
      expect(minimalMap['profileImageUrl'], isNull);

      // Case 2: Maximum data (all fields filled)
      final maximalUser = UserEntity(
        id: 'maximal-user',
        email: 'maximal@example.com',
        firstName: 'Max',
        lastName: 'User',
        phoneNumber: '+255999888777',
        profileImageUrl: 'https://example.com/profile.jpg',
        isEmailVerified: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        role: UserRole.farmer,
        status: UserStatus.active,
        address: Address(
          street: 'Maximal Street 123',
          city: 'Mbeya',
          region: 'Mbeya',
          postalCode: '99999',
          country: 'Tanzania',
          latitude: -8.9094,
          longitude: 33.4607,
        ),
        preferences: {
          'notifications': true,
          'language': 'sw',
          'currency': 'TZS',
        },
      );

      final maximalMap = maximalUser.toMap();
      expect(maximalMap['phoneNumber'], equals('+255999888777'));
      expect(maximalMap['profileImageUrl'], equals('https://example.com/profile.jpg'));
      expect(maximalMap['role'], equals('farmer'));
      expect(maximalMap['status'], equals('active'));
      expect(maximalMap['address'], isNotNull);
      expect(maximalMap['preferences'], isNotNull);
    });
  });
}
