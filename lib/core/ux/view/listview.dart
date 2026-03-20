import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/theme/theme.dart';
import 'package:genrp/core/ux/v.dart';
import 'package:genrp/core/ux/view/empty.dart';

class UxListView extends StatelessWidget with V {
  const UxListView({required this.i, required this.autopilot, this.s = 0, super.key, this.p = '', this.title, this.children = const <Widget>[]});

  @override
  final int vid = 1;

  @override
  final int s;

  @override
  final int i;

  final Autopilot autopilot;
  final String p;
  final String? title;
  final List<Widget> children;

  @override
  final String n = 'listview';

  @override
  Widget build(BuildContext context) {
    final resolvedTitle = title ?? p;
    if (children.isEmpty) {
      return UxEmptyView(i: i, autopilot: autopilot, p: resolvedTitle.isNotEmpty ? resolvedTitle : 'Empty list');
    }
    final listChildren = <Widget>[
      if (resolvedTitle.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(resolvedTitle, style: UxTheme.titleStyle(context)),
        ),
    ];
    if (s == 1) {
      for (var index = 0; index < children.length; index++) {
        listChildren.add(children[index]);
        if (index < children.length - 1) {
          listChildren.add(const Divider(height: 1));
        }
      }
    } else {
      listChildren.addAll(children);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: listChildren);
  }
}
