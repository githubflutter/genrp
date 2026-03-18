import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/model/ux/ux_text_box_model.dart';

class XTextBox extends StatefulWidget {
  const XTextBox({
    required this.model,
    required this.autopilot,
    super.key,
  });

  final UxTextBoxModel model;
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

  String get _currentValue => widget.autopilot
          .resolveFieldBinding(
            src: widget.model.src,
            fieldId: widget.model.fieldId,
            fallbackPath: widget.model.bind,
          )
          ?.toString() ??
      '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(labelText: widget.model.n),
      onChanged: (value) => widget.autopilot.updateFieldBinding(
        src: widget.model.src,
        fieldId: widget.model.fieldId,
        fallbackPath: widget.model.bind,
        value: value,
      ),
    );
  }
}
