import "package:flutter/material.dart";

/// Brand palette. Primary teal is the main accent; ink (secondary) carries
/// everything else; tertiary blue is a rare second accent.
abstract final class AppColors {
  static const primary = Color(0xFF0F766E);

  static const primaryPressed = Color(0xFF0B5C56);

  static const primarySoft = Color(0xFFD5F0EC);

  /// Second accent, blue. Used sparingly (e.g. Saturdays in the calendar).
  static const tertiary = Color(0xFF2F6BFF);

  static const ink = Color(0xFF161718);

  static const gray600 = Color(0xFF5D6066);

  static const gray400 = Color(0xFF9A9CA1);

  static const gray300 = Color(0xFFC9CBD0);

  static const gray200 = Color(0xFFE6E7EA);

  static const gray150 = Color(0xFFEDEEF0);

  static const gray100 = Color(0xFFF2F3F5);

  static const gray50 = Color(0xFFF7F7F8);

  static const paper = Color(0xFFFCFCFD);

  static const error = Color(0xFFE5484D);
}

const appColorScheme = ColorScheme(
  brightness: .light,
  primary: AppColors.primary,
  onPrimary: Colors.white,
  primaryContainer: AppColors.primarySoft,
  onPrimaryContainer: Color(0xFF083F3A),
  secondary: AppColors.ink,
  onSecondary: AppColors.paper,
  secondaryContainer: AppColors.gray150,
  onSecondaryContainer: AppColors.ink,
  tertiary: AppColors.tertiary,
  onTertiary: Colors.white,
  error: AppColors.error,
  onError: Colors.white,
  errorContainer: Color(0xFFFFE5E5),
  onErrorContainer: Color(0xFF8A1C20),
  surface: AppColors.paper,
  onSurface: AppColors.ink,
  onSurfaceVariant: AppColors.gray600,
  surfaceContainerLowest: Colors.white,
  surfaceContainerLow: AppColors.gray50,
  surfaceContainer: AppColors.gray100,
  surfaceContainerHigh: AppColors.gray150,
  surfaceContainerHighest: AppColors.gray200,
  outline: AppColors.gray300,
  outlineVariant: AppColors.gray200,
  inverseSurface: AppColors.ink,
  onInverseSurface: AppColors.gray100,
  inversePrimary: Color(0xFF7FD4C8),
  // No M3 elevation tint: surfaces stay neutral gray.
  surfaceTint: Colors.transparent,
);
