import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/ux/mixins.dart';
import 'package:genrp/core/ux/uwidget/uwfield.dart';

/// Dedicated text input field widget.
///
/// Use this directly for better performance when you know you need text mode,
/// or use [UwField] with [UwFieldMode.text] for mode-dispatched convenience.
class UwFieldText extends StatefulWidget with Uwidget {
  const UwFieldText({
    required this.i,
    required this.autopilot,
    required this.spec,
    this.callbacks = const UwFieldCallbacks(),
    this.s = 0,
    super.key,
  });

  @override
  final int vid = 14;
  @override
  final int s;
  @override
  final int i;
  @override
  final String n = 'field_text';

  final Autopilot autopilot;
  final UwFieldTextSpec spec;
  final UwFieldCallbacks callbacks;

  @override
  State<UwFieldText> createState() => _UwFieldTextState();
}

class _UwFieldTextState extends State<UwFieldText> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.spec.value ?? '');
  }

  @override
  void didUpdateWidget(covariant UwFieldText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.spec.value != oldWidget.spec.value) {
      _controller.text = widget.spec.value ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget fieldBody = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        if (widget.spec.leftIcon != null) _buildLeftButton(widget.spec.leftIcon!, widget.spec.leftTooltip),
        Expanded(
          child: TextField(
            controller: _controller,
            readOnly: widget.spec.readOnly,
            decoration: InputDecoration(
              labelText: widget.spec.label,
              hintText: widget.spec.hint,
              suffixIcon: _controller.text.isNotEmpty || widget.spec.rightIcon != null
                  ? _buildRightButton(widget.spec.rightIcon ?? Icons.clear, widget.spec.rightTooltip)
                  : null,
            ),
            onChanged: (String val) {
              setState(() {});
              widget.callbacks.onChanged?.call(val);
            },
          ),
        ),
      ],
    );

    if (widget.spec.width != null) {
      fieldBody = SizedBox(width: widget.spec.width, child: fieldBody);
    }
    return fieldBody;
  }

  Widget _buildLeftButton(IconData icon, String? tooltip) {
    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      iconSize: 16,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      onPressed: widget.callbacks.onLeftPressed,
    );
  }

  Widget _buildRightButton(IconData icon, String? tooltip) {
    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      iconSize: 16,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      onPressed: widget.callbacks.onRightPressed ??
          () {
            _controller.clear();
            widget.callbacks.onChanged?.call('');
            setState(() {});
          },
    );
  }
}

/// Spec for [UwFieldText] - lighter weight than full [UwFieldSpec].
class UwFieldTextSpec {
  const UwFieldTextSpec({
    this.label,
    this.hint,
    this.width,
    this.value,
    this.readOnly = false,
    this.leftIcon,
    this.leftTooltip,
    this.rightIcon,
    this.rightTooltip,
  });

  final String? label;
  final String? hint;
  final double? width;
  final String? value;
  final bool readOnly;
  final IconData? leftIcon;
  final String? leftTooltip;
  final IconData? rightIcon;
  final String? rightTooltip;
}
