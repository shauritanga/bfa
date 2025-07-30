import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_button.dart';
import '../../../../core/constants/app_constants.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final theme = Theme.of(context);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          centerTitle: true,
        ),
        body: const Center(
          child: Text('No user data available'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to edit profile
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppConstants.defaultPadding.w),
        child: Column(
          children: [
            SizedBox(height: 24.h),

            // Profile Picture
            Stack(
              children: [
                CircleAvatar(
                  radius: 60.r,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  backgroundImage: user.profileImageUrl != null
                      ? NetworkImage(user.profileImageUrl!)
                      : null,
                  child: user.profileImageUrl == null
                      ? Icon(
                          Icons.person,
                          size: 60.w,
                          color: theme.colorScheme.onPrimaryContainer,
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.camera_alt,
                        color: theme.colorScheme.onPrimary,
                        size: 20.w,
                      ),
                      onPressed: () {
                        // TODO: Change profile picture
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // User Name
            Text(
              '${user.firstName} ${user.lastName}',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),

            // Email
            Text(
              user.email,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 32.h),

            // Profile Information Cards
            _buildInfoCard(
              context,
              title: 'Personal Information',
              children: [
                _buildInfoRow(context, 'First Name', user.firstName),
                _buildInfoRow(context, 'Last Name', user.lastName),
                _buildInfoRow(context, 'Email', user.email),
                _buildInfoRow(
                  context,
                  'Phone',
                  user.phoneNumber ?? 'Not provided',
                ),
                _buildInfoRow(
                  context,
                  'Email Verified',
                  user.isEmailVerified ? 'Yes' : 'No',
                  trailing: !user.isEmailVerified
                      ? TextButton(
                          onPressed: () => _sendEmailVerification(context, ref),
                          child: const Text('Verify'),
                        )
                      : null,
                ),
              ],
            ),
            SizedBox(height: 16.h),

            _buildInfoCard(
              context,
              title: 'Account Information',
              children: [
                _buildInfoRow(
                  context,
                  'Member Since',
                  _formatDate(user.createdAt),
                ),
                _buildInfoRow(
                  context,
                  'Last Updated',
                  _formatDate(user.updatedAt),
                ),
                _buildInfoRow(
                  context,
                  'User Role',
                  user.role.toString().split('.').last.toUpperCase(),
                ),
                _buildInfoRow(
                  context,
                  'Account Status',
                  user.status.toString().split('.').last.toUpperCase(),
                ),
              ],
            ),
            SizedBox(height: 32.h),

            // Action Buttons
            AuthButton(
              text: 'Edit Profile',
              onPressed: () {
                // TODO: Navigate to edit profile
              },
              icon: Icons.edit,
            ),
            SizedBox(height: 16.h),

            AuthButton(
              text: 'Change Password',
              onPressed: () {
                // TODO: Navigate to change password
              },
              isOutlined: true,
              icon: Icons.lock_outline,
            ),
            SizedBox(height: 16.h),

            AuthButton(
              text: 'Sign Out',
              onPressed: () => _signOut(context, ref),
              isOutlined: true,
              backgroundColor: theme.colorScheme.error,
              textColor: theme.colorScheme.error,
              icon: Icons.logout,
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16.h),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    Widget? trailing,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _sendEmailVerification(BuildContext context, WidgetRef ref) async {
    final result = await ref.read(authProvider.notifier).sendEmailVerification();
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.isSuccess
                ? 'Verification email sent successfully'
                : result.failure?.message ?? 'Failed to send verification email',
          ),
          backgroundColor: result.isSuccess
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await ref.read(authProvider.notifier).signOut();
      
      if (result.isSuccess && context.mounted) {
        context.go('/login');
      }
    }
  }
}
