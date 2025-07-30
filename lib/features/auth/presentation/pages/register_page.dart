import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../../../../core/constants/app_constants.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    // Listen to auth state changes
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppConstants.defaultPadding.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 24.h),

                // Welcome Text
                Text(
                  'Join ${AppConstants.appName}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),

                Text(
                  'Create your account to start buying fresh crops',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: 32.h),

                // First Name and Last Name Row
                Row(
                  children: [
                    Expanded(
                      child: AuthTextField(
                        controller: _firstNameController,
                        label: 'First Name',
                        hintText: 'Enter first name',
                        prefixIcon: Icons.person_outline,
                        validator: _validateFirstName,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: AuthTextField(
                        controller: _lastNameController,
                        label: 'Last Name',
                        hintText: 'Enter last name',
                        prefixIcon: Icons.person_outline,
                        validator: _validateLastName,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Email Field
                AuthTextField(
                  controller: _emailController,
                  label: 'Email',
                  hintText: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: _validateEmail,
                ),
                SizedBox(height: 16.h),

                // Phone Field
                AuthTextField(
                  controller: _phoneController,
                  label: 'Phone Number (Optional)',
                  hintText: 'Enter your phone number',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  validator: _validatePhone,
                ),
                SizedBox(height: 16.h),

                // Password Field
                AuthTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hintText: 'Enter your password',
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: _validatePassword,
                ),
                SizedBox(height: 16.h),

                // Confirm Password Field
                AuthTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hintText: 'Confirm your password',
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  validator: _validateConfirmPassword,
                ),
                SizedBox(height: 16.h),

                // Terms and Conditions
                Row(
                  children: [
                    Checkbox(
                      value: _acceptTerms,
                      onChanged: (value) {
                        setState(() {
                          _acceptTerms = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: theme.textTheme.bodyMedium,
                          children: [
                            const TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // Sign Up Button
                AuthButton(
                  text: 'Create Account',
                  onPressed: authState.isLoading || !_acceptTerms ? null : _signUp,
                  isLoading: authState.isLoading,
                ),
                SizedBox(height: 24.h),

                // Sign In Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: theme.textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text(
                        'Sign In',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return 'First name is required';
    }
    if (value.length < AppConstants.minNameLength) {
      return 'First name must be at least ${AppConstants.minNameLength} characters';
    }
    return null;
  }

  String? _validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Last name is required';
    }
    if (value.length < AppConstants.minNameLength) {
      return 'Last name must be at least ${AppConstants.minNameLength} characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value != null && value.isNotEmpty) {
      if (!RegExp(r'^\+?[\d\s\-\(\)]+$').hasMatch(value)) {
        return 'Please enter a valid phone number';
      }
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _signUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      final result = await ref.read(authProvider.notifier).signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            phoneNumber: _phoneController.text.trim().isEmpty 
                ? null 
                : _phoneController.text.trim(),
          );

      if (result.isSuccess && mounted) {
        // Show success message and navigate
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppConstants.registerSuccessMessage),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        context.go('/home');
      }
    }
  }
}
