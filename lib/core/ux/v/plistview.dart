import 'package:flutter/material.dart';
import 'package:genrp/core/ux/a/pilot.dart';
import 'package:genrp/core/ux/theme.dart';
import 'package:genrp/core/ux/v/v.dart';
import 'package:genrp/core/ux/v/empty.dart';

class UxPListView extends StatelessWidget with V {
  const UxPListView({
    required this.i,
    required this.autopilot,
    this.s = 0,
    super.key,
    this.p = '',
    this.title,
    this.properties = const <String, Object?>{},
  });

  @override
  final int vid = 6;

  @override
  final int s;

  @override
  final int i;

  final UxPilot autopilot;
  final String p;
  final String? title;
  final Map<String, Object?> properties;

  @override
  final String n = 'plistview';

  @override
  Widget build(BuildContext context) {
    final resolvedTitle = title ?? p;
    if (properties.isEmpty) {
      return UxEmptyView(
        i: i,
        autopilot: autopilot,
        p: resolvedTitle.isNotEmpty ? resolvedTitle : 'No properties',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (resolvedTitle.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(resolvedTitle, style: UxTheme.titleStyle(context)),
          ),
        ...properties.entries.map(
          (MapEntry<String, Object?> entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Text(entry.key, style: UxTheme.keyStyle(context)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Text(
                    '${entry.value ?? ''}',
                    style: UxTheme.bodyStyle(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
