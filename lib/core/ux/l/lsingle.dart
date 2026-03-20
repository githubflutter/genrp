import 'package:flutter/widgets.dart';
import 'package:genrp/core/ux/a/pilot.dart';
import 'package:genrp/core/ux/l/l.dart';
import 'package:genrp/core/ux/t/template.dart';

class Lsingle extends StatelessWidget with L {
  const Lsingle({
    required this.i,
    required this.autopilot,
    required this.child,
    this.s = 0,
    super.key,
  }) : assert(child is Template, 'Lsingle child must be a Template variant');

  @override
  final int lid = 0;

  @override
  final int s;

  @override
  final int i;

  final UxPilot autopilot;
  final StatelessWidget child;

  @override
  final String n = 'lsingle';

  @override
  Widget build(BuildContext context) {
    return Container(child: child);
  }
}
