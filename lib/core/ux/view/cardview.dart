import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/theme/theme.dart';
import 'package:genrp/core/ux/v.dart';
import 'package:genrp/core/ux/view/empty.dart';

class UxCardView extends StatelessWidget with V {
  const UxCardView({required this.i, required this.autopilot, this.s = 0, super.key, this.p = '', this.title, this.child, this.footer, this.padding = const EdgeInsets.all(16)});

  @override
  final int vid = 7;

  @override
  final int s;

  @override
  final int i;

  final Autopilot autopilot;
  final String p;
  final String? title;
  final Widget? child;
  final Widget? footer;
  final EdgeInsetsGeometry padding;

  @override
  final String n = 'cardview';

  @override
  Widget build(BuildContext context) {
    final resolvedTitle = title ?? (p.isNotEmpty ? p : '');
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: s > 0 ? s.toDouble() : 1,
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (resolvedTitle.isNotEmpty) ...<Widget>[Text(resolvedTitle, style: UxTheme.titleStyle(context)), const SizedBox(height: 12)],
            child ?? UxEmptyView(i: i, autopilot: autopilot, p: 'Empty card'),
            if (footer != null) ...<Widget>[const SizedBox(height: 12), footer!],
          ],
        ),
      ),
    );
  }
}
