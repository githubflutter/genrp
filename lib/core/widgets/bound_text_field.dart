import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';

class BoundTextField extends StatefulWidget {
  const BoundTextField({required this.autopilot, required this.bind, this.label, super.key});

  final Autopilot autopilot;
  final String bind;
  final String? label;

  @override
  State<BoundTextField> createState() => _BoundTextFieldState();
}

class _BoundTextFieldState extends State<BoundTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _currentValue);
  }

  @override
  void didUpdateWidget(covariant BoundTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextValue = _currentValue;
    if (_controller.text == nextValue) return;
    _controller.value = TextEditingValue(
      text: nextValue,
      selection: TextSelection.collapsed(offset: nextValue.length),
    );
  }

  String get _currentValue => widget.autopilot.resolve(widget.bind)?.toString() ?? '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(labelText: widget.label),
      onChanged: (value) => widget.autopilot.updateBinding(widget.bind, value),
    );
  }
}
