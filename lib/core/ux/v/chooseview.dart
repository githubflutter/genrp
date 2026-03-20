import 'package:flutter/material.dart';
import 'package:genrp/core/ux/a/pilot.dart';
import 'package:genrp/core/ux/v/v.dart';
import 'package:genrp/core/ux/v/empty.dart';

class UxChooseView extends StatelessWidget with V {
  const UxChooseView({
    required this.i,
    required this.autopilot,
    this.s = 0,
    super.key,
    this.p = '',
    this.options = const <String>[],
    this.selectedIndex,
    this.onSelected,
  });

  @override
  final int vid = 10;

  @override
  final int s;

  @override
  final int i;

  final UxPilot autopilot;
  final String p;
  final List<String> options;
  final int? selectedIndex;
  final ValueChanged<int>? onSelected;

  @override
  final String n = 'chooseview';

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) {
      return UxEmptyView(
        i: i,
        autopilot: autopilot,
        p: p.isNotEmpty ? p : 'No choices available',
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List<Widget>.generate(options.length, (int index) {
        return ChoiceChip(
          label: Text(options[index]),
          selected: selectedIndex == index,
          onSelected: onSelected == null ? null : (_) => onSelected!(index),
        );
      }),
    );
  }
}
