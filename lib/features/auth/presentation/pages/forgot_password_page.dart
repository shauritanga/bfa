import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../../../../core/constants/app_constants.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
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
        title: const Text('Reset Password'),
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
                SizedBox(height: 40.h),

                // Icon
                Icon(
                  _emailSent ? Icons.mark_email_read : Icons.lock_reset,
                  size: 80.w,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(height: 24.h),

                // Title
                Text(
                  _emailSent ? 'Check Your Email' : 'Forgot Password?',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 16.h),

                // Description
                Text(
                  _emailSent
                      ? 'We\'ve sent a password reset link to ${_emailController.text.trim()}'
                      : 'Enter your email address and we\'ll send you a link to reset your password.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: 40.h),

                if (!_emailSent) ...[
                  // Email Field
                  AuthTextField(
                    controller: _emailController,
                    label: 'Email',
                    hintText: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: _validateEmail,
                  ),
                  SizedBox(height: 32.h),

                  // Send Reset Link Button
                  AuthButton(
                    text: 'Send Reset Link',
                    onPressed: authState.isLoading ? null : _sendResetLink,
                    isLoading: authState.isLoading,
                  ),
                ] else ...[
                  // Email sent success content
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.onPrimaryContainer,
                          size: 24.w,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Didn\'t receive the email? Check your spam folder or try again.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Resend Button
                  AuthButton(
                    text: 'Resend Email',
                    onPressed: authState.isLoading ? null : _sendResetLink,
                    isLoading: authState.isLoading,
                    isOutlined: true,
                  ),
                ],

                SizedBox(height: 24.h),

                // Back to Login
                AuthButton(
                  text: 'Back to Login',
                  onPressed: () => context.pop(),
                  isOutlined: !_emailSent,
                ),

                SizedBox(height: 32.h),

                // Additional Help
                if (_emailSent) ...[
                  Text(
                    'Still having trouble?',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to contact support
                    },
                    child: Text(
                      'Contact Support',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
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

  Future<void> _sendResetLink() async {
    if (_formKey.currentState?.validate() ?? false) {
      final result = await ref.read(authProvider.notifier).sendPasswordReset(
            _emailController.text.trim(),
          );

      if (result.isSuccess && mounted) {
        setState(() {
          _emailSent = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Password reset email sent successfully'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    }
  }
}
