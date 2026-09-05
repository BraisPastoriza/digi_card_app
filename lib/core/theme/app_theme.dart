import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Surface ramp for the dark theme. Kept as named steps so widgets can pick a
/// depth instead of inventing one-off greys.
abstract final class AppSurfaces {
  static const background = Color(0xFF0E0E12);
  static const surface = Color(0xFF16161D);
  static const surfaceHigh = Color(0xFF1E1E28);
  static const surfaceHighest = Color(0xFF272733);
  static const outline = Color(0xFF32323F);
  static const outlineStrong = Color(0xFF474756);
}

abstract final class AppTheme {
  /// Digivice orange-amber, used for primary actions and selection.
  static const seed = Color(0xFFFF8A3D);

  static ThemeData dark() {
    const scheme = ColorScheme.dark(
      primary: seed,
      onPrimary: Color(0xFF261200),
      primaryContainer: Color(0xFF4A2A0C),
      onPrimaryContainer: Color(0xFFFFDCC2),
      secondary: Color(0xFF6FD3E6),
      onSecondary: Color(0xFF00272E),
      surface: AppSurfaces.surface,
      onSurface: Color(0xFFE6E5EA),
      onSurfaceVariant: Color(0xFF9E9DAB),
      surfaceContainerLowest: AppSurfaces.background,
      surfaceContainer: AppSurfaces.surfaceHigh,
      surfaceContainerHigh: AppSurfaces.surfaceHigh,
      surfaceContainerHighest: AppSurfaces.surfaceHighest,
      outline: AppSurfaces.outline,
      outlineVariant: AppSurfaces.outlineStrong,
      error: Color(0xFFFF6B6B),
      onError: Color(0xFF2B0000),
    );

    final base = ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppSurfaces.background,
      canvasColor: AppSurfaces.background,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppSurfaces.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          color: Color(0xFFE6E5EA),
        ),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      cardTheme: CardThemeData(
        color: AppSurfaces.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppSurfaces.outline),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppSurfaces.outline,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppSurfaces.surfaceHigh,
        selectedColor: scheme.primaryContainer,
        side: const BorderSide(color: AppSurfaces.outline),
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppSurfaces.surfaceHigh,
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppSurfaces.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppSurfaces.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppSurfaces.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        elevation: 0,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? scheme.onSurface
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppSurfaces.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppSurfaces.surfaceHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: AppSurfaces.surfaceHigh,
          selectedBackgroundColor: scheme.primaryContainer,
          side: const BorderSide(color: AppSurfaces.outline),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppSurfaces.surfaceHighest,
        contentTextStyle: TextStyle(color: scheme.onSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: Color(0xFF9E9DAB),
        titleTextStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE6E5EA),
        ),
        subtitleTextStyle: TextStyle(fontSize: 13, color: Color(0xFF9E9DAB)),
      ),
    );
  }
}
