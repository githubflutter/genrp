import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/theme/theme.dart';
import 'package:genrp/core/ux/view/datatableview.dart';
import 'package:genrp/core/ux/view/empty.dart';
import 'package:genrp/core/ux/view/gridview.dart';
import 'package:genrp/core/ux/view/listview.dart';
import 'package:genrp/core/ux/v.dart';

class UxCollectionView extends StatelessWidget with V {
  // Collection mode:
  // default -> table when columns exist, otherwise list
  // s == 1  -> listview
  // s == 2  -> gridview
  // s == 3  -> datatableview
  const UxCollectionView({
    required this.i,
    required this.autopilot,
    this.s = 0,
    this.p = '',
    this.title,
    this.children = const <Widget>[],
    this.columns = const <String>[],
    this.rows = const <List<Object?>>[],
    this.crossAxisCount = 2,
    this.spacing = 12,
    this.childAspectRatio = 1.2,
    this.selectedIndex,
    this.onSelectIndex,
    super.key,
  });

  @override
  final int vid = 12;

  @override
  final int s;

  @override
  final int i;

  final Autopilot autopilot;
  final String p;
  final String? title;
  final List<Widget> children;
  final List<String> columns;
  final List<List<Object?>> rows;
  final int crossAxisCount;
  final double spacing;
  final double childAspectRatio;
  final int? selectedIndex;
  final ValueChanged<int>? onSelectIndex;

  @override
  final String n = 'collectionview';

  @override
  Widget build(BuildContext context) {
    final resolvedTitle = title ?? p;
    if (children.isEmpty && columns.isEmpty && rows.isEmpty) {
      return UxEmptyView(i: i, autopilot: autopilot, p: resolvedTitle.isNotEmpty ? resolvedTitle : 'Empty collection');
    }

    final listChildren = _buildListChildren(context);
    final gridChildren = _buildGridChildren(context);

    switch (s) {
      case 1:
        return UxListView(i: i, autopilot: autopilot, p: resolvedTitle, s: 1, children: listChildren);
      case 2:
        return UxGridView(i: i, autopilot: autopilot, p: resolvedTitle, crossAxisCount: crossAxisCount, spacing: spacing, childAspectRatio: childAspectRatio, children: gridChildren);
      case 3:
        return UxDataTableView(i: i, autopilot: autopilot, p: resolvedTitle, columns: columns, rows: rows, selectedIndex: selectedIndex, onSelectIndex: onSelectIndex);
      default:
        if (columns.isNotEmpty) {
          return UxDataTableView(i: i, autopilot: autopilot, p: resolvedTitle, columns: columns, rows: rows, selectedIndex: selectedIndex, onSelectIndex: onSelectIndex);
        }
        return UxListView(i: i, autopilot: autopilot, p: resolvedTitle, s: 1, children: listChildren);
    }
  }

  List<Widget> _buildListChildren(BuildContext context) {
    if (children.isNotEmpty) {
      return children.indexed.map<Widget>(((int, Widget) record) => _wrapSelectable(context, record.$1, child: record.$2)).toList(growable: false);
    }
    return rows.indexed.map<Widget>(((int, List<Object?>) record) => _wrapSelectable(context, record.$1, child: _rowListTile(context, record.$2))).toList(growable: false);
  }

  List<Widget> _buildGridChildren(BuildContext context) {
    if (children.isNotEmpty) {
      return children.indexed.map<Widget>(((int, Widget) record) => _wrapSelectable(context, record.$1, child: record.$2)).toList(growable: false);
    }
    return rows.indexed.map<Widget>(((int, List<Object?>) record) => _wrapSelectable(context, record.$1, child: _rowCard(context, record.$2))).toList(growable: false);
  }

  Widget _wrapSelectable(BuildContext context, int index, {required Widget child}) {
    final isSelected = selectedIndex == index;
    final selectionColor = UxTheme.colors(context).primary.withValues(alpha: 0.12);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: UxTheme.radius,
        onTap: onSelectIndex == null ? null : () => onSelectIndex!(index),
        child: Ink(
          decoration: UxTheme.softPanelDecoration(context, color: isSelected ? selectionColor : null),
          child: Padding(padding: UxTheme.compactPadding, child: child),
        ),
      ),
    );
  }

  Widget _rowListTile(BuildContext context, List<Object?> row) {
    final titleText = row.isEmpty ? 'Row' : '${row.first ?? ''}';
    final subtitleParts = row.skip(1).map((Object? value) => '$value').where((String value) => value.isNotEmpty);
    final subtitleText = subtitleParts.join(' · ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(titleText, style: UxTheme.keyStyle(context)),
        if (subtitleText.isNotEmpty) ...<Widget>[const SizedBox(height: 4), Text(subtitleText, style: UxTheme.bodyStyle(context))],
      ],
    );
  }

  Widget _rowCard(BuildContext context, List<Object?> row) {
    final titleText = row.isEmpty ? 'Row' : '${row.first ?? ''}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(titleText, style: UxTheme.titleStyle(context)),
        const SizedBox(height: 8),
        ...row
            .skip(1)
            .map(
              (Object? value) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('$value', style: UxTheme.bodyStyle(context)),
              ),
            ),
      ],
    );
  }
}
