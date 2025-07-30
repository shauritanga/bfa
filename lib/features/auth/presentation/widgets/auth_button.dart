import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/loading_widget.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const AuthButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isOutlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          side: BorderSide(
            color: backgroundColor ?? theme.colorScheme.primary,
          ),
        ),
        child: _buildButtonContent(context),
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? theme.colorScheme.primary,
        foregroundColor: textColor ?? theme.colorScheme.onPrimary,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        elevation: 2,
      ),
      child: _buildButtonContent(context),
    );
  }

  Widget _buildButtonContent(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return SizedBox(
        height: 20.h,
        width: 20.w,
        child: LoadingWidget(
          color: isOutlined
              ? (backgroundColor ?? theme.colorScheme.primary)
              : (textColor ?? theme.colorScheme.onPrimary),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20.w,
            color: isOutlined
                ? (backgroundColor ?? theme.colorScheme.primary)
                : (textColor ?? theme.colorScheme.onPrimary),
          ),
          SizedBox(width: 8.w),
          Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: isOutlined
                  ? (backgroundColor ?? theme.colorScheme.primary)
                  : (textColor ?? theme.colorScheme.onPrimary),
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: theme.textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: isOutlined
            ? (backgroundColor ?? theme.colorScheme.primary)
            : (textColor ?? theme.colorScheme.onPrimary),
      ),
    );
  }
}
