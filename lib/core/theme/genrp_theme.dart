import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class GenrpTheme {
  GenrpTheme._();

  static const double fontXl = 15;
  static const double fontLl = 13;
  static const double fontNm = 12;
  static const double fontXs = 11;

  static const Color _seed = Color(0xFF6EA8FE);
  static const Color _surface = Color(0xFF0C1218);
  static const Color _surfaceAlt = Color(0xFF151E29);
  static const Color _surfaceSoft = Color(0xFF1C2735);
  static const Color _outline = Color(0xFF425264);
  static const BorderRadius _radius = BorderRadius.all(Radius.circular(18));

  static bool isDesktopPlatform(TargetPlatform platform) {
    return platform == TargetPlatform.macOS ||
        platform == TargetPlatform.windows ||
        platform == TargetPlatform.linux;
  }

  static double toolbarHeightFor(TargetPlatform platform) {
    return isDesktopPlatform(platform) ? 36 : 48;
  }

  static double statusBarHeightFor(TargetPlatform platform) {
    return isDesktopPlatform(platform) ? 32 : 36;
  }

  static double statusBarHeightOf(BuildContext context) {
    return statusBarHeightFor(Theme.of(context).platform);
  }

  static double toolbarHeightOf(BuildContext context) {
    return toolbarHeightFor(Theme.of(context).platform);
  }

  static Color panelColorOf(BuildContext context) {
    final theme = Theme.of(context);
    return theme.cardTheme.color ?? theme.colorScheme.surface;
  }

  static Color workspaceColorOf(BuildContext context) {
    final theme = Theme.of(context);
    return Color.alphaBlend(
      theme.colorScheme.primary.withValues(alpha: 0.03),
      theme.colorScheme.surface,
    );
  }

  static Color workspaceAltColorOf(BuildContext context) {
    final theme = Theme.of(context);
    return Color.alphaBlend(
      theme.colorScheme.secondary.withValues(alpha: 0.04),
      panelColorOf(context),
    );
  }

  static ThemeData lightTheme() {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.light,
    );
    return _buildTheme(
      baseScheme.copyWith(
        primary: const Color(0xFF215A96),
        secondary: const Color(0xFF955100),
        surface: const Color(0xFFF7F9FC),
      ),
    );
  }

  static ThemeData darkTheme() {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
    );
    return _buildTheme(
      baseScheme.copyWith(
        primary: const Color(0xFF9CC7FF),
        onPrimary: const Color(0xFF08213F),
        secondary: const Color(0xFFFFC788),
        onSecondary: const Color(0xFF3E2400),
        surface: _surface,
        onSurface: const Color(0xFFE8EEF7),
        outline: _outline,
      ),
    );
  }

  static ThemeData _buildTheme(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    final platform = defaultTargetPlatform;
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
    );
    final textTheme = baseTheme.textTheme.copyWith(
      displayLarge: baseTheme.textTheme.displayLarge?.copyWith(
        fontSize: fontXl,
      ),
      displayMedium: baseTheme.textTheme.displayMedium?.copyWith(
        fontSize: fontXl,
      ),
      displaySmall: baseTheme.textTheme.displaySmall?.copyWith(
        fontSize: fontXl,
      ),
      headlineLarge: baseTheme.textTheme.headlineLarge?.copyWith(
        fontSize: fontXl,
      ),
      headlineMedium: baseTheme.textTheme.headlineMedium?.copyWith(
        fontSize: fontXl,
      ),
      headlineSmall: baseTheme.textTheme.headlineSmall?.copyWith(
        fontSize: fontXl,
      ),
      titleLarge: baseTheme.textTheme.titleLarge?.copyWith(fontSize: fontXl),
      titleMedium: baseTheme.textTheme.titleMedium?.copyWith(fontSize: fontLl),
      titleSmall: baseTheme.textTheme.titleSmall?.copyWith(fontSize: fontLl),
      bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(fontSize: fontNm),
      bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(fontSize: fontNm),
      bodySmall: baseTheme.textTheme.bodySmall?.copyWith(fontSize: fontXs),
      labelLarge: baseTheme.textTheme.labelLarge?.copyWith(fontSize: fontNm),
      labelMedium: baseTheme.textTheme.labelMedium?.copyWith(fontSize: fontNm),
      labelSmall: baseTheme.textTheme.labelSmall?.copyWith(fontSize: fontXs),
    );

    final panelColor = isDark ? _surfaceAlt : Colors.white;
    final softPanelColor = isDark ? _surfaceSoft : const Color(0xFFF0F4F9);
    final borderSide = BorderSide(
      color: scheme.outline.withValues(alpha: isDark ? 0.68 : 0.42),
    );
    final outlineBorder = OutlineInputBorder(
      borderRadius: _radius,
      borderSide: borderSide,
    );
    final buttonShape = RoundedRectangleBorder(borderRadius: _radius);

    return baseTheme.copyWith(
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      platform: platform,
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,
      appBarTheme: baseTheme.appBarTheme.copyWith(
        toolbarHeight: toolbarHeightFor(platform),
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
      bottomAppBarTheme: BottomAppBarThemeData(
        color: panelColor,
        height: statusBarHeightFor(platform),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: panelColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: _radius, side: borderSide),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outline.withValues(alpha: isDark ? 0.45 : 0.22),
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: softPanelColor,
        border: outlineBorder,
        enabledBorder: outlineBorder,
        focusedBorder: outlineBorder.copyWith(
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
        errorBorder: outlineBorder.copyWith(
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: outlineBorder.copyWith(
          borderSide: BorderSide(color: scheme.error, width: 1.6),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.secondary,
        textColor: scheme.onSurface,
        selectedColor: scheme.onSurface,
        selectedTileColor: scheme.primary.withValues(
          alpha: isDark ? 0.16 : 0.1,
        ),
        shape: RoundedRectangleBorder(borderRadius: _radius),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: softPanelColor,
        contentTextStyle: TextStyle(color: scheme.onSurface),
      ),
      tabBarTheme: baseTheme.tabBarTheme.copyWith(
        dividerColor: Colors.transparent,
        indicatorColor: scheme.secondary,
        labelColor: scheme.onSurface,
        unselectedLabelColor: scheme.onSurface.withValues(alpha: 0.65),
        labelStyle: textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: textTheme.labelMedium,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.secondaryContainer,
        foregroundColor: scheme.onSecondaryContainer,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: buttonShape,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: buttonShape,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: buttonShape,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          side: borderSide,
        ),
      ),
    );
  }
}
