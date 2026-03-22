import 'package:flutter/material.dart';
import 'package:genrp/core/model/uschema/ux_template_action_spec.dart';

enum FloatingIslandSide { left, right }

/// A side-docked floating island that can be dragged vertically and expanded
/// inward to reveal up to four actions.
class DraggableFAB extends StatefulWidget {
  const DraggableFAB({
    super.key,
    required this.actions,
    required this.onAction,
    this.icon = Icons.touch_app,
    this.backgroundColor,
    this.foregroundColor,
    this.initialTop = 120,
    this.initialSide = FloatingIslandSide.right,
    this.screenPadding = 16,
    this.mainSize = 56,
    this.childSize = 44,
    this.maxActions = 4,
  });

  final List<UxTemplateActionSpec> actions;
  final void Function(UxTemplateAction action, Map<String, Object?> payload) onAction;
  final IconData icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double initialTop;
  final FloatingIslandSide initialSide;
  final double screenPadding;
  final double mainSize;
  final double childSize;
  final int maxActions;

  @override
  State<DraggableFAB> createState() => _DraggableFABState();
}

class _DraggableFABState extends State<DraggableFAB> with SingleTickerProviderStateMixin {
  late double _top;
  late FloatingIslandSide _side;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _expanded = false;

  List<UxTemplateActionSpec> get _visibleActions => widget.actions.where((UxTemplateActionSpec action) => action.visible).take(widget.maxActions).toList(growable: false);

  @override
  void initState() {
    super.initState();
    _top = widget.initialTop;
    _side = widget.initialSide;
    _controller = AnimationController(duration: const Duration(milliseconds: 180), vsync: this);
    _expandAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
    });
    if (_expanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _switchSide() {
    setState(() {
      _side = _side == FloatingIslandSide.left ? FloatingIslandSide.right : FloatingIslandSide.left;
    });
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    final Size screenSize = MediaQuery.of(context).size;
    final double minTop = widget.screenPadding;
    final double maxTop = screenSize.height - widget.mainSize - widget.screenPadding;
    setState(() {
      _top = (_top + details.delta.dy).clamp(minTop, maxTop);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color backgroundColor = widget.backgroundColor ?? theme.floatingActionButtonTheme.backgroundColor ?? theme.colorScheme.secondaryContainer;
    final Color foregroundColor = widget.foregroundColor ?? theme.floatingActionButtonTheme.foregroundColor ?? theme.colorScheme.onSecondaryContainer;
    final bool dockLeft = _side == FloatingIslandSide.left;
    final List<Widget> stackChildren = <Widget>[
      SizeTransition(
        sizeFactor: _expandAnimation,
        axis: Axis.horizontal,
        axisAlignment: dockLeft ? -1 : 1,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: dockLeft
              ? <Widget>[_buildMainButton(backgroundColor, foregroundColor), const SizedBox(width: 8), _buildActions(theme, expandRight: true)]
              : <Widget>[_buildActions(theme, expandRight: false), const SizedBox(width: 8), _buildMainButton(backgroundColor, foregroundColor)],
        ),
      ),
    ];

    if (!_expanded) {
      stackChildren[0] = _buildMainButton(backgroundColor, foregroundColor);
    }

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      top: _top,
      left: dockLeft ? 0 : null,
      right: dockLeft ? null : 0,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onLongPress: _switchSide,
          onVerticalDragUpdate: _onVerticalDragUpdate,
          behavior: HitTestBehavior.opaque,
          child: Row(mainAxisSize: MainAxisSize.min, children: stackChildren),
        ),
      ),
    );
  }

  Widget _buildActions(ThemeData theme, {required bool expandRight}) {
    final List<UxTemplateActionSpec> actions = _visibleActions;
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: actions
          .map<Widget>(
            (UxTemplateActionSpec action) => Padding(
              padding: EdgeInsets.only(left: expandRight ? 0 : 8, right: expandRight ? 8 : 0),
              child: Tooltip(
                message: action.effectiveTooltip,
                child: FloatingActionButton.small(
                  heroTag: null,
                  onPressed: action.enabled
                      ? () {
                          widget.onAction(action.action, action.payload);
                          _toggleExpanded();
                        }
                      : null,
                  backgroundColor: action.backgroundColor ?? theme.floatingActionButtonTheme.backgroundColor,
                  foregroundColor: action.foregroundColor ?? theme.floatingActionButtonTheme.foregroundColor,
                  child: Icon(action.effectiveIcon, size: widget.childSize * 0.45),
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }

  Widget _buildMainButton(Color backgroundColor, Color foregroundColor) {
    return Tooltip(
      message: _expanded ? 'Close actions' : 'Open actions. Long press to move to the other side.',
      child: SizedBox(
        width: widget.mainSize,
        height: widget.mainSize,
        child: FloatingActionButton(
          heroTag: null,
          onPressed: _toggleExpanded,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Icon(
              _expanded ? Icons.close : widget.icon,
              key: ValueKey<bool>(_expanded),
            ),
          ),
        ),
      ),
    );
  }
}
