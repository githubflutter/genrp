import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/ux/uwidget/uwtoolbar.dart';

class TcrudHeader extends StatelessWidget {
  const TcrudHeader({
    required this.i,
    required this.autopilot,
    required this.mode,
    required this.currentViewMode,
    required this.availableViewModes,
    required this.onViewModeChanged,
    required this.onBack,
    required this.onNew,
    required this.onInspect,
    required this.onEdit,
    required this.onClear,
    this.oid = '',
    this.canInspect = false,
    super.key,
  });

  final int i;
  final Autopilot autopilot;
  final String mode;
  final int currentViewMode;
  final List<int> availableViewModes;
  final ValueChanged<int> onViewModeChanged;
  final VoidCallback onBack;
  final VoidCallback onNew;
  final VoidCallback? onInspect;
  final VoidCallback? onEdit;
  final VoidCallback onClear;
  final String oid;
  final bool canInspect;

  @override
  Widget build(BuildContext context) {
    return UwToolbar(
      i: i,
      autopilot: autopilot,
      s: 2,
      leftChildren: _buildLeftChildren(),
      rightChildren: _buildRightChildren(),
    );
  }

  List<Widget> _buildLeftChildren() {
    return <Widget>[
      ..._buildLeadControl(),
      if (oid.isNotEmpty) Text('OID $oid'),
    ];
  }

  List<Widget> _buildRightChildren() {
    return <Widget>[
      TextButton(onPressed: onNew, child: const Text('New')),
      TextButton(
        onPressed: canInspect ? onInspect : null,
        child: const Text('Inspect'),
      ),
      TextButton(
        onPressed: canInspect ? onEdit : null,
        child: const Text('Edit'),
      ),
      TextButton(onPressed: onClear, child: const Text('Clear')),
    ];
  }

  List<Widget> _buildLeadControl() {
    if (mode == 'edit' || mode == 'create' || mode == 'inspect') {
      return <Widget>[
        IconButton.filledTonal(
          tooltip: 'Back',
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_outlined),
        ),
      ];
    }

    if (availableViewModes.length <= 1) {
      return const <Widget>[];
    }
    final currentIndex = availableViewModes.indexOf(currentViewMode);
    final normalizedIndex = currentIndex < 0 ? 0 : currentIndex;
    final nextMode =
        availableViewModes[(normalizedIndex + 1) % availableViewModes.length];

    return <Widget>[
      IconButton.filledTonal(
        tooltip:
            'Switch view (${_viewLabelFor(currentViewMode)} -> ${_viewLabelFor(nextMode)})',
        onPressed: () => onViewModeChanged(nextMode),
        icon: Icon(_viewIconFor(currentViewMode)),
      ),
    ];
  }

  String _viewLabelFor(int mode) => switch (mode) {
    1 => 'List',
    2 => 'Grid',
    3 => 'Table',
    _ => 'View $mode',
  };

  IconData _viewIconFor(int mode) => switch (mode) {
    1 => Icons.view_list_outlined,
    2 => Icons.grid_view_outlined,
    3 => Icons.table_rows_outlined,
    _ => Icons.dashboard_outlined,
  };
}
