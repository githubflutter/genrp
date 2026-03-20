import 'package:flutter/widgets.dart';
import 'package:genrp/core/ux/a/pilot.dart';
import 'package:genrp/core/ux/p/paper.dart';

class Pfour extends StatelessWidget with Paper {
  const Pfour({
    required this.i,
    required this.autopilot,
    this.s = 0,
    super.key,
  });

  @override
  final int pid = 4;

  @override
  final int s;

  @override
  final int i;

  final UxPilot autopilot;

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
