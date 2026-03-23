import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/ux/mixins.dart';
import 'package:genrp/core/ux/uwidget/uwempty.dart';

class Tdboard extends StatelessWidget with Ux {
  const Tdboard({
    required this.i,
    required this.autopilot,
    this.s = 0,
    super.key,
  });

  final int tid = 4;
  final int s;

  @override
  final int i;

  final Autopilot autopilot;

  @override
  final String n = 'tdboard';

  @override
  Widget build(BuildContext context) {
    return UxTemplateHost(
      i: i,
      autopilot: autopilot,
      builder: (BuildContext context, String scope) => UwEmpty(
        i: i,
        autopilot: autopilot,
        p: 'tdboard',
        message:
            'Tdboard is wired to the new runtime, but the dashboard surface is not implemented yet.',
      ),
    );
  }
}
