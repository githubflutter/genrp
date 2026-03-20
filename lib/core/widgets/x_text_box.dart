import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/model/uschema/ux_template_spec.dart';

class XTextBox extends StatefulWidget {
  const XTextBox({required this.node, required this.autopilot, super.key});

  final UxNodeSpec node;
  final Autopilot autopilot;

  @override
  State<XTextBox> createState() => _XTextBoxState();
}

class _XTextBoxState extends State<XTextBox> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _currentValue);
  }

  @override
  void didUpdateWidget(covariant XTextBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextValue = _currentValue;
    if (_controller.text == nextValue) return;
    _controller.value = TextEditingValue(
      text: nextValue,
      selection: TextSelection.collapsed(offset: nextValue.length),
    );
  }

  String get _currentValue =>
      widget.autopilot
          .resolveFieldBinding(
            src: widget.node.src,
            fieldId: widget.node.fieldId,
            fallbackPath: widget.node.bind,
          )
          ?.toString() ??
      '';

  bool get _isSelected => widget.autopilot.isSelectedUxIdentity(
    hostId: widget.node.hostId,
    bodyId: widget.node.bodyId,
    widgetId: widget.node.widgetId,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      key: ValueKey(
        'x-text-box-${widget.node.hostId}-${widget.node.bodyId}-${widget.node.widgetId}',
      ),
      decoration: BoxDecoration(
        border: _isSelected
            ? Border.all(color: theme.colorScheme.primary, width: 2)
            : null,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: _isSelected ? const EdgeInsets.all(2) : EdgeInsets.zero,
        child: GestureDetector(
          onLongPress: kDebugMode
              ? () => widget.autopilot.selectUxIdentity(
                  hostId: widget.node.hostId,
                  bodyId: widget.node.bodyId,
                  widgetId: widget.node.widgetId,
                )
              : null,
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: widget.node.label.isEmpty
                  ? widget.node.n
                  : widget.node.label,
            ),
            onChanged: (value) => widget.autopilot.updateFieldBinding(
              src: widget.node.src,
              fieldId: widget.node.fieldId,
              fallbackPath: widget.node.bind,
              value: value,
            ),
          ),
        ),
      ),
    );
  }
}
