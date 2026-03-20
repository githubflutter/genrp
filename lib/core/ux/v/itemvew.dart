import 'package:flutter/material.dart';
import 'package:genrp/core/ux/a/pilot.dart';
import 'package:genrp/core/ux/theme.dart';
import 'package:genrp/core/ux/v/v.dart';

class UxItemVew extends StatelessWidget with V {
  const UxItemVew({
    required this.i,
    required this.autopilot,
    this.s = 0,
    super.key,
    this.p = '',
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });

  @override
  final int vid = 8;

  @override
  final int s;

  @override
  final int i;

  final UxPilot autopilot;
  final String p;
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  final String n = 'itemvew';

  @override
  Widget build(BuildContext context) {
    final resolvedTitle = title ?? (p.isNotEmpty ? p : n);
    final content = ListTile(
      contentPadding: EdgeInsets.zero,
      leading: leading,
      trailing: trailing,
      title: Text(resolvedTitle),
      subtitle: subtitle == null ? null : Text(subtitle!),
      onTap: onTap,
    );
    if (s == 1) {
      return Card(
        child: Padding(padding: const EdgeInsets.all(8), child: content),
      );
    }
    return DefaultTextStyle(
      style: UxTheme.bodyStyle(context) ?? const TextStyle(),
      child: content,
    );
  }
}
