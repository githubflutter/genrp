import 'package:flutter/widgets.dart';
import 'package:genrp/core/ux/a/pilot.dart';
import 'package:genrp/core/ux/l/l.dart';
import 'package:genrp/core/ux/t/template.dart';

class Ldual extends StatelessWidget with L {
  // Minimum pane width/height should stay around 50px to avoid touch/layout issues.
  // Split rule:
  // 0 < s < 100   -> first width percentage
  // s >= 100      -> first width in px
  // -100 < s < 0  -> first height percentage
  // s <= -100     -> first height in px (using abs(s))
  // Precaution: 100% total limits and minimum pane clipping are not checked here.
  // API users must validate those values before passing them in.
  const Ldual({
    required this.i,
    required this.autopilot,
    required this.first,
    required this.second,
    this.s = 0,
    super.key,
  }) : assert(
         first is Template,
         'Ldual first child must be a Template variant',
       ),
       assert(
         second is Template,
         'Ldual second child must be a Template variant',
       );

  @override
  final int lid = 1;

  @override
  final int s;

  @override
  final int i;

  final UxPilot autopilot;
  final StatelessWidget first;
  final StatelessWidget second;

  @override
  final String n = 'ldual';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final maxWidth = constraints.maxWidth;
        final maxHeight = constraints.maxHeight;

        if (s < 0) {
          final firstSize = s.abs();
          if (maxHeight.isInfinite) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (firstSize >= 100)
                  SizedBox(height: firstSize.toDouble(), child: first)
                else
                  first,
                second,
              ],
            );
          }

          if (firstSize < 100) {
            final firstHeight = maxHeight * (firstSize / 100);
            final secondHeight = (maxHeight - firstHeight).clamp(
              0.0,
              maxHeight,
            );
            return Column(
              children: <Widget>[
                SizedBox(height: firstHeight, child: first),
                SizedBox(height: secondHeight, child: second),
              ],
            );
          }

          final firstHeight = firstSize.toDouble().clamp(0.0, maxHeight);
          final secondHeight = (maxHeight - firstHeight).clamp(0.0, maxHeight);
          return Column(
            children: <Widget>[
              SizedBox(height: firstHeight, child: first),
              SizedBox(height: secondHeight, child: second),
            ],
          );
        }

        if (maxWidth.isInfinite) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (s >= 100)
                SizedBox(width: s.toDouble(), child: first)
              else
                first,
              second,
            ],
          );
        }

        if (s > 0 && s < 100) {
          final firstWidth = maxWidth * (s / 100);
          final secondWidth = (maxWidth - firstWidth).clamp(0.0, maxWidth);
          return Row(
            children: <Widget>[
              SizedBox(width: firstWidth, child: first),
              SizedBox(width: secondWidth, child: second),
            ],
          );
        }

        if (s >= 100) {
          final firstWidth = s.toDouble().clamp(0.0, maxWidth);
          final secondWidth = (maxWidth - firstWidth).clamp(0.0, maxWidth);
          return Row(
            children: <Widget>[
              SizedBox(width: firstWidth, child: first),
              SizedBox(width: secondWidth, child: second),
            ],
          );
        }

        return Row(
          children: <Widget>[
            Expanded(child: first),
            Expanded(child: second),
          ],
        );
      },
    );
  }
}
