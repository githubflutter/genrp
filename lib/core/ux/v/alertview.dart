import 'package:flutter/material.dart';
import 'package:genrp/core/ux/a/pilot.dart';
import 'package:genrp/core/ux/theme.dart';
import 'package:genrp/core/ux/v/v.dart';

class UxAlertView extends StatelessWidget with V {
  const UxAlertView({
    required this.i,
    required this.autopilot,
    this.s = 0,
    super.key,
    this.p = '',
    this.title,
    this.message,
    this.actions = const <Widget>[],
  });

  @override
  final int vid = 11;

  @override
  final int s;

  @override
  final int i;

  final UxPilot autopilot;
  final String p;
  final String? title;
  final String? message;
  final List<Widget> actions;

  @override
  final String n = 'alertview';

  @override
  Widget build(BuildContext context) {
    final colorScheme = UxTheme.colors(context);
    final resolvedTitle = title ?? 'Alert';
    final resolvedMessage = message ?? p;
    final accent = switch (s) {
      1 => colorScheme.primary,
      2 => Colors.green.shade700,
      3 => Colors.orange.shade700,
      4 => colorScheme.error,
      _ => colorScheme.outline,
    };
    return Container(
      padding: UxTheme.panelPadding,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        border: Border.all(color: accent),
        borderRadius: UxTheme.radius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(resolvedTitle, style: UxTheme.titleStyle(context)),
          if (resolvedMessage.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Text(resolvedMessage, style: UxTheme.bodyStyle(context)),
          ],
          if (actions.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: actions),
          ],
        ],
      ),
    );
  }
}
