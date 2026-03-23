import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/ux/mixins.dart';
import 'package:genrp/core/ux/uwidget/uwempty.dart';

class Tform extends StatelessWidget with Ux {
  const Tform({
    required this.i,
    required this.autopilot,
    this.s = 0,
    super.key,
  });

  final int tid = 6;
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
      builder: (BuildContext context, String scope) => UwEmpty(
        i: i,
        autopilot: autopilot,
        p: 'tform',
        message: 'Tform is ready for the new runtime, but not implemented yet.',
      ),
    );
  }
}
