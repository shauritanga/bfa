import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';

/// Custom button widget with consistent styling
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final Widget? icon;
  final bool isLoading;
  final ButtonType type;
  final ButtonSize size;
  final double? width;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style,
    this.icon,
    this.isLoading = false,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.width,
    this.height,
  });

  /// Create a primary button
  const CustomButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.size = ButtonSize.medium,
    this.width,
    this.height,
  }) : type = ButtonType.primary, style = null;

  /// Create a secondary button
  const CustomButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.size = ButtonSize.medium,
    this.width,
    this.height,
  }) : type = ButtonType.secondary, style = null;

  /// Create an outline button
  const CustomButton.outline({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.size = ButtonSize.medium,
    this.width,
    this.height,
  }) : type = ButtonType.outline, style = null;

  /// Create a text button
  const CustomButton.text({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.size = ButtonSize.medium,
    this.width,
    this.height,
  }) : type = ButtonType.text, style = null;

  /// Create a danger button
  const CustomButton.danger({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.size = ButtonSize.medium,
    this.width,
    this.height,
  }) : type = ButtonType.danger, style = null;

  @override
  Widget build(BuildContext context) {
    final buttonStyle = style ?? _getButtonStyle(context);
    final buttonSize = _getButtonSize();
    
    Widget button;

    if (icon != null) {
      button = _buildIconButton(buttonStyle);
    } else {
      button = _buildTextButton(buttonStyle);
    }

    if (width != null || height != null) {
      button = SizedBox(
        width: width,
        height: height ?? buttonSize.height,
        child: button,
      );
    }

    return button;
  }

  Widget _buildTextButton(ButtonStyle buttonStyle) {
    switch (type) {
      case ButtonType.primary:
      case ButtonType.secondary:
      case ButtonType.danger:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: _buildButtonContent(),
        );
      case ButtonType.outline:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: _buildButtonContent(),
        );
      case ButtonType.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: _buildButtonContent(),
        );
    }
  }

  Widget _buildIconButton(ButtonStyle buttonStyle) {
    switch (type) {
      case ButtonType.primary:
      case ButtonType.secondary:
      case ButtonType.danger:
        return ElevatedButton.icon(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          icon: _buildIcon(),
          label: _buildLabel(),
        );
      case ButtonType.outline:
        return OutlinedButton.icon(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          icon: _buildIcon(),
          label: _buildLabel(),
        );
      case ButtonType.text:
        return TextButton.icon(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          icon: _buildIcon(),
          label: _buildLabel(),
        );
    }
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16.w,
            height: 16.h,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              color: _getLoadingColor(),
            ),
          ),
          SizedBox(width: 8.w),
          Text(text),
        ],
      );
    }
    return Text(text);
  }

  Widget _buildIcon() {
    if (isLoading) {
      return SizedBox(
        width: 16.w,
        height: 16.h,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          color: _getLoadingColor(),
        ),
      );
    }
    return icon!;
  }

  Widget _buildLabel() {
    return Text(text);
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    final theme = Theme.of(context);
    final buttonSize = _getButtonSize();

    switch (type) {
      case ButtonType.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          padding: buttonSize.padding,
          minimumSize: Size(0, buttonSize.height),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 2,
        );
      case ButtonType.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.onSecondary,
          padding: buttonSize.padding,
          minimumSize: Size(0, buttonSize.height),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 2,
        );
      case ButtonType.outline:
        return OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: buttonSize.padding,
          minimumSize: Size(0, buttonSize.height),
          side: BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        );
      case ButtonType.text:
        return TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: buttonSize.padding,
          minimumSize: Size(0, buttonSize.height),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        );
      case ButtonType.danger:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: AppColors.onError,
          padding: buttonSize.padding,
          minimumSize: Size(0, buttonSize.height),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 2,
        );
    }
  }

  _ButtonSize _getButtonSize() {
    switch (size) {
      case ButtonSize.small:
        return _ButtonSize(
          height: 36.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        );
      case ButtonSize.medium:
        return _ButtonSize(
          height: 48.h,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        );
      case ButtonSize.large:
        return _ButtonSize(
          height: 56.h,
          padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
        );
    }
  }

  Color _getLoadingColor() {
    switch (type) {
      case ButtonType.primary:
      case ButtonType.secondary:
      case ButtonType.danger:
        return Colors.white;
      case ButtonType.outline:
      case ButtonType.text:
        return AppColors.primary;
    }
  }
}

/// Button types
enum ButtonType {
  primary,
  secondary,
  outline,
  text,
  danger,
}

/// Button sizes
enum ButtonSize {
  small,
  medium,
  large,
}

/// Internal button size class
class _ButtonSize {
  final double height;
  final EdgeInsets padding;

  const _ButtonSize({
    required this.height,
    required this.padding,
  });
}

/// Floating action button with custom styling
class CustomFAB extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final String? tooltip;
  final bool isExtended;
  final String? label;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CustomFAB({
    super.key,
    this.onPressed,
    required this.icon,
    this.tooltip,
    this.isExtended = false,
    this.label,
    this.backgroundColor,
    this.foregroundColor,
  });

  /// Create an extended FAB with label
  const CustomFAB.extended({
    super.key,
    this.onPressed,
    required this.icon,
    required this.label,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
  }) : isExtended = true;

  @override
  Widget build(BuildContext context) {
    if (isExtended && label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        icon: icon,
        label: Text(label!),
        tooltip: tooltip,
        backgroundColor: backgroundColor ?? AppColors.secondary,
        foregroundColor: foregroundColor ?? AppColors.onSecondary,
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: backgroundColor ?? AppColors.secondary,
      foregroundColor: foregroundColor ?? AppColors.onSecondary,
      child: icon,
    );
  }
}

/// Icon button with custom styling
class CustomIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final String? tooltip;
  final Color? color;
  final double? size;
  final EdgeInsets? padding;

  const CustomIconButton({
    super.key,
    this.onPressed,
    required this.icon,
    this.tooltip,
    this.color,
    this.size,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: icon,
      tooltip: tooltip,
      color: color,
      iconSize: size,
      padding: padding ?? EdgeInsets.all(8.w),
    );
  }
}

/// Toggle button widget
class CustomToggleButton extends StatelessWidget {
  final bool isSelected;
  final ValueChanged<bool>? onChanged;
  final Widget child;
  final Color? selectedColor;
  final Color? unselectedColor;
  final BorderRadius? borderRadius;

  const CustomToggleButton({
    super.key,
    required this.isSelected,
    this.onChanged,
    required this.child,
    this.selectedColor,
    this.unselectedColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => onChanged?.call(!isSelected),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected 
              ? (selectedColor ?? AppColors.primary)
              : (unselectedColor ?? Colors.transparent),
          border: Border.all(
            color: isSelected 
                ? (selectedColor ?? AppColors.primary)
                : AppColors.neutral,
          ),
          borderRadius: borderRadius ?? BorderRadius.circular(8.r),
        ),
        child: DefaultTextStyle(
          style: theme.textTheme.bodyMedium!.copyWith(
            color: isSelected 
                ? AppColors.onPrimary
                : theme.colorScheme.onSurface,
          ),
          child: child,
        ),
      ),
    );
  }
}
