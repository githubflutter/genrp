import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/theme/theme.dart';
import 'package:genrp/core/ux/mixins.dart';
import 'package:genrp/core/ux/uwidget/uwempty.dart';
import 'package:genrp/core/ux/uwidget/uwtoolbar.dart';

class UwTab extends StatelessWidget with Uwidget {
  UwTab({
    required this.i,
    required this.autopilot,
    this.s = 1,
    this.p = '',
    this.activeIndex = 0,
    this.labels = const <String>[],
    this.children = const <Widget>[],
    this.onChanged,
    super.key,
  }) : assert(
         labels.isEmpty || labels.length == children.length,
         'UwTab labels length must match children length',
       );

  @override
  final int vid = 13;

  @override
  final int s;

  @override
  final int i;

  final Autopilot autopilot;
  final String p;
  final int activeIndex;
  final List<String> labels;
  final List<Widget> children;
  final ValueChanged<int>? onChanged;

  @override
  final String n = 'tab';

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return UwEmpty(
        i: i,
        autopilot: autopilot,
        p: p.isNotEmpty ? p : 'No tabs',
      );
    }

    final currentIndex = activeIndex.clamp(0, children.length - 1);
    final tabLabels = labels.isEmpty
        ? List<String>.generate(
            children.length,
            (int index) => 'Tab ${index + 1}',
          )
        : labels;

    final tabButtons = List<Widget>.generate(children.length, (int index) {
      final active = index == currentIndex;
      final palette = UxTheme.colors(context);
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onChanged == null ? null : () => onChanged!(index),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: active
                ? palette.primary.withValues(alpha: 0.18)
                : Colors.transparent,
            borderRadius: UxTheme.radius,
            border: Border.all(
              color: active
                  ? palette.primary.withValues(alpha: 0.4)
                  : UxTheme.outlineColor(context, alpha: 0.25),
            ),
          ),
          child: Padding(
            padding: UxTheme.compactPadding,
            child: Text(
              tabLabels[index],
              style: (UxTheme.bodyStyle(context) ?? const TextStyle()).copyWith(
                color: active ? palette.primary : palette.onSurface,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      );
    });

    final content = Container(
      decoration: UxTheme.panelDecoration(context),
      padding: UxTheme.panelPadding,
      child: children[currentIndex],
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final header = UwToolbar(
          i: i,
          autopilot: autopilot,
          s: s,
          p: p,
          children: tabButtons,
        );

        if (constraints.maxHeight.isFinite) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              header,
              const SizedBox(height: 12),
              Expanded(child: content),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[header, const SizedBox(height: 12), content],
        );
      },
    );
  }
}
