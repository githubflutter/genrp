import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/ux/mixins.dart';
import 'package:genrp/core/ux/uwidget/uwempty.dart';

class Tsheet extends StatelessWidget with Template {
  const Tsheet({
    required this.i,
    required this.autopilot,
    this.s = 0,
    super.key,
  });

  @override
  final int tid = 2;

  @override
  final int s;

  @override
  final int i;

  final Autopilot autopilot;

  @override
  final String n = 'tsheet';

  @override
  Widget build(BuildContext context) {
    return UxTemplateHost(
      i: i,
      autopilot: autopilot,
      builder: (BuildContext context, String scope) => UwEmpty(
        i: i,
        autopilot: autopilot,
        p: 'tsheet',
        message:
            'Tsheet is wired to the new runtime, but its sheet behavior is still pending.',
      ),
    );
  }
}
