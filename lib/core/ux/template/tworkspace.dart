import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/model/uschema/ux_action_holder_spec.dart';
import 'package:genrp/core/model/uschema/ux_template_action_spec.dart';
import 'package:genrp/core/theme/theme.dart';
import 'package:genrp/core/ux/mixins.dart';
import 'package:genrp/core/ux/draggable_fab.dart';
import 'package:genrp/core/ux/uwidget/uwalert.dart';
import 'package:genrp/core/ux/uwidget/uwcollection.dart';
import 'package:genrp/core/ux/uwidget/uwempty.dart';
import 'package:genrp/core/ux/uwidget/uwform.dart';
import 'package:genrp/core/ux/uwidget/uwplist.dart';
import 'package:genrp/core/ux/uwidget/uwtoolbar.dart';

class Tworkspace extends StatelessWidget with Template {
  const Tworkspace({
    required this.i,
    required this.autopilot,
    this.s = 0,
    this.oid = '',
    this.summaryText = '',
    this.collectionTitle = 'Collection',
    this.collectionRows = const <List<Object?>>[],
    this.collectionColumns = const <String>[],
    this.collectionChildren = const <Widget>[],
    this.collectionViewModes = const <int>[3],
    this.properties = const <String, Object?>{},
    this.actions = const <UxTemplateActionSpec>[],
    this.actionHolders = const <UxActionHolderSpec>[],
    this.formChildren = const <Widget>[],
    this.formFooter,
    this.emptyTitle = 'No selection',
    this.emptyMessage = 'Choose an item from the collection to inspect it.',
    this.defaultAlertMessage = 'Something needs your attention.',
    this.collectionFlex = 7,
    this.detailFlex = 5,
    super.key,
  });

  @override
  final int tid = 1;

  @override
  final int s;

  @override
  final int i;

  final Autopilot autopilot;
  final String oid;
  final String summaryText;
  final String collectionTitle;
  final List<List<Object?>> collectionRows;
  final List<String> collectionColumns;
  final List<Widget> collectionChildren;
  final List<int> collectionViewModes;
  final Map<String, Object?> properties;
  final List<UxTemplateActionSpec> actions;
  final List<UxActionHolderSpec> actionHolders;
  final List<Widget> formChildren;
  final Widget? formFooter;
  final String emptyTitle;
  final String emptyMessage;
  final String defaultAlertMessage;
  final int collectionFlex;
  final int detailFlex;

