import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/ux/uwidget/uwtab.dart';

class GenAuthoringPanels extends StatelessWidget {
  const GenAuthoringPanels({
    required this.i,
    required this.autopilot,
    required this.activeIndex,
    required this.onChanged,
    required this.minorBuilder,
    required this.listBuilder,
    required this.detailBuilder,
    this.labels = const <String>['Rows', 'Editor', 'Split'],
    this.minorWidth = 280,
    this.minorStackHeight = 260,
    this.outerBreakpoint = 1100,
    this.innerBreakpoint = 920,
    this.gap = 16,
    super.key,
  });

  final int i;
  final Autopilot autopilot;
  final int activeIndex;
  final ValueChanged<int> onChanged;
  final WidgetBuilder minorBuilder;
  final WidgetBuilder listBuilder;
  final WidgetBuilder detailBuilder;
  final List<String> labels;
  final double minorWidth;
  final double minorStackHeight;
  final double outerBreakpoint;
  final double innerBreakpoint;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final minorPanel = minorBuilder(context);
        final majorPanel = _buildMajorPanel(context);
        if (constraints.maxWidth < outerBreakpoint) {
          return Column(
            children: <Widget>[
              SizedBox(height: minorStackHeight, child: minorPanel),
              SizedBox(height: gap),
              Expanded(child: majorPanel),
            ],
          );
        }
        return Row(
          children: <Widget>[
            SizedBox(width: minorWidth, child: minorPanel),
            SizedBox(width: gap),
            Expanded(child: majorPanel),
          ],
        );
      },
    );
  }

  Widget _buildMajorPanel(BuildContext context) {
    return UwTab(
      i: i,
      autopilot: autopilot,
      s: 10,
      activeIndex: activeIndex,
      labels: labels,
      onChanged: onChanged,
      children: <Widget>[
        listBuilder(context),
        _buildEditorLayout(context, leftFlex: 3, rightFlex: 2),
        _buildEditorLayout(context, leftFlex: 1, rightFlex: 1),
      ],
    );
  }

  Widget _buildEditorLayout(
    BuildContext context, {
    required int leftFlex,
    required int rightFlex,
  }) {
    final list = listBuilder(context);
    final detail = detailBuilder(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < innerBreakpoint) {
          return Column(
            children: <Widget>[
              Expanded(child: list),
              SizedBox(height: gap),
              Expanded(child: detail),
            ],
          );
        }
        return Row(
          children: <Widget>[
            Expanded(flex: leftFlex, child: list),
            SizedBox(width: gap),
            Expanded(flex: rightFlex, child: detail),
          ],
        );
      },
    );
  }
}
