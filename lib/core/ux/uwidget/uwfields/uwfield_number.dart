import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/ux/mixins.dart';
import 'package:genrp/core/ux/uwidget/uwfield.dart';

/// Dedicated number input field widget.
///
/// Use this directly for better performance when you know you need number mode,
/// or use [UwField] with [UwFieldMode.number] for mode-dispatched convenience.
class UwFieldNumber extends StatefulWidget with Ux {
  const UwFieldNumber({
    required this.i,
    required this.autopilot,
    required this.spec,
    this.callbacks = const UwFieldCallbacks(),
    this.s = 0,
    super.key,
  });

  final int uwid = 14;
  final int s;
  @override
  final int i;
  @override
  final String n = 'field_number';

  final Autopilot autopilot;
  final UwFieldNumberSpec spec;
  final UwFieldCallbacks callbacks;

  @override
  State<UwFieldNumber> createState() => _UwFieldNumberState();
}

class _UwFieldNumberState extends State<UwFieldNumber> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatValue(widget.spec.value));
  }

  @override
  void didUpdateWidget(covariant UwFieldNumber oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.spec.value != oldWidget.spec.value) {
      _controller.text = _formatValue(widget.spec.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatValue(num? value) {
    if (value == null) return '';
    return value.toString();
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
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            decoration: InputDecoration(
              labelText: widget.spec.label,
              hintText: widget.spec.hint,
              suffixIcon: _controller.text.isNotEmpty || widget.spec.rightIcon != null
                  ? _buildRightButton(widget.spec.rightIcon ?? Icons.clear, widget.spec.rightTooltip)
                  : null,
            ),
            onChanged: (String val) {
              setState(() {});
              if (val.isEmpty) {
                widget.callbacks.onChanged?.call(null);
              } else {
                final numValue = num.tryParse(val);
                widget.callbacks.onChanged?.call(numValue);
              }
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
            widget.callbacks.onChanged?.call(null);
            setState(() {});
          },
    );
  }
}

/// Spec for [UwFieldNumber] - lighter weight than full [UwFieldSpec].
class UwFieldNumberSpec {
  const UwFieldNumberSpec({
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
  final num? value;
  final bool readOnly;
  final IconData? leftIcon;
  final String? leftTooltip;
  final IconData? rightIcon;
  final String? rightTooltip;
}