  @override
  final String n = 'tworkspace';

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
      initialState: <String, dynamic>{'mode': 'browse', 'viewMode': initialViewMode, 'selectionMode': 'single', 'activeId': null, 'activeIndex': null, 'selectedIds': const <Object?>[]},
      builder: (BuildContext context, String scope) {
        return AnimatedBuilder(
          animation: autopilot,
          builder: (BuildContext context, Widget? child) {
            final mode = autopilot.templateState<String>(scope, 'mode') ?? 'browse';
            final viewMode = autopilot.templateState<int>(scope, 'viewMode') ?? 3;
            final activeId = autopilot.templateState<Object?>(scope, 'activeId');
            final activeIndex = autopilot.templateState<int>(scope, 'activeIndex');
            final selectedIds = autopilot.templateState<List<dynamic>>(scope, 'selectedIds') ?? const <dynamic>[];
            final totalCount = autopilot.templateState<int>(scope, 'totalCount') ?? collectionRows.length;
            final errorMessage = autopilot.templateState<String>(scope, 'error');
            final activeLabel = _labelForIndex(activeIndex);
            final activeProperties = _propertiesForIndex(activeIndex);
            final canInspect = collectionRows.isNotEmpty;
            final resolvedIndex = activeIndex ?? (canInspect ? 0 : null);
            final resolvedId = _idForIndex(resolvedIndex);
            final allowedViewModes = _allowedViewModes();

            final collection = UwCollection(
              i: i * 100 + 10,
              autopilot: autopilot,
              s: viewMode,
              p: collectionTitle,
              columns: collectionColumns,
              rows: collectionRows,
              selectedIndex: activeIndex,
              onSelectIndex: (int index) {
                _selectIndex(scope, index);
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
                  scope: scope,
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
                final floatingHolder = _holderFor(
                  UxActionHolderPosition.floating,
                  UxActionHolderPresentation.floatingIsland,
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

                return Stack(
                  children: <Widget>[
                    bodyColumn,
                    if (floatingHolder != null)
                      DraggableFAB(
                        actions: _actionsForHolder(floatingHolder),
                        onAction: _handleTemplateAction,
                      ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildDetail({required String mode, required Object? activeId, required int? activeIndex, required Map<String, Object?> properties, required String? errorMessage}) {
    if (errorMessage != null && errorMessage.isNotEmpty) {
      return UwAlert(i: i * 100 + 14, autopilot: autopilot, s: 4, title: 'Error', message: errorMessage.isNotEmpty ? errorMessage : defaultAlertMessage);
    }

    if (mode == 'create' || mode == 'edit') {
      return UwForm(i: i * 100 + 13, autopilot: autopilot, p: mode == 'create' ? 'Create' : 'Edit${activeId == null ? '' : ' $activeId'}', footer: formFooter, children: formChildren);
    }

    if (mode == 'inspect' && (activeIndex != null || activeId != null)) {
      return UwPList(i: i * 100 + 12, autopilot: autopilot, p: 'Properties', properties: properties);
    }

    return UwEmpty(i: i * 100 + 11, autopilot: autopilot, title: emptyTitle, message: emptyMessage);
  }

  Widget? _buildTopToolbar({
    required String mode,
    required int currentViewMode,
    required List<int> availableViewModes,
    required bool canInspect,
    required String scope,
    required Object? activeId,
    required int? activeIndex,
    required Object? resolvedId,
    required int? resolvedIndex,
  }) {
    final holder = _holderFor(
      UxActionHolderPosition.top,
      UxActionHolderPresentation.toolbar,
    );
    if (holder == null || !holder.visible) return null;
    return UwToolbar(
      i: i * 100 + 1,
      autopilot: autopilot,
      s: 2,
      leftChildren: <Widget>[
        ..._buildLeadControl(
          mode: mode,
          currentViewMode: currentViewMode,
          availableViewModes: availableViewModes,
          onBack: () {
            if (mode == 'edit') {
              _setInspect(scope, activeId: activeId, activeIndex: activeIndex);
              return;
            }
            _setBrowse(scope);
          },
          onViewModeChanged: (int nextMode) {
            autopilot.setTemplateState(scope, 'viewMode', nextMode);
          },
        ),
        if (oid.isNotEmpty) Text('OID $oid'),
      ],
      rightChildren: <Widget>[
        TextButton(onPressed: () => _setCreate(scope), child: const Text('New')),
        TextButton(
          onPressed: canInspect
              ? () => _setInspect(
                    scope,
                    activeId: resolvedId,
                    activeIndex: resolvedIndex,
                  )
              : null,
          child: const Text('Inspect'),
        ),
        TextButton(
          onPressed: canInspect
              ? () => _setEdit(
                    scope,
                    activeId: resolvedId,
                    activeIndex: resolvedIndex,
                  )
              : null,
          child: const Text('Edit'),
        ),
        TextButton(onPressed: () => _setBrowse(scope), child: const Text('Clear')),
      ],
    );
  }

  Widget? _buildBottomToolbar({
    required int totalCount,
    required String? activeLabel,
    required int selectedCount,
  }) {
    final holder = _holderFor(
      UxActionHolderPosition.bottom,
      UxActionHolderPresentation.toolbar,
    );
    if (holder == null || !holder.visible) return null;
    return UwToolbar(
      i: i * 100 + 3,
      autopilot: autopilot,
      s: 2,
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

  UxActionHolderSpec? _holderFor(
    UxActionHolderPosition position,
    UxActionHolderPresentation presentation,
  ) {
    for (final UxActionHolderSpec holder in actionHolders) {
      if (holder.position == position && holder.presentation == presentation) {
        return holder;
      }
    }
    return null;
  }

  List<UxTemplateActionSpec> _actionsForHolder(UxActionHolderSpec holder) {
    if (holder.actionKinds.isEmpty) return const <UxTemplateActionSpec>[];
    final Map<UxTemplateAction, UxTemplateActionSpec> byAction =
        <UxTemplateAction, UxTemplateActionSpec>{
      for (final UxTemplateActionSpec action in actions) action.action: action,
    };
    final List<UxTemplateActionSpec> resolved = <UxTemplateActionSpec>[];
    for (final UxTemplateAction kind in holder.actionKinds) {
      final UxTemplateActionSpec? action = byAction[kind];
      if (action != null && action.visible) {
        resolved.add(action);
      }
    }
    return resolved;
  }

  void _handleTemplateAction(
    UxTemplateAction action,
    Map<String, Object?> payload,
  ) {
    switch (action) {
      case UxTemplateAction.commit:
        callbacksNoop();
      case UxTemplateAction.refetch:
        callbacksNoop();
      case UxTemplateAction.cancel:
        callbacksNoop();
      case UxTemplateAction.share:
        callbacksNoop();
    }
  }

  void callbacksNoop() {}

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

  void _selectIndex(String scope, int index) {
    final activeId = _idForIndex(index);
    _setInspect(scope, activeId: activeId, activeIndex: index);
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

  void _setBrowse(String scope) {
    autopilot.patchTemplateState(scope, <String, dynamic>{'mode': 'browse', 'activeId': null, 'activeIndex': null, 'selectedIds': const <Object?>[]});
  }

  void _setCreate(String scope) {
    autopilot.patchTemplateState(scope, <String, dynamic>{'mode': 'create', 'activeId': null, 'activeIndex': null, 'selectedIds': const <Object?>[]});
  }

  void _setInspect(String scope, {required Object? activeId, required int? activeIndex}) {
    autopilot.patchTemplateState(scope, <String, dynamic>{
      'mode': activeId == null && activeIndex == null ? 'browse' : 'inspect',
      'activeId': activeId,
      'activeIndex': activeIndex,
      'selectedIds': activeId == null ? const <Object?>[] : <Object?>[activeId],
    });
  }

  void _setEdit(String scope, {required Object? activeId, required int? activeIndex}) {
    autopilot.patchTemplateState(scope, <String, dynamic>{
      'mode': 'edit',
      'activeId': activeId,
      'activeIndex': activeIndex,
      'selectedIds': activeId == null ? const <Object?>[] : <Object?>[activeId],
    });
  }
}
