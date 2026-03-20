import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/theme/theme.dart';
import 'package:genrp/core/ux/mixins.dart';
import 'package:genrp/core/ux/template/tcrudfooter.dart';
import 'package:genrp/core/ux/template/tcrudheader.dart';
import 'package:genrp/core/ux/uwidget/uwalert.dart';
import 'package:genrp/core/ux/uwidget/uwcollection.dart';
import 'package:genrp/core/ux/uwidget/uwempty.dart';
import 'package:genrp/core/ux/uwidget/uwfrom.dart';
import 'package:genrp/core/ux/uwidget/uwplist.dart';

class Tcrud extends StatelessWidget with Template {
  const Tcrud({
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
  final List<Widget> formChildren;
  final Widget? formFooter;
  final String emptyTitle;
  final String emptyMessage;
  final String defaultAlertMessage;
  final int collectionFlex;
  final int detailFlex;

  @override
  final String n = 'tcrud';

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
      initialState: <String, dynamic>{
        'mode': 'browse',
        'viewMode': initialViewMode,
        'selectionMode': 'single',
        'activeId': null,
        'activeIndex': null,
        'selectedIds': const <Object?>[],
      },
      builder: (BuildContext context, String scope) {
        return AnimatedBuilder(
          animation: autopilot,
          builder: (BuildContext context, Widget? child) {
            final mode =
                autopilot.templateState<String>(scope, 'mode') ?? 'browse';
            final viewMode =
                autopilot.templateState<int>(scope, 'viewMode') ?? 3;
            final activeId = autopilot.templateState<Object?>(
              scope,
              'activeId',
            );
            final activeIndex = autopilot.templateState<int>(
              scope,
              'activeIndex',
            );
            final selectedIds =
                autopilot.templateState<List<dynamic>>(scope, 'selectedIds') ??
                const <dynamic>[];
            final totalCount =
                autopilot.templateState<int>(scope, 'totalCount') ??
                collectionRows.length;
            final errorMessage = autopilot.templateState<String>(
              scope,
              'error',
            );
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

            final detail = _buildDetail(
              mode: mode,
              activeId: activeId,
              activeIndex: activeIndex,
              properties: activeProperties,
              errorMessage: errorMessage,
            );

            return LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final showCollectionBody =
                    errorMessage == null || errorMessage.isEmpty
                    ? mode == 'browse'
                    : false;
                final bodyChild = showCollectionBody
                    ? collection
                    : Container(
                        decoration: UxTheme.softPanelDecoration(context),
                        child: SingleChildScrollView(
                          padding: UxTheme.panelPadding,
                          child: detail,
                        ),
                      );
                final mainBody = constraints.hasBoundedHeight
                    ? Expanded(child: bodyChild)
                    : SizedBox(height: 760, child: bodyChild);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TcrudHeader(
                      i: i * 100 + 1,
                      autopilot: autopilot,
                      mode: mode,
                      currentViewMode: viewMode,
                      availableViewModes: allowedViewModes,
                      oid: oid,
                      canInspect: canInspect,
                      onViewModeChanged: (int nextMode) {
                        autopilot.setTemplateState(scope, 'viewMode', nextMode);
                      },
                      onBack: () {
                        if (mode == 'edit') {
                          _setInspect(
                            scope,
                            activeId: activeId,
                            activeIndex: activeIndex,
                          );
                          return;
                        }
                        _setBrowse(scope);
                      },
                      onNew: () => _setCreate(scope),
                      onInspect: canInspect
                          ? () => _setInspect(
                              scope,
                              activeId: resolvedId,
                              activeIndex: resolvedIndex,
                            )
                          : null,
                      onEdit: canInspect
                          ? () => _setEdit(
                              scope,
                              activeId: resolvedId,
                              activeIndex: resolvedIndex,
                            )
                          : null,
                      onClear: () => _setBrowse(scope),
                    ),
                    const SizedBox(height: 12),
                    mainBody,
                    const SizedBox(height: 12),
                    TcrudFooter(
                      i: i * 100 + 3,
                      autopilot: autopilot,
                      totalCount: totalCount,
                      activeLabel: activeLabel,
                      selectedCount: selectedIds.length,
                      summaryText: summaryText,
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

  Widget _buildDetail({
    required String mode,
    required Object? activeId,
    required int? activeIndex,
    required Map<String, Object?> properties,
    required String? errorMessage,
  }) {
    if (errorMessage != null && errorMessage.isNotEmpty) {
      return UwAlert(
        i: i * 100 + 14,
        autopilot: autopilot,
        s: 4,
        title: 'Error',
        message: errorMessage.isNotEmpty ? errorMessage : defaultAlertMessage,
      );
    }

    if (mode == 'create' || mode == 'edit') {
      return UwFrom(
        i: i * 100 + 13,
        autopilot: autopilot,
        p: mode == 'create'
            ? 'Create'
            : 'Edit${activeId == null ? '' : ' $activeId'}',
        footer: formFooter,
        children: formChildren,
      );
    }

    if (mode == 'inspect' && (activeIndex != null || activeId != null)) {
      return UwPList(
        i: i * 100 + 12,
        autopilot: autopilot,
        p: 'Properties',
        properties: properties,
      );
    }

    return UwEmpty(
      i: i * 100 + 11,
      autopilot: autopilot,
      title: emptyTitle,
      message: emptyMessage,
    );
  }

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
        for (
          var columnIndex = 0;
          columnIndex < collectionColumns.length;
          columnIndex++
        ) {
          resolved[collectionColumns[columnIndex]] = columnIndex < row.length
              ? row[columnIndex]
              : null;
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
    autopilot.patchTemplateState(scope, <String, dynamic>{
      'mode': 'browse',
      'activeId': null,
      'activeIndex': null,
      'selectedIds': const <Object?>[],
    });
  }

  void _setCreate(String scope) {
    autopilot.patchTemplateState(scope, <String, dynamic>{
      'mode': 'create',
      'activeId': null,
      'activeIndex': null,
      'selectedIds': const <Object?>[],
    });
  }

  void _setInspect(
    String scope, {
    required Object? activeId,
    required int? activeIndex,
  }) {
    autopilot.patchTemplateState(scope, <String, dynamic>{
      'mode': activeId == null && activeIndex == null ? 'browse' : 'inspect',
      'activeId': activeId,
      'activeIndex': activeIndex,
      'selectedIds': activeId == null ? const <Object?>[] : <Object?>[activeId],
    });
  }

  void _setEdit(
    String scope, {
    required Object? activeId,
    required int? activeIndex,
  }) {
    autopilot.patchTemplateState(scope, <String, dynamic>{
      'mode': 'edit',
      'activeId': activeId,
      'activeIndex': activeIndex,
      'selectedIds': activeId == null ? const <Object?>[] : <Object?>[activeId],
    });
  }
}
