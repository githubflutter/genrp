import 'package:flutter/widgets.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/ux/mixins.dart';

class Pfour extends StatelessWidget with Ux {
  const Pfour({
    required this.i,
    required this.autopilot,
    this.s = 0,
    super.key,
  });

  final int pid = 4;
  final int s;

  @override
  final int i;

  final Autopilot autopilot;

  @override
  final String n = 'paperfour';

  @override
  Widget build(BuildContext context) {
    return UxPaperHost(
      i: i,
      autopilot: autopilot,
      child: const SizedBox.shrink(),
    );
  }
}
