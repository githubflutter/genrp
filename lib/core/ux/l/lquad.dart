import 'package:flutter/widgets.dart';
import 'package:genrp/core/ux/a/pilot.dart';
import 'package:genrp/core/ux/l/l.dart';
import 'package:genrp/core/ux/t/template.dart';

class Lquad extends StatelessWidget with L {
  // Layout rule:
  // s == 0  -> balanced 2x2 grid
  // s > 0   -> horizontal strip with four equal panes
  // s < 0   -> vertical stack with four equal panes
  const Lquad({
    required this.i,
    required this.autopilot,
    required this.first,
    required this.second,
    required this.third,
    required this.fourth,
    this.s = 0,
    super.key,
  }) : assert(
         first is Template,
         'Lquad first child must be a Template variant',
       ),
       assert(
         second is Template,
         'Lquad second child must be a Template variant',
       ),
       assert(
         third is Template,
         'Lquad third child must be a Template variant',
       ),
       assert(
         fourth is Template,
         'Lquad fourth child must be a Template variant',
       );

  @override
  final int lid = 3;

  @override
  final int s;

  @override
  final int i;

  final UxPilot autopilot;
  final StatelessWidget first;
  final StatelessWidget second;
  final StatelessWidget third;
  final StatelessWidget fourth;

  @override
  final String n = 'lquad';

  @override
  Widget build(BuildContext context) {
    if (s == 0) {
      return Table(
        defaultColumnWidth: const FlexColumnWidth(),
        children: <TableRow>[
          TableRow(children: <Widget>[first, second]),
          TableRow(children: <Widget>[third, fourth]),
        ],
      );
    }

    final vertical = s < 0;
    final children = <StatelessWidget>[first, second, third, fourth];
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bounded = vertical
            ? constraints.maxHeight.isFinite
            : constraints.maxWidth.isFinite;
        if (!bounded) {
          return Flex(
            direction: vertical ? Axis.vertical : Axis.horizontal,
            mainAxisSize: MainAxisSize.min,
            children: children,
          );
        }
        return Flex(
          direction: vertical ? Axis.vertical : Axis.horizontal,
          children: children
              .map<Widget>((StatelessWidget child) => Expanded(child: child))
              .toList(),
        );
      },
    );
  }
}
