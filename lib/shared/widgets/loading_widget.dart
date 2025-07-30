import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';

/// A reusable loading widget with different styles
class LoadingWidget extends StatelessWidget {
  final String? message;
  final double? size;
  final Color? color;
  final LoadingStyle style;

  const LoadingWidget({
    super.key,
    this.message,
    this.size,
    this.color,
    this.style = LoadingStyle.circular,
  });

  /// Create a small loading widget
  const LoadingWidget.small({super.key, this.message, this.color})
    : size = 20.0,
      style = LoadingStyle.circular;

  /// Create a large loading widget
  const LoadingWidget.large({super.key, this.message, this.color})
    : size = 50.0,
      style = LoadingStyle.circular;

  /// Create a linear loading widget
  const LoadingWidget.linear({super.key, this.message, this.color})
    : size = null,
      style = LoadingStyle.linear;

  /// Create a shimmer loading widget
  const LoadingWidget.shimmer({super.key, this.message, this.color})
    : size = null,
      style = LoadingStyle.shimmer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loadingColor = color ?? AppColors.primary;

    Widget loadingIndicator;

    switch (style) {
      case LoadingStyle.circular:
        loadingIndicator = SizedBox(
          width: size?.w ?? 30.w,
          height: size?.h ?? 30.h,
          child: CircularProgressIndicator(
            color: loadingColor,
            strokeWidth: 3.0,
          ),
        );
        break;

      case LoadingStyle.linear:
        loadingIndicator = LinearProgressIndicator(
          color: loadingColor,
          backgroundColor: loadingColor.withValues(alpha: 0.2),
        );
        break;

      case LoadingStyle.shimmer:
        loadingIndicator = _buildShimmerEffect();
        break;

      case LoadingStyle.dots:
        loadingIndicator = _buildDotsLoading(loadingColor);
        break;
    }

    if (message != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          loadingIndicator,
          SizedBox(height: 16.h),
          Text(
            message!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return loadingIndicator;
  }

  Widget _buildShimmerEffect() {
    return Container(
      width: double.infinity,
      height: 20.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.r),
        gradient: LinearGradient(
          colors: [
            AppColors.neutral.withValues(alpha: 0.3),
            AppColors.neutral.withValues(alpha: 0.1),
            AppColors.neutral.withValues(alpha: 0.3),
          ],
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
    );
  }

  Widget _buildDotsLoading(Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 600 + (index * 200)),
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          width: 8.w,
          height: 8.h,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        );
      }),
    );
  }
}

/// Loading styles enum
enum LoadingStyle { circular, linear, shimmer, dots }

/// Full screen loading overlay
class LoadingOverlay extends StatelessWidget {
  final String? message;
  final bool isLoading;
  final Widget child;
  final Color? backgroundColor;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor ?? Colors.black.withValues(alpha: 0.5),
            child: Center(
              child: Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: LoadingWidget(
                  message: message ?? 'Loading...',
                  size: 40.0,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Loading button widget
class LoadingButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonStyle? style;
  final Widget? icon;

  const LoadingButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.style,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: style,
        icon: isLoading
            ? SizedBox(
                width: 16.w,
                height: 16.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.0,
                  color: Colors.white,
                ),
              )
            : icon!,
        label: Text(text),
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      child: isLoading
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16.w,
                  height: 16.h,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.0,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(text),
              ],
            )
          : Text(text),
    );
  }
}

/// Shimmer loading card
class ShimmerCard extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const ShimmerCard({super.key, this.width, this.height, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height ?? 200.h,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(12.r),
        gradient: LinearGradient(
          colors: [
            AppColors.neutral.withValues(alpha: 0.3),
            AppColors.neutral.withValues(alpha: 0.1),
            AppColors.neutral.withValues(alpha: 0.3),
          ],
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
    );
  }
}

/// Shimmer list item
class ShimmerListItem extends StatelessWidget {
  final bool hasAvatar;
  final bool hasSubtitle;

  const ShimmerListItem({
    super.key,
    this.hasAvatar = true,
    this.hasSubtitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          if (hasAvatar) ...[
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neutral.withValues(alpha: 0.3),
              ),
            ),
            SizedBox(width: 12.w),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 16.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.r),
                    color: AppColors.neutral.withValues(alpha: 0.3),
                  ),
                ),
                if (hasSubtitle) ...[
                  SizedBox(height: 8.h),
                  Container(
                    width: 200.w,
                    height: 14.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.r),
                      color: AppColors.neutral.withValues(alpha: 0.2),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
