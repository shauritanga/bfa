import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import '../constants/app_colors.dart';

/// App theme configuration using FlexColorScheme
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  /// Light theme configuration
  static ThemeData get lightTheme {
    return FlexThemeData.light(
      scheme: FlexScheme.custom,
      colors: const FlexSchemeColor(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryContainer,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryContainer,
        tertiary: AppColors.accent,
        tertiaryContainer: AppColors.accentLight,
        appBarColor: AppColors.primary,
        error: AppColors.error,
      ),
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 7,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 10,
        blendOnColors: false,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,

        // AppBar styling
        appBarBackgroundSchemeColor: SchemeColor.primary,
        appBarScrolledUnderElevation: 2,

        // Card styling
        cardRadius: 12,
        cardElevation: 2,

        // Button styling
        elevatedButtonRadius: 12,
        elevatedButtonElevation: 2,
        elevatedButtonSchemeColor: SchemeColor.primary,

        filledButtonRadius: 12,
        outlinedButtonRadius: 12,
        textButtonRadius: 12,

        // Input decoration
        inputDecoratorRadius: 12,
        inputDecoratorSchemeColor: SchemeColor.primary,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorFocusedHasBorder: true,
        inputDecoratorUnfocusedHasBorder: true,

        // FAB styling
        fabRadius: 16,
        fabUseShape: true,
        fabSchemeColor: SchemeColor.secondary,

        // Chip styling
        chipRadius: 8,
        chipSchemeColor: SchemeColor.primaryContainer,

        // Dialog styling
        dialogRadius: 16,
        dialogElevation: 6,

        // Bottom sheet styling
        bottomSheetRadius: 16,
        bottomSheetElevation: 4,

        // Navigation bar styling
        navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        navigationBarSelectedIconSchemeColor: SchemeColor.primary,
        navigationBarIndicatorSchemeColor: SchemeColor.primaryContainer,
        navigationBarBackgroundSchemeColor: SchemeColor.surface,
        navigationBarElevation: 2,
        navigationBarHeight: 70,

        // Tab bar styling
        tabBarIndicatorSchemeColor: SchemeColor.primary,
        tabBarItemSchemeColor: SchemeColor.primary,

        // Switch styling
        switchSchemeColor: SchemeColor.primary,
        switchThumbSchemeColor: SchemeColor.onPrimary,

        // Checkbox styling
        checkboxSchemeColor: SchemeColor.primary,

        // Radio styling
        radioSchemeColor: SchemeColor.primary,

        // Slider styling
        sliderBaseSchemeColor: SchemeColor.primary,
        sliderIndicatorSchemeColor: SchemeColor.primary,
        sliderValueIndicatorType: FlexSliderIndicatorType.drop,

        // SnackBar styling
        snackBarRadius: 8,
        snackBarElevation: 4,
        snackBarBackgroundSchemeColor: SchemeColor.inverseSurface,

        // Bottom navigation bar styling
        bottomNavigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        bottomNavigationBarSelectedIconSchemeColor: SchemeColor.primary,
        bottomNavigationBarBackgroundSchemeColor: SchemeColor.surface,
        bottomNavigationBarElevation: 8,
      ),
      keyColors: const FlexKeyColors(
        useSecondary: true,
        useTertiary: true,
        keepPrimary: true,
        keepSecondary: true,
        keepTertiary: true,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
      fontFamily: 'Inter',
    ).copyWith(
      // Custom text theme
      textTheme: _buildTextTheme(Brightness.light),
      // Custom app bar theme
      appBarTheme: _buildAppBarTheme(Brightness.light),
      // Custom bottom navigation bar theme
      bottomNavigationBarTheme: _buildBottomNavigationBarTheme(
        Brightness.light,
      ),
    );
  }

  /// Dark theme configuration
  static ThemeData get darkTheme {
    return FlexThemeData.dark(
      scheme: FlexScheme.custom,
      colors: FlexSchemeColor.from(
        primary: AppColors.primaryLight,
        primaryContainer: AppColors.primaryDark,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryDark,
        tertiary: AppColors.accent,
        tertiaryContainer: AppColors.accentDark,
        appBarColor: AppColors.primaryDark,
        error: AppColors.errorLight,
      ),
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 13,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 20,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,

        // AppBar styling
        appBarBackgroundSchemeColor: SchemeColor.surface,
        appBarScrolledUnderElevation: 2,

        // Card styling
        cardRadius: 12,
        cardElevation: 4,

        // Button styling
        elevatedButtonRadius: 12,
        elevatedButtonElevation: 2,
        elevatedButtonSchemeColor: SchemeColor.primary,

        filledButtonRadius: 12,
        outlinedButtonRadius: 12,
        textButtonRadius: 12,

        // Input decoration
        inputDecoratorRadius: 12,
        inputDecoratorSchemeColor: SchemeColor.primary,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorFocusedHasBorder: true,
        inputDecoratorUnfocusedHasBorder: true,

        // FAB styling
        fabRadius: 16,
        fabUseShape: true,
        fabSchemeColor: SchemeColor.secondary,

        // Chip styling
        chipRadius: 8,
        chipSchemeColor: SchemeColor.primaryContainer,

        // Dialog styling
        dialogRadius: 16,
        dialogElevation: 8,

        // Bottom sheet styling
        bottomSheetRadius: 16,
        bottomSheetElevation: 6,

        // Navigation bar styling
        navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        navigationBarSelectedIconSchemeColor: SchemeColor.primary,
        navigationBarIndicatorSchemeColor: SchemeColor.primaryContainer,
        navigationBarBackgroundSchemeColor: SchemeColor.surface,
        navigationBarElevation: 4,
        navigationBarHeight: 70,

        // Tab bar styling
        tabBarIndicatorSchemeColor: SchemeColor.primary,
        tabBarItemSchemeColor: SchemeColor.primary,

        // Switch styling
        switchSchemeColor: SchemeColor.primary,
        switchThumbSchemeColor: SchemeColor.onPrimary,

        // Checkbox styling
        checkboxSchemeColor: SchemeColor.primary,

        // Radio styling
        radioSchemeColor: SchemeColor.primary,

        // Slider styling
        sliderBaseSchemeColor: SchemeColor.primary,
        sliderIndicatorSchemeColor: SchemeColor.primary,
        sliderValueIndicatorType: FlexSliderIndicatorType.drop,

        // SnackBar styling
        snackBarRadius: 8,
        snackBarElevation: 6,
        snackBarBackgroundSchemeColor: SchemeColor.inverseSurface,

        // Bottom navigation bar styling
        bottomNavigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        bottomNavigationBarSelectedIconSchemeColor: SchemeColor.primary,
        bottomNavigationBarBackgroundSchemeColor: SchemeColor.surface,
        bottomNavigationBarElevation: 8,
      ),
      keyColors: const FlexKeyColors(
        useSecondary: true,
        useTertiary: true,
        keepPrimary: true,
        keepSecondary: true,
        keepTertiary: true,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
      fontFamily: 'Inter',
    ).copyWith(
      // Custom text theme
      textTheme: _buildTextTheme(Brightness.dark),
      // Custom app bar theme
      appBarTheme: _buildAppBarTheme(Brightness.dark),
      // Custom bottom navigation bar theme
      bottomNavigationBarTheme: _buildBottomNavigationBarTheme(Brightness.dark),
    );
  }

  /// Build custom text theme
  static TextTheme _buildTextTheme(Brightness brightness) {
    final baseTheme = brightness == Brightness.light
        ? ThemeData.light().textTheme
        : ThemeData.dark().textTheme;

    return baseTheme.copyWith(
      displayLarge: baseTheme.displayLarge?.copyWith(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.bold,
      ),
      displayMedium: baseTheme.displayMedium?.copyWith(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.bold,
      ),
      displaySmall: baseTheme.displaySmall?.copyWith(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
      ),
      headlineLarge: baseTheme.headlineLarge?.copyWith(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: baseTheme.headlineMedium?.copyWith(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: baseTheme.headlineSmall?.copyWith(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
      ),
      titleLarge: baseTheme.titleLarge?.copyWith(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
      ),
      titleMedium: baseTheme.titleMedium?.copyWith(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w500,
      ),
      titleSmall: baseTheme.titleSmall?.copyWith(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: baseTheme.bodyLarge?.copyWith(
        fontFamily: 'Inter',
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: baseTheme.bodyMedium?.copyWith(
        fontFamily: 'Inter',
        fontWeight: FontWeight.normal,
      ),
      bodySmall: baseTheme.bodySmall?.copyWith(
        fontFamily: 'Inter',
        fontWeight: FontWeight.normal,
      ),
      labelLarge: baseTheme.labelLarge?.copyWith(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w500,
      ),
      labelMedium: baseTheme.labelMedium?.copyWith(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w500,
      ),
      labelSmall: baseTheme.labelSmall?.copyWith(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w400,
      ),
    );
  }

  /// Build custom app bar theme
  static AppBarTheme _buildAppBarTheme(Brightness brightness) {
    return AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 2,
      backgroundColor: brightness == Brightness.light
          ? AppColors.primary
          : AppColors.surface,
      foregroundColor: brightness == Brightness.light
          ? AppColors.onPrimary
          : AppColors.onSurface,
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: brightness == Brightness.light
            ? AppColors.onPrimary
            : AppColors.onSurface,
      ),
      iconTheme: IconThemeData(
        color: brightness == Brightness.light
            ? AppColors.onPrimary
            : AppColors.onSurface,
      ),
      actionsIconTheme: IconThemeData(
        color: brightness == Brightness.light
            ? AppColors.onPrimary
            : AppColors.onSurface,
      ),
    );
  }

  /// Build custom bottom navigation bar theme
  static BottomNavigationBarThemeData _buildBottomNavigationBarTheme(
    Brightness brightness,
  ) {
    return BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      backgroundColor: brightness == Brightness.light
          ? AppColors.surface
          : AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.neutral,
      selectedLabelStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
    );
  }
}
