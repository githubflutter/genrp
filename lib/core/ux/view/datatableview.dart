import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/theme/theme.dart';
import 'package:genrp/core/ux/v.dart';
import 'package:genrp/core/ux/view/empty.dart';

class UxDataTableView extends StatelessWidget with V {
  const UxDataTableView({
    required this.i,
    required this.autopilot,
    this.s = 0,
    super.key,
    this.p = '',
    this.columns = const <String>[],
    this.rows = const <List<Object?>>[],
    this.selectedIndex,
    this.onSelectIndex,
  });

  @override
  final int vid = 3;

  @override
  final int s;

  @override
  final int i;

  final Autopilot autopilot;
  final String p;
  final List<String> columns;
  final List<List<Object?>> rows;
  final int? selectedIndex;
  final ValueChanged<int>? onSelectIndex;

  @override
  final String n = 'datatableview';

  @override
  Widget build(BuildContext context) {
    if (columns.isEmpty) {
      return UxEmptyView(i: i, autopilot: autopilot, p: p.isNotEmpty ? p : 'No table definition');
    }
    final normalizedRows = rows.map((List<Object?> row) => List<String>.generate(columns.length, (int index) => index < row.length ? '${row[index] ?? ''}' : '')).toList(growable: false);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: UxTheme.panelDecoration(context),
        padding: UxTheme.compactPadding,
        child: DataTable(
          columns: columns.map((String label) => DataColumn(label: Text(label))).toList(growable: false),
          rows: normalizedRows.indexed
              .map(
                ((int, List<String>) record) => DataRow(
                  selected: selectedIndex == record.$1,
                  onSelectChanged: onSelectIndex == null ? null : (_) => onSelectIndex!(record.$1),
                  cells: record.$2.map((String cell) => DataCell(Text(cell))).toList(growable: false),
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }
}
