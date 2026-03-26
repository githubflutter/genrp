import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/model/uschema/ux_spec.dart';
import 'package:genrp/core/theme/theme.dart';
import 'package:genrp/core/ux/mixins.dart';
import 'package:genrp/core/ux/uwidget/uwalert.dart';
import 'package:genrp/core/ux/uwidget/uwcollection.dart';
import 'package:genrp/core/ux/uwidget/uwempty.dart';
import 'package:genrp/core/ux/uwidget/uwform.dart';
import 'package:genrp/core/ux/uwidget/uwplist.dart';
import 'package:genrp/core/ux/uwidget/uwtoolbar.dart';

class Tworkspace extends StatelessWidget with Ux {
  const Tworkspace({
    required this.i,
    required this.autopilot,
    required this.meta,
    required this.slots,
    this.s = 0,
    this.oid = '',
    this.collectionChildren = const <Widget>[],
    this.formChildren = const <Widget>[],
    this.formFooter,
    super.key,
  });

  final int tid = 1;
  final int s;

  @override
  final int i;

  final Autopilot autopilot;
  final UxWorkspaceMeta meta;
  final UxWorkspaceSlots slots;
  final String oid;
  final List<Widget> collectionChildren;
  final List<Widget> formChildren;
  final Widget? formFooter;

  @override
  final String n = 'tworkspace';

  String get summaryText => meta.summaryText;
  String get collectionTitle => meta.collectionTitle;
  List<List<Object?>> get collectionRows => meta.collectionRows;
  List<String> get collectionColumns => meta.collectionColumns;
  List<int> get collectionViewModes => meta.collectionViewModes;
  Map<String, Object?> get properties => meta.properties;
  String get emptyTitle => meta.emptyTitle;
  String get emptyMessage => meta.emptyMessage;
  String get defaultAlertMessage => meta.defaultAlertMessage;
  int get collectionFlex => meta.collectionFlex;
  int get detailFlex => meta.detailFlex;
  int? get topToolbarI => slots.topToolbar.i;
  int get topToolbarStyle => slots.topToolbar.style;
  int? get bottomToolbarI => slots.bottomToolbar.i;
  int get bottomToolbarStyle => slots.bottomToolbar.style;
  int? get collectionI => slots.collection.i;
  int get collectionStyle => slots.collection.style;
  int? get plistI => slots.plist.i;
  int get plistStyle => slots.plist.style;
  int? get formI => slots.form.i;
  int get formStyle => slots.form.style;
  int? get emptyI => slots.empty.i;
  int get emptyStyle => slots.empty.style;
  int? get alertI => slots.alert.i;
  int get alertStyle => slots.alert.style;

