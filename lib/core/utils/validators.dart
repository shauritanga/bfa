import '../constants/app_constants.dart';

/// Utility class for input validation
class Validators {
  // Private constructor to prevent instantiation
  Validators._();

  /// Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }

    if (value.length > AppConstants.maxPasswordLength) {
      return 'Password must not exceed ${AppConstants.maxPasswordLength} characters';
    }

    // Check for at least one uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for at least one lowercase letter
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    // Check for at least one digit
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  /// Confirm password validation
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.length < AppConstants.minNameLength) {
      return 'Name must be at least ${AppConstants.minNameLength} characters';
    }

    if (value.length > AppConstants.maxNameLength) {
      return 'Name must not exceed ${AppConstants.maxNameLength} characters';
    }

    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(value)) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }

    return null;
  }

  /// Phone number validation
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove all non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');

    // Check for valid length (assuming 10-15 digits)
    if (digitsOnly.length < 10 || digitsOnly.length > 15) {
      return 'Please enter a valid phone number';
    }

    // Check for valid format (can start with + or country code)
    final phoneRegex = RegExp(r'^\+?[1-9]\d{9,14}$');
    if (!phoneRegex.hasMatch(digitsOnly)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Numeric validation
  static String? validateNumeric(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (double.tryParse(value) == null) {
      return '$fieldName must be a valid number';
    }

    return null;
  }

  /// Price validation
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }

    final price = double.tryParse(value);
    if (price == null) {
      return 'Please enter a valid price';
    }

    if (price <= 0) {
      return 'Price must be greater than zero';
    }

    if (price > 1000000) {
      return 'Price seems too high';
    }

    return null;
  }

  /// Quantity validation
  static String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Quantity is required';
    }

    final quantity = int.tryParse(value);
    if (quantity == null) {
      return 'Please enter a valid quantity';
    }

    if (quantity <= 0) {
      return 'Quantity must be greater than zero';
    }

    if (quantity > 10000) {
      return 'Quantity seems too high';
    }

    return null;
  }

  /// Description validation
  static String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Description is required';
    }

    if (value.length > AppConstants.maxDescriptionLength) {
      return 'Description must not exceed ${AppConstants.maxDescriptionLength} characters';
    }

    return null;
  }

  /// Address validation
  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address is required';
    }

    if (value.length < 10) {
      return 'Please enter a complete address';
    }

    if (value.length > 200) {
      return 'Address is too long';
    }

    return null;
  }

  /// URL validation
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  /// Rating validation
  static String? validateRating(double? value) {
    if (value == null) {
      return 'Rating is required';
    }

    if (value < AppConstants.minRating || value > AppConstants.maxRating) {
      return 'Rating must be between ${AppConstants.minRating} and ${AppConstants.maxRating}';
    }

    return null;
  }

  /// Search query validation
  static String? validateSearchQuery(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Search query cannot be empty';
    }

    if (value.trim().length < AppConstants.minSearchLength) {
      return 'Search query must be at least ${AppConstants.minSearchLength} characters';
    }

    return null;
  }

  /// Credit card number validation (basic)
  static String? validateCreditCard(String? value) {
    if (value == null || value.isEmpty) {
      return 'Card number is required';
    }

    // Remove spaces and hyphens
    final cardNumber = value.replaceAll(RegExp(r'[\s\-]'), '');

    // Check if all characters are digits
    if (!RegExp(r'^\d+$').hasMatch(cardNumber)) {
      return 'Card number can only contain digits';
    }

    // Check length (most cards are 13-19 digits)
    if (cardNumber.length < 13 || cardNumber.length > 19) {
      return 'Please enter a valid card number';
    }

    // Luhn algorithm validation
    if (!_isValidLuhn(cardNumber)) {
      return 'Please enter a valid card number';
    }

    return null;
  }

  /// Luhn algorithm for credit card validation
  static bool _isValidLuhn(String cardNumber) {
    int sum = 0;
    bool alternate = false;

    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cardNumber[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit = (digit % 10) + 1;
        }
      }

      sum += digit;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }
}
