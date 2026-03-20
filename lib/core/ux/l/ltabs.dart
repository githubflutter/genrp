import 'package:flutter/widgets.dart';
import 'package:genrp/core/ux/a/pilot.dart';
import 'package:genrp/core/ux/l/l.dart';
import 'package:genrp/core/ux/t/template.dart';
import 'package:genrp/core/ux/theme.dart';

class Ltabs extends StatelessWidget with L {
  // Tab rule:
  // s -> active tab index
  // labels are optional; when omitted, child template names are used
  Ltabs({
    required this.i,
    required this.autopilot,
    required this.children,
    this.labels = const <String>[],
    this.onChanged,
    this.s = 0,
    super.key,
  }) : assert(children.isNotEmpty, 'Ltabs requires at least one child'),
       assert(
         children.every((StatelessWidget child) => child is Template),
         'Ltabs children must be Template variants',
       ),
       assert(
         labels.isEmpty || labels.length == children.length,
         'Ltabs labels length must match children length',
       );

  @override
  final int lid = 4;

  @override
  final int s;

  @override
  final int i;

  final UxPilot autopilot;
  final List<StatelessWidget> children;
  final List<String> labels;
  final ValueChanged<int>? onChanged;

  @override
  final String n = 'ltabs';

  @override
  Widget build(BuildContext context) {
    final activeIndex = s.clamp(0, children.length - 1);
    final palette = UxTheme.colors(context);
    final tabLabels = labels.isEmpty
        ? children.map<String>(_fallbackLabel).toList()
        : labels;

    Widget buildHeader() {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: <Widget>[
          for (var index = 0; index < children.length; index++)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onChanged == null ? null : () => onChanged!(index),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: index == activeIndex
                      ? palette.primary.withValues(alpha: 0.18)
                      : UxTheme.panelColor(context),
                  borderRadius: UxTheme.radius,
                  border: Border.all(
                    color: index == activeIndex
                        ? palette.primary.withValues(alpha: 0.45)
                        : UxTheme.outlineColor(context),
                  ),
                ),
                child: Padding(
                  padding: UxTheme.compactPadding,
                  child: Text(
                    tabLabels[index],
                    style: (UxTheme.bodyStyle(context) ?? const TextStyle())
                        .copyWith(
                          color: index == activeIndex
                              ? palette.primary
                              : palette.onSurface,
                        ),
                  ),
                ),
              ),
            ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxHeight.isInfinite) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              buildHeader(),
              const SizedBox(height: 12),
              children[activeIndex],
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            buildHeader(),
            const SizedBox(height: 12),
            Expanded(child: children[activeIndex]),
          ],
        );
      },
    );
  }

  String _fallbackLabel(StatelessWidget child) {
    final Object candidate = child;
    if (candidate is Template) {
      return candidate.n;
    }
    return 'tab';
  }
}