  @override
  Widget build(BuildContext context) {
    final initialViewMode = collectionViewModes.contains(3)
        ? 3
        : collectionViewModes.isNotEmpty
        ? collectionViewModes.first
        : 3;
    return UxTemplateHost(
      i: i,
      autopilot: autopilot,
      initialState: <String, dynamic>{'mode': 'browse', 'viewmode': initialViewMode, 'selectionmode': 'single', 'activeid': null, 'activeindex': null, 'selectedids': const <Object?>[]},
      builder: (BuildContext context, int runtimeid) {
        return AnimatedBuilder(
          animation: autopilot,
          builder: (BuildContext context, Widget? child) {
            final mode = autopilot.state.rt<String>(runtimeid, 'mode') ?? 'browse';
            final viewMode = autopilot.state.rt<int>(runtimeid, 'viewmode') ?? 3;
            final activeId = autopilot.state.rt<Object?>(runtimeid, 'activeid');
            final activeIndex = autopilot.state.rt<int>(runtimeid, 'activeindex');
            final selectedIds = autopilot.state.rt<List<dynamic>>(runtimeid, 'selectedids') ?? const <dynamic>[];
            final totalCount = autopilot.state.rt<int>(runtimeid, 'totalcount') ?? collectionRows.length;
            final errorMessage = autopilot.state.rt<String>(runtimeid, 'error');
            final activeLabel = _labelForIndex(activeIndex);
            final activeProperties = _propertiesForIndex(activeIndex);
            final canInspect = collectionRows.isNotEmpty;
            final resolvedIndex = activeIndex ?? (canInspect ? 0 : null);
            final resolvedId = _idForIndex(resolvedIndex);
            final allowedViewModes = _allowedViewModes();

            final collection = UwCollection(
              i: collectionI ?? i * 100 + 10,
              autopilot: autopilot,
              s: collectionI == null ? viewMode : collectionStyle,
              p: collectionTitle,
              columns: collectionColumns,
              rows: collectionRows,
              selectedIndex: activeIndex,
              onSelectIndex: (int index) {
                _selectIndex(runtimeid, index);
              },
              children: collectionChildren,
            );

            final detail = _buildDetail(mode: mode, activeId: activeId, activeIndex: activeIndex, properties: activeProperties, errorMessage: errorMessage);

            return LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final showCollectionBody = errorMessage == null || errorMessage.isEmpty ? mode == 'browse' : false;
                final bodyChild = showCollectionBody
                    ? collection
                    : Container(
                        decoration: UxTheme.softPanelDecoration(context),
                        child: SingleChildScrollView(padding: UxTheme.panelPadding, child: detail),
                      );
                final mainBody = constraints.hasBoundedHeight ? Expanded(child: bodyChild) : SizedBox(height: 760, child: bodyChild);

                final topToolbar = _buildTopToolbar(
                  mode: mode,
                  currentViewMode: viewMode,
                  availableViewModes: allowedViewModes,
                  canInspect: canInspect,
                  runtimeid: runtimeid,
                  activeId: activeId,
                  activeIndex: activeIndex,
                  resolvedId: resolvedId,
                  resolvedIndex: resolvedIndex,
                );
                final bottomToolbar = _buildBottomToolbar(
                  totalCount: totalCount,
                  activeLabel: activeLabel,
                  selectedCount: selectedIds.length,
                );
                final bodyColumn = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    if (topToolbar case final Widget toolbar) ...<Widget>[
                      toolbar,
                      const SizedBox(height: 12),
                    ],
                    mainBody,
                    if (bottomToolbar case final Widget toolbar) ...<Widget>[
                      const SizedBox(height: 12),
                      toolbar,
                    ],
                  ],
                );

                return bodyColumn;
              },
            );
          },
        );
      },
    );
  }

  Widget _buildDetail({required String mode, required Object? activeId, required int? activeIndex, required Map<String, Object?> properties, required String? errorMessage}) {
    if (errorMessage != null && errorMessage.isNotEmpty) {
      return UwAlert(i: alertI ?? i * 100 + 14, autopilot: autopilot, s: alertI == null ? 4 : alertStyle, title: 'Error', message: errorMessage.isNotEmpty ? errorMessage : defaultAlertMessage);
    }

    if (mode == 'create' || mode == 'edit') {
      return UwForm(i: formI ?? i * 100 + 13, autopilot: autopilot, s: formStyle, p: mode == 'create' ? 'Create' : 'Edit${activeId == null ? '' : ' $activeId'}', footer: formFooter, children: formChildren);
    }

    if (mode == 'inspect' && (activeIndex != null || activeId != null)) {
      return UwPList(i: plistI ?? i * 100 + 12, autopilot: autopilot, s: plistStyle, p: 'Properties', properties: properties);
    }

    return UwEmpty(i: emptyI ?? i * 100 + 11, autopilot: autopilot, s: emptyStyle, title: emptyTitle, message: emptyMessage);
  }

  Widget? _buildTopToolbar({
    required String mode,
    required int currentViewMode,
    required List<int> availableViewModes,
    required bool canInspect,
    required int runtimeid,
    required Object? activeId,
    required int? activeIndex,
    required Object? resolvedId,
    required int? resolvedIndex,
  }) {
    return UwToolbar(
      i: topToolbarI ?? i * 100 + 1,
      autopilot: autopilot,
      s: topToolbarI == null ? 2 : topToolbarStyle,
      leftChildren: <Widget>[
        ..._buildLeadControl(
          mode: mode,
          currentViewMode: currentViewMode,
          availableViewModes: availableViewModes,
          onBack: () {
            if (mode == 'edit') {
              _setInspect(runtimeid, activeId: activeId, activeIndex: activeIndex);
              return;
            }
            _setBrowse(runtimeid);
          },
          onViewModeChanged: (int nextMode) {
            autopilot.state.setrt(runtimeid, 'viewmode', nextMode);
          },
        ),
        if (oid.isNotEmpty) Text('OID $oid'),
      ],
      rightChildren: <Widget>[
        TextButton(onPressed: () => _setCreate(runtimeid), child: const Text('New')),
        TextButton(
          onPressed: canInspect
              ? () => _setInspect(
                    runtimeid,
                    activeId: resolvedId,
                    activeIndex: resolvedIndex,
                  )
              : null,
          child: const Text('Inspect'),
        ),
        TextButton(
          onPressed: canInspect
              ? () => _setEdit(
                    runtimeid,
                    activeId: resolvedId,
                    activeIndex: resolvedIndex,
                  )
              : null,
          child: const Text('Edit'),
        ),
        TextButton(onPressed: () => _setBrowse(runtimeid), child: const Text('Clear')),
      ],
    );
  }

  Widget? _buildBottomToolbar({
    required int totalCount,
    required String? activeLabel,
    required int selectedCount,
  }) {
    return UwToolbar(
      i: bottomToolbarI ?? i * 100 + 3,
      autopilot: autopilot,
      s: bottomToolbarI == null ? 2 : bottomToolbarStyle,
      leftChildren: <Widget>[
        Text('Results: $totalCount'),
        if (activeLabel != null && activeLabel.isNotEmpty) Text('Active: $activeLabel'),
        if (selectedCount > 0) Text('Selected: $selectedCount'),
      ],
      rightChildren: <Widget>[
        if (summaryText.isNotEmpty) Text('Summary: $summaryText'),
      ],
    );
  }

  List<Widget> _buildLeadControl({
    required String mode,
    required int currentViewMode,
    required List<int> availableViewModes,
    required VoidCallback onBack,
    required ValueChanged<int> onViewModeChanged,
  }) {
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
    final nextMode = availableViewModes[(normalizedIndex + 1) % availableViewModes.length];
    return <Widget>[
      IconButton.filledTonal(
        tooltip: 'Switch view (${_viewLabelFor(currentViewMode)} -> ${_viewLabelFor(nextMode)})',
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

  void _selectIndex(int runtimeid, int index) {
    final activeId = _idForIndex(index);
    _setInspect(runtimeid, activeId: activeId, activeIndex: index);
  }

  Object? _idForIndex(int? index) {
    if (index == null || index < 0 || index >= collectionRows.length) {
      return null;
    }
    final row = collectionRows[index];
    return row.isEmpty ? index : row.first;
  }

  String? _labelForIndex(int? index) {
    if (index == null || index < 0 || index >= collectionRows.length) {
      return null;
    }
    final row = collectionRows[index];
    if (row.isEmpty) {
      return '$index';
    }
    if (row.length > 1) {
      return '${row[1] ?? row.first ?? ''}';
    }
    return '${row.first ?? ''}';
  }

  Map<String, Object?> _propertiesForIndex(int? index) {
    final resolved = <String, Object?>{};
    if (index != null && index >= 0 && index < collectionRows.length) {
      final row = collectionRows[index];
      if (collectionColumns.isNotEmpty) {
        for (var columnIndex = 0; columnIndex < collectionColumns.length; columnIndex++) {
          resolved[collectionColumns[columnIndex]] = columnIndex < row.length ? row[columnIndex] : null;
        }
      } else {
        for (var columnIndex = 0; columnIndex < row.length; columnIndex++) {
          resolved['Field ${columnIndex + 1}'] = row[columnIndex];
        }
      }
    }
    for (final entry in properties.entries) {
      resolved.putIfAbsent(entry.key, () => entry.value);
    }
    return resolved;
  }

  List<int> _allowedViewModes() {
    final modes = <int>[];
    final seen = <int>{};
    for (final mode in collectionViewModes) {
      if (seen.add(mode)) {
        modes.add(mode);
      }
    }
    return modes;
  }

  void _setBrowse(int runtimeid) {
    autopilot.state.patchrt(runtimeid, <String, dynamic>{'mode': 'browse', 'activeid': null, 'activeindex': null, 'selectedids': const <Object?>[]});
  }

  void _setCreate(int runtimeid) {
    autopilot.state.patchrt(runtimeid, <String, dynamic>{'mode': 'create', 'activeid': null, 'activeindex': null, 'selectedids': const <Object?>[]});
  }

  void _setInspect(int runtimeid, {required Object? activeId, required int? activeIndex}) {
    autopilot.state.patchrt(runtimeid, <String, dynamic>{
      'mode': activeId == null && activeIndex == null ? 'browse' : 'inspect',
      'activeid': activeId,
      'activeindex': activeIndex,
      'selectedids': activeId == null ? const <Object?>[] : <Object?>[activeId],
    });
  }

  void _setEdit(int runtimeid, {required Object? activeId, required int? activeIndex}) {
    autopilot.state.patchrt(runtimeid, <String, dynamic>{
      'mode': 'edit',
      'activeid': activeId,
      'activeindex': activeIndex,
      'selectedids': activeId == null ? const <Object?>[] : <Object?>[activeId],
    });
  }
}
