import "package:flutter/material.dart";

import "app_colors.dart";
import "app_tokens.dart";

const _scheme = appColorScheme;

/// Pretendard scale tuned for Korean: tighter tracking on large sizes,
/// 1.5 line height for body copy. Colors come from the color scheme.
const _textTheme = TextTheme(
  displayLarge: TextStyle(
    fontSize: 40,
    fontWeight: .w800,
    height: 1.2,
    letterSpacing: -1.0,
  ),
  displayMedium: TextStyle(
    fontSize: 32,
    fontWeight: .w700,
    height: 1.25,
    letterSpacing: -0.8,
  ),
  displaySmall: TextStyle(
    fontSize: 28,
    fontWeight: .w700,
    height: 1.3,
    letterSpacing: -0.6,
  ),
  headlineLarge: TextStyle(
    fontSize: 24,
    fontWeight: .w700,
    height: 1.35,
    letterSpacing: -0.5,
  ),
  headlineMedium: TextStyle(
    fontSize: 22,
    fontWeight: .w700,
    height: 1.35,
    letterSpacing: -0.4,
  ),
  headlineSmall: TextStyle(
    fontSize: 20,
    fontWeight: .w700,
    height: 1.4,
    letterSpacing: -0.3,
  ),
  titleLarge: TextStyle(
    fontSize: 18,
    fontWeight: .w600,
    height: 1.4,
    letterSpacing: -0.3,
  ),
  titleMedium: TextStyle(
    fontSize: 16,
    fontWeight: .w600,
    height: 1.45,
    letterSpacing: -0.2,
  ),
  titleSmall: TextStyle(
    fontSize: 14,
    fontWeight: .w600,
    height: 1.45,
    letterSpacing: -0.1,
  ),
  bodyLarge: TextStyle(
    fontSize: 16,
    fontWeight: .w400,
    height: 1.5,
    letterSpacing: -0.2,
  ),
  bodyMedium: TextStyle(
    fontSize: 15,
    fontWeight: .w400,
    height: 1.5,
    letterSpacing: -0.1,
  ),
  bodySmall: TextStyle(
    fontSize: 13,
    fontWeight: .w400,
    height: 1.45,
    letterSpacing: 0,
  ),
  labelLarge: TextStyle(
    fontSize: 15,
    fontWeight: .w600,
    height: 1.3,
    letterSpacing: -0.1,
  ),
  labelMedium: TextStyle(
    fontSize: 13,
    fontWeight: .w500,
    height: 1.3,
    letterSpacing: 0,
  ),
  labelSmall: TextStyle(
    fontSize: 12,
    fontWeight: .w500,
    height: 1.3,
    letterSpacing: 0,
  ),
);

const _buttonShape = RoundedRectangleBorder(
  borderRadius: .all(.circular(AppRadius.md)),
);

const _buttonSize = Size(64, 52);

const _buttonPadding = EdgeInsets.symmetric(horizontal: AppSpacing.xl);

final _inputBorder = OutlineInputBorder(
  borderRadius: .circular(AppRadius.md),
  borderSide: .none,
);

// A getter, not a `final`: a top-level final is built once, so hot reload
// would keep showing the old theme until a full restart.
ThemeData get appTheme => ThemeData(
  fontFamily: "Pretendard",
  colorScheme: _scheme,
  textTheme: _textTheme,
  scaffoldBackgroundColor: _scheme.surface,

  appBarTheme: AppBarTheme(
    backgroundColor: _scheme.surface,
    foregroundColor: _scheme.onSurface,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    titleTextStyle: _textTheme.titleLarge?.copyWith(
      color: _scheme.onSurface,
      fontFamily: "Pretendard",
    ),
  ),

  // Primary blue = the one main action on a screen.
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: _buttonSize,
      padding: _buttonPadding,
      shape: _buttonShape,
      textStyle: _textTheme.labelLarge,
      disabledBackgroundColor: _scheme.surfaceContainerHigh,
      disabledForegroundColor: AppColors.gray400,
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: _buttonSize,
      padding: _buttonPadding,
      shape: _buttonShape,
      textStyle: _textTheme.labelLarge,
      foregroundColor: _scheme.onSurface,
      side: BorderSide(color: _scheme.outline),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      shape: _buttonShape,
      textStyle: _textTheme.labelLarge,
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: _scheme.surfaceContainerLow,
    contentPadding: const .symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.md + 2,
    ),
    hintStyle: _textTheme.bodyLarge?.copyWith(color: _scheme.onSurfaceVariant),
    border: _inputBorder,
    enabledBorder: _inputBorder,
    focusedBorder: _inputBorder.copyWith(
      borderSide: BorderSide(color: _scheme.primary, width: 1.5),
    ),
    errorBorder: _inputBorder.copyWith(
      borderSide: BorderSide(color: _scheme.error),
    ),
    focusedErrorBorder: _inputBorder.copyWith(
      borderSide: BorderSide(color: _scheme.error, width: 1.5),
    ),
  ),

  cardTheme: CardThemeData(
    color: _scheme.surfaceContainerLowest,
    elevation: 0,
    margin: .zero,
    shape: RoundedRectangleBorder(
      borderRadius: .circular(AppRadius.lg),
      side: BorderSide(color: _scheme.outlineVariant),
    ),
  ),

  chipTheme: ChipThemeData(
    shape: const StadiumBorder(),
    side: .none,
    showCheckmark: false,
    backgroundColor: _scheme.surfaceContainer,
    selectedColor: _scheme.secondary,
    labelStyle: _textTheme.labelMedium?.copyWith(color: _scheme.onSurface),
    secondaryLabelStyle: _textTheme.labelMedium?.copyWith(
      color: _scheme.onSecondary,
    ),
  ),

  // Selected tab is ink, not blue: blue is reserved for actions.
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: _scheme.surface,
    elevation: 0,
    height: 64,
    indicatorColor: Colors.transparent,
    overlayColor: const WidgetStatePropertyAll(Colors.transparent),
    iconTheme: WidgetStateProperty.resolveWith(
      (states) => IconThemeData(
        size: 24,
        color: states.contains(WidgetState.selected)
            ? _scheme.secondary
            : AppColors.gray400,
      ),
    ),
    labelTextStyle: WidgetStateProperty.resolveWith(
      (states) => _textTheme.labelSmall?.copyWith(
        color: states.contains(WidgetState.selected)
            ? _scheme.secondary
            : AppColors.gray400,
      ),
    ),
  ),

  dividerTheme: DividerThemeData(
    color: _scheme.outlineVariant,
    thickness: 1,
    space: 1,
  ),

  snackBarTheme: SnackBarThemeData(
    behavior: .floating,
    backgroundColor: _scheme.inverseSurface,
    contentTextStyle: _textTheme.bodyMedium?.copyWith(
      color: _scheme.onInverseSurface,
    ),
    shape: RoundedRectangleBorder(borderRadius: .circular(AppRadius.md)),
  ),

  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: _scheme.surface,
    showDragHandle: true,
    dragHandleColor: _scheme.outline,
    shape: const RoundedRectangleBorder(
      borderRadius: .vertical(top: .circular(AppRadius.xl)),
    ),
  ),

  dialogTheme: DialogThemeData(
    backgroundColor: _scheme.surface,
    shape: RoundedRectangleBorder(borderRadius: .circular(AppRadius.xl)),
    titleTextStyle: _textTheme.titleLarge?.copyWith(color: _scheme.onSurface),
    contentTextStyle: _textTheme.bodyMedium?.copyWith(
      color: _scheme.onSurfaceVariant,
    ),
  ),
);
