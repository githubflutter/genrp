import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/ux/view/toolbarview.dart';

class TcrudFooter extends StatelessWidget {
  const TcrudFooter({
    required this.i,
    required this.autopilot,
    required this.totalCount,
    this.activeLabel,
    this.selectedCount = 0,
    this.summaryText = '',
    super.key,
  });

  final int i;
  final Autopilot autopilot;
  final int totalCount;
  final String? activeLabel;
  final int selectedCount;
  final String summaryText;

  @override
  Widget build(BuildContext context) {
    return UxToolbarView(
      i: i,
      autopilot: autopilot,
      s: 2,
      leftChildren: <Widget>[
        Text('Results: $totalCount'),
        if (activeLabel != null && activeLabel!.isNotEmpty)
          Text('Active: $activeLabel'),
        if (selectedCount > 0) Text('Selected: $selectedCount'),
      ],
      rightChildren: <Widget>[
        if (summaryText.isNotEmpty) Text('Summary: $summaryText'),
      ],
    );
  }
}
