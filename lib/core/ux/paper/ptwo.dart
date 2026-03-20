import 'package:flutter/widgets.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/ux/paper.dart';
import 'package:genrp/core/ux/template.dart';

class Ptwo extends StatelessWidget with Paper {
  // Minimum pane width/height should stay around 50px to avoid touch/layout issues.
  // Split rule:
  // 0 < s < 100   -> left width percentage
  // s >= 100      -> left width in px
  // -100 < s < 0  -> top height percentage
  // s <= -100     -> top height in px (using abs(s))
  // Precaution: 100% total limits and minimum pane clipping are not checked here.
  // API users must validate those values before passing them in.
  const Ptwo({required this.i, required this.autopilot, required this.left, required this.right, this.s = 0, super.key})
    : assert(left is Template, 'Ptwo left child must be a Template variant'),
      assert(right is Template, 'Ptwo right child must be a Template variant');

  @override
  final int pid = 2;

  @override
  final int s;

  @override
  final int i;

  final Autopilot autopilot;
  final StatelessWidget left;
  final StatelessWidget right;

  @override
  final String n = 'papertwo';

  @override
  Widget build(BuildContext context) {
    return UxPaperHost(
      i: i,
      autopilot: autopilot,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final maxWidth = constraints.maxWidth;
          final maxHeight = constraints.maxHeight;
          if (s < 0) {
            final topSize = s.abs();
            if (maxHeight.isInfinite) {
              if (topSize < 100) {
                final bottomFlex = 100 - topSize;
                return Column(
                  children: <Widget>[
                    Expanded(flex: topSize, child: left),
                    Expanded(flex: bottomFlex <= 0 ? 1 : bottomFlex, child: right),
                  ],
                );
              }
              return Column(
                children: <Widget>[
                  SizedBox(height: topSize.toDouble(), child: left),
                  Expanded(child: right),
                ],
              );
            }

            if (topSize < 100) {
              final topHeight = maxHeight * (topSize / 100);
              final bottomHeight = (maxHeight - topHeight).clamp(0.0, maxHeight);
              return Column(
                children: <Widget>[
                  SizedBox(height: topHeight, child: left),
                  SizedBox(height: bottomHeight, child: right),
                ],
              );
            }

            final topHeight = topSize.toDouble().clamp(0.0, maxHeight);
            final bottomHeight = (maxHeight - topHeight).clamp(0.0, maxHeight);
            return Column(
              children: <Widget>[
                SizedBox(height: topHeight, child: left),
                SizedBox(height: bottomHeight, child: right),
              ],
            );
          }

          if (maxWidth.isInfinite) {
            if (s > 0 && s < 100) {
              final rightFlex = 100 - s;
              return Row(
                children: <Widget>[
                  Expanded(flex: s, child: left),
                  Expanded(flex: rightFlex <= 0 ? 1 : rightFlex, child: right),
                ],
              );
            }
            if (s > 100) {
              return Row(
                children: <Widget>[
                  SizedBox(width: s.toDouble(), child: left),
                  Expanded(child: right),
                ],
              );
            }
            return Row(
              children: <Widget>[
                Expanded(child: left),
                Expanded(child: right),
              ],
            );
          }

          if (s > 0 && s < 100) {
            final leftWidth = maxWidth * (s / 100);
            final rightWidth = (maxWidth - leftWidth).clamp(0.0, maxWidth);
            return Row(
              children: <Widget>[
                SizedBox(width: leftWidth, child: left),
                SizedBox(width: rightWidth, child: right),
              ],
            );
          }

          if (s >= 100) {
            final leftWidth = s.toDouble().clamp(0.0, maxWidth);
            final rightWidth = (maxWidth - leftWidth).clamp(0.0, maxWidth);
            return Row(
              children: <Widget>[
                SizedBox(width: leftWidth, child: left),
                SizedBox(width: rightWidth, child: right),
              ],
            );
          }

          return Row(
            children: <Widget>[
              Expanded(child: left),
              Expanded(child: right),
            ],
          );
        },
      ),
    );
  }
}
