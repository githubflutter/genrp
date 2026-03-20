import 'package:flutter/widgets.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/ux/paper.dart';
import 'package:genrp/core/ux/template.dart';

class Pthree extends StatelessWidget with Paper {
  // Split rule:
  // s > 0  -> horizontal
  // s < 0  -> vertical
  // abs(s) <= 9999  -> percentage mode, left-pad to 4 digits and split AABB
  // abs(s) > 9999   -> pixel mode, left-pad to 6 digits and split AAABBB
  // first/last or top/bottom are encoded, middle expands to the remainder
  // Precaution: 100% total limits and minimum pane clipping are not checked here.
  // API users must validate those values before passing them in.
  const Pthree({required this.i, required this.autopilot, required this.first, required this.middle, required this.last, this.s = 0, super.key})
    : assert(first is Template, 'Pthree first child must be a Template variant'),
      assert(middle is Template, 'Pthree middle child must be a Template variant'),
      assert(last is Template, 'Pthree last child must be a Template variant');

  @override
  final int pid = 3;

  @override
  final int s;

  @override
  final int i;

  final Autopilot autopilot;
  final StatelessWidget first;
  final StatelessWidget middle;
  final StatelessWidget last;

  @override
  final String n = 'paperthree';

  @override
  Widget build(BuildContext context) {
    return UxPaperHost(
      i: i,
      autopilot: autopilot,
      child: Builder(
        builder: (BuildContext context) {
          if (s == 0) {
            return Row(
              children: <Widget>[
                Expanded(child: first),
                Expanded(child: middle),
                Expanded(child: last),
              ],
            );
          }

          final vertical = s < 0;
          final raw = s.abs();
          final isPixelMode = raw > 9999;
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              if (vertical) {
                return isPixelMode ? _buildVerticalPixel(constraints, raw) : _buildVerticalPercent(constraints, raw);
              }
              return isPixelMode ? _buildHorizontalPixel(constraints, raw) : _buildHorizontalPercent(constraints, raw);
            },
          );
        },
      ),
    );
  }

  Widget _buildHorizontalPercent(BoxConstraints constraints, int raw) {
    if (constraints.maxWidth.isInfinite) {
      return Row(mainAxisSize: MainAxisSize.min, children: <Widget>[first, middle, last]);
    }
    final pair = _decodePercentPair(raw);
    final firstPercent = pair.$1;
    final lastPercent = pair.$2;
    final middlePercent = 100 - firstPercent - lastPercent;
    final children = <Widget>[
      if (firstPercent > 0) Expanded(flex: firstPercent, child: first),
      if (middlePercent > 0) Expanded(flex: middlePercent, child: middle),
      if (lastPercent > 0) Expanded(flex: lastPercent, child: last),
    ];
    if (children.isEmpty) {
      children.add(Expanded(child: middle));
    }
    return Row(children: children);
  }

  Widget _buildVerticalPercent(BoxConstraints constraints, int raw) {
    if (constraints.maxHeight.isInfinite) {
      return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[first, middle, last]);
    }
    final pair = _decodePercentPair(raw);
    final firstPercent = pair.$1;
    final lastPercent = pair.$2;
    final middlePercent = 100 - firstPercent - lastPercent;
    final children = <Widget>[
      if (firstPercent > 0) Expanded(flex: firstPercent, child: first),
      if (middlePercent > 0) Expanded(flex: middlePercent, child: middle),
      if (lastPercent > 0) Expanded(flex: lastPercent, child: last),
    ];
    if (children.isEmpty) {
      children.add(Expanded(child: middle));
    }
    return Column(children: children);
  }

  Widget _buildHorizontalPixel(BoxConstraints constraints, int raw) {
    final pair = _decodePixelPair(raw);
    final firstWidth = pair.$1.toDouble();
    final lastWidth = pair.$2.toDouble();
    if (constraints.maxWidth.isInfinite) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(width: firstWidth, child: first),
          middle,
          SizedBox(width: lastWidth, child: last),
        ],
      );
    }
    final scale = _pixelScale(firstExtent: firstWidth, lastExtent: lastWidth, totalExtent: constraints.maxWidth);
    return Row(
      children: <Widget>[
        SizedBox(width: firstWidth * scale, child: first),
        Expanded(child: middle),
        SizedBox(width: lastWidth * scale, child: last),
      ],
    );
  }

  Widget _buildVerticalPixel(BoxConstraints constraints, int raw) {
    final pair = _decodePixelPair(raw);
    final firstHeight = pair.$1.toDouble();
    final lastHeight = pair.$2.toDouble();
    if (constraints.maxHeight.isInfinite) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(height: firstHeight, child: first),
          middle,
          SizedBox(height: lastHeight, child: last),
        ],
      );
    }
    final scale = _pixelScale(firstExtent: firstHeight, lastExtent: lastHeight, totalExtent: constraints.maxHeight);
    return Column(
      children: <Widget>[
        SizedBox(height: firstHeight * scale, child: first),
        Expanded(child: middle),
        SizedBox(height: lastHeight * scale, child: last),
      ],
    );
  }

  (int, int) _decodePercentPair(int raw) {
    final text = raw.toString().padLeft(4, '0');
    return (int.parse(text.substring(0, 2)), int.parse(text.substring(2, 4)));
  }

  (int, int) _decodePixelPair(int raw) {
    final text = raw.toString().padLeft(6, '0');
    return (int.parse(text.substring(0, 3)), int.parse(text.substring(3, 6)));
  }

  double _pixelScale({required double firstExtent, required double lastExtent, required double totalExtent}) {
    final occupied = firstExtent + lastExtent;
    if (occupied <= 0 || occupied <= totalExtent) {
      return 1;
    }
    return totalExtent / occupied;
  }
}
