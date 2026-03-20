import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/theme/theme.dart';
import 'package:genrp/core/ux/mixins.dart';

class UwToolbar extends StatelessWidget with Uwidget {
  const UwToolbar({
    required this.i,
    required this.autopilot,
    this.s = 0,
    this.p = '',
    this.children = const <Widget>[],
    this.leftChildren = const <Widget>[],
    this.middleChildren = const <Widget>[],
    this.rightChildren = const <Widget>[],
    super.key,
  });

  @override
  final int vid = 4;

  @override
  final int s;

  @override
  final int i;

  final Autopilot autopilot;
  final String p;
  final List<Widget> children;
  final List<Widget> leftChildren;
  final List<Widget> middleChildren;
  final List<Widget> rightChildren;

  @override
  final String n = 'toolbar';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: UxTheme.toolbarHeight,
      padding: UxTheme.compactPadding,
      decoration: UxTheme.softPanelDecoration(context),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return _buildContent(constraints);
        },
      ),
    );
  }

  Widget _buildContent(BoxConstraints constraints) {
    final leftGroup = leftChildren;
    final middleGroup = middleChildren;
    final rightGroup = rightChildren;

    if (children.isEmpty &&
        leftGroup.isEmpty &&
        middleGroup.isEmpty &&
        rightGroup.isEmpty) {
      return const SizedBox.shrink();
    }

    switch (s) {
      case 1:
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: children,
        );
      case -1:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: children,
        );
      case 2:
        return Row(
          children: <Widget>[
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.start,
                  children: leftGroup,
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: rightGroup,
                ),
              ),
            ),
          ],
        );
      case -2:
        return Row(
          children: <Widget>[
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: leftGroup,
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.start,
                  children: rightGroup,
                ),
              ),
            ),
          ],
        );
      case 3:
        return Row(
          children: <Widget>[
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.start,
                  children: leftGroup,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: middleGroup,
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: rightGroup,
                ),
              ),
            ),
          ],
        );
      case 10:
      case -10:
        final alignment = s == 10
            ? Alignment.centerLeft
            : Alignment.centerRight;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Align(
              alignment: alignment,
              child: Row(mainAxisSize: MainAxisSize.min, children: children),
            ),
          ),
        );
      case 20:
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: IntrinsicWidth(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.start,
                    children: leftGroup,
                  ),
                  const SizedBox(width: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.end,
                    children: rightGroup,
                  ),
                ],
              ),
            ),
          ),
        );
      case -20:
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: IntrinsicWidth(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.end,
                      children: leftGroup,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.start,
                      children: rightGroup,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      case 30:
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.start,
                  children: leftGroup,
                ),
                const SizedBox(width: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: middleGroup,
                ),
                const SizedBox(width: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: rightGroup,
                ),
              ],
            ),
          ),
        );
      default:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children
              .map<Widget>(
                (Widget child) => Expanded(child: Center(child: child)),
              )
              .toList(),
        );
    }
  }
}
