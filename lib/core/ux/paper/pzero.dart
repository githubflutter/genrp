import 'package:flutter/widgets.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/ux/paper.dart';
import 'package:genrp/core/ux/template.dart';

class Pzero extends StatelessWidget with Paper {
  const Pzero({required this.i, required this.autopilot, required this.child, this.s = 0, super.key}) : assert(child is Template, 'Pzero child must be a Template variant');

  @override
  final int pid = 0;

  @override
  final int s;

  @override
  final int i;

  final Autopilot autopilot;
  final StatelessWidget child;

  @override
  final String n = 'paperzero';

  @override
  Widget build(BuildContext context) {
    return UxPaperHost(
      i: i,
      autopilot: autopilot,
      child: Container(child: child),
    );
  }
}
