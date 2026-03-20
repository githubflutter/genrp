import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/theme/theme.dart';
import 'package:genrp/core/ux/mixins.dart';

class UwEmpty extends StatelessWidget with Uwidget {
  const UwEmpty({
    required this.i,
    required this.autopilot,
    this.s = 0,
    super.key,
    this.p = '',
    this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
  });

  @override
  final int vid = 9;

  @override
  final int s;

  @override
  final int i;

  final Autopilot autopilot;
  final String p;
  final String? title;
  final String? message;
  final IconData icon;

  @override
  final String n = 'empty';

  @override
  Widget build(BuildContext context) {
    final resolvedTitle = title ?? (p.isNotEmpty ? p : 'Nothing Here');
    final resolvedMessage =
        message ?? (s == 1 ? 'There is no data to display yet.' : '');
    return Center(
      child: Padding(
        padding: UxTheme.panelPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 32, color: UxTheme.colors(context).outline),
            const SizedBox(height: 12),
            Text(resolvedTitle, style: UxTheme.titleStyle(context)),
            if (resolvedMessage.isNotEmpty) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                resolvedMessage,
                textAlign: TextAlign.center,
                style: UxTheme.bodyStyle(context),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
