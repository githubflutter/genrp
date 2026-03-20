import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/ux/template.dart';
import 'package:genrp/core/ux/view/empty.dart';

class Tform extends StatelessWidget with Template {
  const Tform({required this.i, required this.autopilot, this.s = 0, super.key});

  @override
  final int tid = 6;

  @override
  final int s;

  @override
  final int i;

  final Autopilot autopilot;

  @override
  final String n = 'tform';

  @override
  Widget build(BuildContext context) {
    return UxTemplateHost(
      i: i,
      autopilot: autopilot,
      builder: (BuildContext context, String scope) => UxEmptyView(i: i, autopilot: autopilot, p: 'tform', message: 'Tform is ready for the new runtime, but not implemented yet.'),
    );
  }
}
