import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/ux/mixins.dart';
import 'package:genrp/core/ux/uwidget/uwempty.dart';

class Treport extends StatelessWidget with Ux {
  const Treport({
    required this.i,
    required this.autopilot,
    this.s = 0,
    super.key,
  });

  final int tid = 3;
  final int s;

  @override
  final int i;

  final Autopilot autopilot;

  @override
  final String n = 'treport';

  @override
  Widget build(BuildContext context) {
    return UxTemplateHost(
      i: i,
      autopilot: autopilot,
      builder: (BuildContext context, int runtimeid) => UwEmpty(
        i: i,
        autopilot: autopilot,
        p: 'treport',
        message:
            'Treport is wired to the new runtime, but the report surface is not implemented yet.',
      ),
    );
  }
}
