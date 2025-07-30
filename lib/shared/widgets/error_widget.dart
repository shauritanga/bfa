import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/errors/failures.dart';

/// A reusable error widget for displaying different error states
class AppErrorWidget extends StatelessWidget {
  final Failure? failure;
  final String? message;
  final String? title;
  final VoidCallback? onRetry;
  final Widget? icon;
  final ErrorWidgetStyle style;

  const AppErrorWidget({
    super.key,
    this.failure,
    this.message,
    this.title,
    this.onRetry,
    this.icon,
    this.style = ErrorWidgetStyle.full,
  });

  /// Create a network error widget
  const AppErrorWidget.network({super.key, this.onRetry})
    : failure = null,
      message = 'Please check your internet connection and try again.',
      title = 'No Internet Connection',
      icon = null,
      style = ErrorWidgetStyle.full;

  /// Create a server error widget
  const AppErrorWidget.server({super.key, this.onRetry})
    : failure = null,
      message = 'Something went wrong on our end. Please try again later.',
      title = 'Server Error',
      icon = null,
      style = ErrorWidgetStyle.full;

  /// Create a not found error widget
  const AppErrorWidget.notFound({
    super.key,
    this.onRetry,
    this.message = 'The content you\'re looking for could not be found.',
  }) : failure = null,
       title = 'Not Found',
       icon = null,
       style = ErrorWidgetStyle.full;

  /// Create a compact error widget
  const AppErrorWidget.compact({super.key, required this.message, this.onRetry})
    : failure = null,
      title = null,
      icon = null,
      style = ErrorWidgetStyle.compact;

  /// Create an inline error widget
  const AppErrorWidget.inline({super.key, required this.message})
    : failure = null,
      title = null,
      icon = null,
      onRetry = null,
      style = ErrorWidgetStyle.inline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorMessage = _getErrorMessage();
    final errorTitle = _getErrorTitle();
    final errorIcon = _getErrorIcon();

    switch (style) {
      case ErrorWidgetStyle.full:
        return _buildFullErrorWidget(
          theme,
          errorTitle,
          errorMessage,
          errorIcon,
        );
      case ErrorWidgetStyle.compact:
        return _buildCompactErrorWidget(theme, errorMessage, errorIcon);
      case ErrorWidgetStyle.inline:
        return _buildInlineErrorWidget(theme, errorMessage);
    }
  }

  Widget _buildFullErrorWidget(
    ThemeData theme,
    String title,
    String message,
    IconData icon,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40.sp, color: AppColors.error),
            ),
            SizedBox(height: 24.h),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: 24.h),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompactErrorWidget(
    ThemeData theme,
    String message,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.error, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
          if (onRetry != null) ...[
            SizedBox(width: 12.w),
            IconButton(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              color: AppColors.error,
              iconSize: 20.sp,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInlineErrorWidget(ThemeData theme, String message) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 16.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getErrorMessage() {
    if (message != null) return message!;

    if (failure != null) {
      return failure!.message;
    }

    return 'An unexpected error occurred. Please try again.';
  }

  String _getErrorTitle() {
    if (title != null) return title!;

    if (failure != null) {
      switch (failure.runtimeType) {
        case NetworkFailure:
          return 'Network Error';
        case ServerFailure:
          return 'Server Error';
        case AuthFailure:
          return 'Authentication Error';
        case ValidationFailure:
          return 'Validation Error';
        case PaymentFailure:
          return 'Payment Error';
        default:
          return 'Error';
      }
    }

    return 'Error';
  }

  IconData _getErrorIcon() {
    if (icon != null) return icon as IconData;

    if (failure != null) {
      switch (failure.runtimeType) {
        case NetworkFailure:
          return Icons.wifi_off;
        case ServerFailure:
          return Icons.cloud_off;
        case AuthFailure:
          return Icons.lock_outline;
        case ValidationFailure:
          return Icons.warning_outlined;
        case PaymentFailure:
          return Icons.payment_outlined;
        default:
          return Icons.error_outline;
      }
    }

    return Icons.error_outline;
  }
}

/// Error widget styles
enum ErrorWidgetStyle { full, compact, inline }

/// Empty state widget
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final Widget? icon;
  final VoidCallback? onAction;
  final String? actionText;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.onAction,
    this.actionText,
  });

  /// Create an empty products widget
  const EmptyStateWidget.products({super.key, this.onAction})
    : title = 'No Products Found',
      message = 'We couldn\'t find any products matching your criteria.',
      icon = null,
      actionText = 'Browse All Products';

  /// Create an empty cart widget
  const EmptyStateWidget.cart({super.key, this.onAction})
    : title = 'Your Cart is Empty',
      message = 'Add some fresh crops to your cart to get started.',
      icon = null,
      actionText = 'Start Shopping';

  /// Create an empty orders widget
  const EmptyStateWidget.orders({super.key, this.onAction})
    : title = 'No Orders Yet',
      message =
          'You haven\'t placed any orders yet. Start shopping for fresh crops!',
      icon = null,
      actionText = 'Start Shopping';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: AppColors.neutral.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child:
                  icon ??
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 40.sp,
                    color: AppColors.neutral,
                  ),
            ),
            SizedBox(height: 24.h),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && actionText != null) ...[
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                ),
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
