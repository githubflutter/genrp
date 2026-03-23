import 'package:flutter/widgets.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/ux/mixins.dart';

class Pone extends StatelessWidget with Ux {
  const Pone({
    required this.i,
    required this.autopilot,
    required this.child,
    this.s = 0,
    super.key,
  }) : assert(child is Ux, 'Pone child must be a Ux variant');

  final int pid = 1;
  final int s;

  @override
  final int i;

  final Autopilot autopilot;
  final StatelessWidget child;

  @override
  final String n = 'paperone';

  @override
  Widget build(BuildContext context) {
    final isHorizontal = s == 1;
    return UxPaperHost(
      i: i,
      autopilot: autopilot,
      child: SingleChildScrollView(
        scrollDirection: isHorizontal ? Axis.horizontal : Axis.vertical,
        child: isHorizontal
            ? Row(children: <Widget>[child])
            : Column(children: <Widget>[child]),
      ),
    );
  }
}
