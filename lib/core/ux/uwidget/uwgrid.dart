import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/ux/uwidget/uwempty.dart';
import 'package:genrp/core/ux/mixins.dart';

class UwGrid extends StatelessWidget with Uwidget {
  const UwGrid({
    required this.i,
    required this.autopilot,
    this.s = 0,
    super.key,
    this.p = '',
    this.children = const <Widget>[],
    this.crossAxisCount = 2,
    this.spacing = 12,
    this.childAspectRatio = 1.2,
  });

  @override
  final int vid = 2;

  @override
  final int s;

  @override
  final int i;

  final Autopilot autopilot;
  final String p;
  final List<Widget> children;
  final int crossAxisCount;
  final double spacing;
  final double childAspectRatio;

  @override
  final String n = 'grid';

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return UwEmpty(
        i: i,
        autopilot: autopilot,
        p: p.isNotEmpty ? p : 'Empty grid',
      );
    }
    final effectiveCount = s > 1 ? s : crossAxisCount;
    return GridView.count(
      crossAxisCount: effectiveCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
      childAspectRatio: childAspectRatio,
      children: children,
    );
  }
}
