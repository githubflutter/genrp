import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/theme/theme.dart';
import 'package:genrp/core/ux/v.dart';
import 'package:genrp/core/ux/view/empty.dart';

class UxFromView extends StatelessWidget with V {
  const UxFromView({required this.i, required this.autopilot, this.s = 0, super.key, this.p = '', this.title, this.children = const <Widget>[], this.footer});

  @override
  final int vid = 5;

  @override
  final int s;

  @override
  final int i;

  final Autopilot autopilot;
  final String p;
  final String? title;
  final List<Widget> children;
  final Widget? footer;

  @override
  final String n = 'fromview';

  @override
  Widget build(BuildContext context) {
    final resolvedTitle = title ?? p;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (resolvedTitle.isNotEmpty) ...<Widget>[Text(resolvedTitle, style: UxTheme.titleStyle(context)), const SizedBox(height: 12)],
        if (children.isEmpty) UxEmptyView(i: i, autopilot: autopilot, p: 'No form content') else ...children,
        if (footer != null) ...<Widget>[const SizedBox(height: 16), footer!],
      ],
    );
  }
}
