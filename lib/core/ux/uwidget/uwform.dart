import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/theme/theme.dart';
import 'package:genrp/core/ux/uwidget/uwempty.dart';
import 'package:genrp/core/ux/mixins.dart';

class UwForm extends StatelessWidget with Ux {
  const UwForm({required this.i, required this.autopilot, this.s = 0, super.key, this.p = '', this.title, this.children = const <Widget>[], this.footer});

  final int uwid = 5;
  final int s;

  @override
  final int i;

  final Autopilot autopilot;
  final String p;
  final String? title;
  final List<Widget> children;
  final Widget? footer;

  @override
  final String n = 'from';

  @override
  Widget build(BuildContext context) {
    final resolvedTitle = title ?? p;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (resolvedTitle.isNotEmpty) ...<Widget>[Text(resolvedTitle, style: UxTheme.titleStyle(context)), const SizedBox(height: 12)],
        if (children.isEmpty) UwEmpty(i: i, autopilot: autopilot, p: 'No form content') else ...children,
        if (footer != null) ...<Widget>[const SizedBox(height: 16), footer!],
      ],
    );
  }
}
