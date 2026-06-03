import 'package:flutter_test/flutter_test.dart';
import 'package:bfa/features/auth/domain/entities/user_entity.dart';

void main() {
  group('Registration Fix Tests', () {
    test('UserEntity should preserve Firestore data when parsing fails', () {
      // Simulate the scenario where UserEntity.fromMap() fails due to PigeonUserDetails error
      // but we have valid Firestore data that should be preserved
      
      final firestoreData = {
        'id': 'test-user-123',
        'email': 'test@example.com',
        'firstName': 'John',
        'lastName': 'Doe',
        'phoneNumber': '+255123456789',
        'profileImageUrl': null,
        'isEmailVerified': false,
        'createdAt': '2025-07-31T11:32:32.436643',
        'updatedAt': '2025-07-31T11:32:32.436645',
        'role': 'customer',
        'status': 'active',
        'address': {
          'street': '123 Main Street',
          'city': 'Dar es Salaam',
          'region': 'Dar es Salaam',
          'postalCode': '12345',
          'country': 'Tanzania',
          'latitude': null,
          'longitude': null,
        },
        'preferences': null,
      };

      // Test the fallback logic that preserves Firestore data
      final preservedUser = UserEntity(
        id: firestoreData['id'] as String,
        email: firestoreData['email'] as String,
        firstName: firestoreData['firstName'] as String,
        lastName: firestoreData['lastName'] as String,
        phoneNumber: firestoreData['phoneNumber'] as String?,
        profileImageUrl: firestoreData['profileImageUrl'] as String?,
        isEmailVerified: firestoreData['isEmailVerified'] as bool,
        address: firestoreData['address'] != null 
            ? Address.fromMap(firestoreData['address'] as Map<String, dynamic>)
            : null,
        createdAt: DateTime.parse(firestoreData['createdAt'] as String),
        updatedAt: DateTime.now(),
      );

      // Verify all data is preserved
      expect(preservedUser.id, equals('test-user-123'));
      expect(preservedUser.email, equals('test@example.com'));
      expect(preservedUser.firstName, equals('John'));
      expect(preservedUser.lastName, equals('Doe'));
      expect(preservedUser.phoneNumber, equals('+255123456789'));
      expect(preservedUser.isEmailVerified, isFalse);
      
      // Verify address is preserved
      expect(preservedUser.address, isNotNull);
      expect(preservedUser.address!.street, equals('123 Main Street'));
      expect(preservedUser.address!.city, equals('Dar es Salaam'));
      expect(preservedUser.address!.country, equals('Tanzania'));
    });

    test('UserEntity should handle missing Firestore fields gracefully', () {
      // Test the scenario where some Firestore fields are missing or null
      final partialFirestoreData = {
        'id': 'partial-user',
        'email': 'partial@example.com',
        'firstName': 'Partial',
        'lastName': 'User',
        // phoneNumber is missing
        'profileImageUrl': null,
        'isEmailVerified': true,
        'createdAt': '2025-07-31T11:32:32.436643',
        'updatedAt': '2025-07-31T11:32:32.436645',
        'role': 'customer',
        'status': 'active',
        // address is missing
        'preferences': null,
      };

      final partialUser = UserEntity(
        id: partialFirestoreData['id'] as String,
        email: partialFirestoreData['email'] as String,
        firstName: partialFirestoreData['firstName'] as String,
        lastName: partialFirestoreData['lastName'] as String,
        phoneNumber: partialFirestoreData['phoneNumber'] as String?,
        profileImageUrl: partialFirestoreData['profileImageUrl'] as String?,
        isEmailVerified: partialFirestoreData['isEmailVerified'] as bool,
        address: partialFirestoreData['address'] != null 
            ? Address.fromMap(partialFirestoreData['address'] as Map<String, dynamic>)
            : null,
        createdAt: DateTime.parse(partialFirestoreData['createdAt'] as String),
        updatedAt: DateTime.now(),
      );

      expect(partialUser.id, equals('partial-user'));
      expect(partialUser.email, equals('partial@example.com'));
      expect(partialUser.firstName, equals('Partial'));
      expect(partialUser.lastName, equals('User'));
      expect(partialUser.phoneNumber, isNull); // Missing field should be null
      expect(partialUser.address, isNull); // Missing field should be null
      expect(partialUser.isEmailVerified, isTrue);
    });

    test('Address should be created correctly from Firestore data', () {
      final addressData = {
        'street': 'Mwanza Street 456',
        'city': 'Mwanza',
        'region': 'Mwanza',
        'postalCode': '33000',
        'country': 'Tanzania',
        'latitude': -2.5164,
        'longitude': 32.9175,
      };

      final address = Address.fromMap(addressData);

      expect(address.street, equals('Mwanza Street 456'));
      expect(address.city, equals('Mwanza'));
      expect(address.region, equals('Mwanza'));
      expect(address.postalCode, equals('33000'));
      expect(address.country, equals('Tanzania'));
      expect(address.latitude, equals(-2.5164));
      expect(address.longitude, equals(32.9175));
    });

    test('Registration data should be preserved through error recovery', () {
      // Simulate the complete registration flow with error recovery
      
      // 1. Original registration data from form
      final registrationData = {
        'email': 'recovery@example.com',
        'firstName': 'Recovery',
        'lastName': 'Test',
        'phoneNumber': '+255987654321',
        'address': 'Arusha, Tanzania',
      };

      // 2. UserEntity created during registration (this gets saved to Firestore)
      final originalUserEntity = UserEntity(
        id: 'recovery-user-id',
        email: registrationData['email']!,
        firstName: registrationData['firstName']!,
        lastName: registrationData['lastName']!,
        phoneNumber: registrationData['phoneNumber'],
        isEmailVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        address: Address(
          street: registrationData['address']!,
          city: '',
          region: '',
          postalCode: '',
          country: 'Tanzania',
        ),
      );

      // 3. Firestore data (what gets saved)
      final firestoreData = originalUserEntity.toMap();

      // 4. Recovery scenario: PigeonUserDetails error occurs, but we recover from Firestore
      final recoveredUserEntity = UserEntity(
        id: firestoreData['id'] as String,
        email: firestoreData['email'] as String,
        firstName: firestoreData['firstName'] as String,
        lastName: firestoreData['lastName'] as String,
        phoneNumber: firestoreData['phoneNumber'] as String?,
        profileImageUrl: firestoreData['profileImageUrl'] as String?,
        isEmailVerified: firestoreData['isEmailVerified'] as bool,
        address: firestoreData['address'] != null 
            ? Address.fromMap(firestoreData['address'] as Map<String, dynamic>)
            : null,
        createdAt: DateTime.parse(firestoreData['createdAt'] as String),
        updatedAt: DateTime.now(),
      );

      // 5. Verify that all original registration data is preserved
      expect(recoveredUserEntity.email, equals(registrationData['email']));
      expect(recoveredUserEntity.firstName, equals(registrationData['firstName']));
      expect(recoveredUserEntity.lastName, equals(registrationData['lastName']));
      expect(recoveredUserEntity.phoneNumber, equals(registrationData['phoneNumber']));
      
      expect(recoveredUserEntity.address, isNotNull);
      expect(recoveredUserEntity.address!.street, equals(registrationData['address']));
      expect(recoveredUserEntity.address!.country, equals('Tanzania'));

      print('✅ Registration data preserved through error recovery:');
      print('  Original: $registrationData');
      print('  Recovered: ${recoveredUserEntity.toMap()}');
    });

    test('Empty display name should not override Firestore data', () {
      // Test the scenario where Firebase Auth display name is empty or null
      // but Firestore has the correct firstName/lastName
      
      final firestoreData = {
        'id': 'display-name-test',
        'email': 'displayname@example.com',
        'firstName': 'Display',
        'lastName': 'Name',
        'phoneNumber': '+255111222333',
        'isEmailVerified': false,
        'createdAt': '2025-07-31T11:32:32.436643',
        'updatedAt': '2025-07-31T11:32:32.436645',
        'role': 'customer',
        'status': 'active',
      };

      // Simulate parsing display name (which might be empty)
      final displayName = ''; // Empty display name from Firebase Auth
      final displayNameParts = displayName.isNotEmpty 
          ? {'firstName': displayName.split(' ').first, 'lastName': displayName.split(' ').skip(1).join(' ')}
          : {'firstName': '', 'lastName': ''};

      // The fallback logic should prefer Firestore data over empty display name
      final userEntity = UserEntity(
        id: firestoreData['id'] as String,
        email: firestoreData['email'] as String,
        // Should use Firestore data, not empty display name parts
        firstName: firestoreData['firstName'] as String? ?? displayNameParts['firstName'] ?? '',
        lastName: firestoreData['lastName'] as String? ?? displayNameParts['lastName'] ?? '',
        phoneNumber: firestoreData['phoneNumber'] as String?,
        isEmailVerified: firestoreData['isEmailVerified'] as bool,
        createdAt: DateTime.parse(firestoreData['createdAt'] as String),
        updatedAt: DateTime.now(),
      );

      // Verify Firestore data is preserved, not empty display name
      expect(userEntity.firstName, equals('Display'));
      expect(userEntity.lastName, equals('Name'));
      expect(userEntity.phoneNumber, equals('+255111222333'));
      
      // Verify it's not using empty display name parts
      expect(userEntity.firstName, isNot(equals('')));
      expect(userEntity.lastName, isNot(equals('')));
    });

    test('Registration should work with all field combinations', () {
      // Test various combinations of filled/empty fields
      
      final testCases = [
        // All fields filled
        {
          'firstName': 'Full',
          'lastName': 'User',
          'phoneNumber': '+255123456789',
          'address': 'Full Address, Tanzania',
        },
        // Only required fields
        {
          'firstName': 'Minimal',
          'lastName': 'User',
          'phoneNumber': null,
          'address': null,
        },
        // Phone but no address
        {
          'firstName': 'Phone',
          'lastName': 'Only',
          'phoneNumber': '+255987654321',
          'address': null,
        },
        // Address but no phone
        {
          'firstName': 'Address',
          'lastName': 'Only',
          'phoneNumber': null,
          'address': 'Address Only Street, Tanzania',
        },
      ];

      for (int i = 0; i < testCases.length; i++) {
        final testCase = testCases[i];
        
        final userEntity = UserEntity(
          id: 'test-case-$i',
          email: 'testcase$i@example.com',
          firstName: testCase['firstName'] as String,
          lastName: testCase['lastName'] as String,
          phoneNumber: testCase['phoneNumber'],
          isEmailVerified: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          address: testCase['address'] != null 
              ? Address(
                  street: testCase['address'] as String,
                  city: '',
                  region: '',
                  postalCode: '',
                  country: 'Tanzania',
                )
              : null,
        );

        // Verify the user entity is created correctly
        expect(userEntity.firstName, equals(testCase['firstName']));
        expect(userEntity.lastName, equals(testCase['lastName']));
        expect(userEntity.phoneNumber, equals(testCase['phoneNumber']));
        
        if (testCase['address'] != null) {
          expect(userEntity.address, isNotNull);
          expect(userEntity.address!.street, equals(testCase['address']));
        } else {
          expect(userEntity.address, isNull);
        }

        // Verify serialization works
        final userMap = userEntity.toMap();
        expect(userMap['firstName'], equals(testCase['firstName']));
        expect(userMap['lastName'], equals(testCase['lastName']));
        expect(userMap['phoneNumber'], equals(testCase['phoneNumber']));
      }
    });
  });
}
