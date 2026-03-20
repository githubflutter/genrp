import 'package:flutter/material.dart';
import 'package:genrp/core/theme/genrp_theme.dart';

class UxTheme {
  UxTheme._();

  static const BorderRadius radius = BorderRadius.all(Radius.circular(18));
  static const EdgeInsets panelPadding = EdgeInsets.all(16);
  static const EdgeInsets compactPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 10,
  );
  static const double toolbarHeight = 56;

  static ThemeData lightTheme() => GenrpTheme.lightTheme();

  static ThemeData darkTheme() => GenrpTheme.darkTheme();

  static ThemeData of(BuildContext context) => Theme.of(context);

  static ColorScheme colors(BuildContext context) =>
      Theme.of(context).colorScheme;

  static Color panelColor(BuildContext context) =>
      GenrpTheme.panelColorOf(context);

  static Color workspaceColor(BuildContext context) =>
      GenrpTheme.workspaceColorOf(context);

  static Color workspaceAltColor(BuildContext context) =>
      GenrpTheme.workspaceAltColorOf(context);

  static Color outlineColor(BuildContext context, {double alpha = 0.5}) =>
      colors(context).outline.withValues(alpha: alpha);

  static BoxDecoration panelDecoration(
    BuildContext context, {
    Color? color,
    double outlineAlpha = 0.5,
  }) {
    return BoxDecoration(
      color: color ?? panelColor(context),
      borderRadius: radius,
      border: Border.all(color: outlineColor(context, alpha: outlineAlpha)),
    );
  }

  static BoxDecoration softPanelDecoration(
    BuildContext context, {
    Color? color,
    double outlineAlpha = 0.36,
  }) {
    return BoxDecoration(
      color: color ?? colors(context).surfaceContainerHighest,
      borderRadius: radius,
      border: Border.all(color: outlineColor(context, alpha: outlineAlpha)),
    );
  }

  static TextStyle? titleStyle(BuildContext context) =>
      of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700);

  static TextStyle? bodyStyle(BuildContext context) =>
      of(context).textTheme.bodyMedium;

  static TextStyle? keyStyle(BuildContext context) =>
      of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600);
}
