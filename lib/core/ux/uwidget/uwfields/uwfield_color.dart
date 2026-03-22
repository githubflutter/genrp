import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/ux/mixins.dart';
import 'package:genrp/core/ux/uwidget/uwfield.dart';

/// Dedicated color picker field widget.
///
/// Supports single color selection with color picker dialog.
/// Value is stored as String (hex #RRGGBB or #RRGGBBAA) or int (32-bit color).
///
/// Use this directly for better performance, or use [UwField] with
/// [UwFieldMode.color] for mode-dispatched convenience.
class UwFieldColor extends StatefulWidget with Uwidget {
  const UwFieldColor({required this.i, required this.autopilot, required this.spec, this.callbacks = const UwFieldCallbacks(), this.s = 0, super.key});

  @override
  final int vid = 14;
  @override
  final int s;
  @override
  final int i;
  @override
  final String n = 'field_color';

  final Autopilot autopilot;
  final UwFieldColorSpec spec;
  final UwFieldCallbacks callbacks;

  @override
  State<UwFieldColor> createState() => _UwFieldColorState();
}

class _UwFieldColorState extends State<UwFieldColor> {
  Color _currentColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _syncColor();
  }

  @override
  void didUpdateWidget(covariant UwFieldColor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.spec.value != oldWidget.spec.value) {
      _syncColor();
    }
  }

  void _syncColor() {
    final value = widget.spec.value;
    if (value == null) {
      _currentColor = Colors.grey;
      return;
    }

    if (value is int) {
      _currentColor = Color(value);
    } else if (value is String) {
      _currentColor = _parseColor(value);
    }
  }

  Color _parseColor(String value) {
    var hex = value.replaceFirst('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    if (hex.length != 8) {
      return Colors.grey;
    }
    try {
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }

  String _formatColor(Color color) {
    if (widget.spec.format == ColorFormat.rgba) {
      return 'rgba(${(color.r * 255).round()}, ${(color.g * 255).round()}, ${(color.b * 255).round()}, ${color.a.toStringAsFixed(2)})';
    } else if (widget.spec.format == ColorFormat.rgb) {
      return 'rgb(${(color.r * 255).round()}, ${(color.g * 255).round()}, ${(color.b * 255).round()})';
    } else {
      // Hex format (default)
      return '#${color.a.round().toRadixString(16).padLeft(2, '0')}${color.r.round().toRadixString(16).padLeft(2, '0')}${color.g.round().toRadixString(16).padLeft(2, '0')}${color.b.round().toRadixString(16).padLeft(2, '0')}'
          .toUpperCase();
    }
  }

  Future<void> _pickColor() async {
    final pickedColor = await showDialog<Color>(
      context: context,
      builder: (BuildContext context) {
        return _ColorPickerDialog(initialColor: _currentColor);
      },
    );

    if (pickedColor == null) return;

    _currentColor = pickedColor;
    setState(() {});

    if (widget.spec.valueIsInt) {
      widget.callbacks.onChanged?.call(pickedColor.toARGB32());
    } else {
      widget.callbacks.onChanged?.call(_formatColor(pickedColor));
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget fieldBody = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        if (widget.spec.leftIcon != null)
          IconButton(
            icon: Icon(widget.spec.leftIcon),
            tooltip: widget.spec.leftTooltip,
            iconSize: 16,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: widget.callbacks.onLeftPressed,
          ),
        Expanded(
          child: GestureDetector(
            onTap: widget.spec.readOnly ? null : _pickColor,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: widget.spec.label,
                hintText: widget.spec.hint ?? 'Select color',
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Color preview swatch
                    Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: _currentColor,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    IconButton(
                      icon: Icon(widget.spec.rightIcon ?? Icons.color_lens),
                      tooltip: widget.spec.rightTooltip ?? 'Pick color',
                      iconSize: 16,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      onPressed: widget.spec.readOnly ? null : _pickColor,
                    ),
                  ],
                ),
              ),
              child: Text(_formatColor(_currentColor)),
            ),
          ),
        ),
      ],
    );

    if (widget.spec.width != null) {
      fieldBody = SizedBox(width: widget.spec.width, child: fieldBody);
    }
    return fieldBody;
  }
}

/// Simple color picker dialog
class _ColorPickerDialog extends StatefulWidget {
  const _ColorPickerDialog({required this.initialColor});

  final Color initialColor;

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late Color _selectedColor;
  late double _hue;
  late double _saturation;
  late double _brightness;
  late double _alpha;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
    final hsb = _toHSB(_selectedColor);
    _hue = hsb[0];
    _saturation = hsb[1];
    _brightness = hsb[2];
    _alpha = _selectedColor.a;
  }

  List<double> _toHSB(Color color) {
    final r = color.r;
    final g = color.g;
    final b = color.b;

    final max = r > g ? (r > b ? r : b) : (g > b ? g : b);
    final min = r < g ? (r < b ? r : b) : (g < b ? g : b);
    final delta = max - min;

    double h = 0;
    if (delta > 0) {
      if (max == r) {
        h = 60 * (((g - b) / delta) % 6);
      } else if (max == g) {
        h = 60 * (((b - r) / delta) + 2);
      } else {
        h = 60 * (((r - g) / delta) + 4);
      }
    }

    final s = max > 0 ? delta / max : 0.0;
    final brightness = max;

    return <double>[h, s, brightness];
  }

  Color _fromHSB(double h, double s, double b) {
    final c = b * s;
    final x = c * (1 - ((h / 60) % 2 - 1).abs());

    double r, g, bl;
    if (h < 60) {
      r = c;
      g = x;
      bl = 0;
    } else if (h < 120) {
      r = x;
      g = c;
      bl = 0;
    } else if (h < 180) {
      r = 0;
      g = c;
      bl = x;
    } else if (h < 240) {
      r = 0;
      g = x;
      bl = c;
    } else if (h < 300) {
      r = x;
      g = 0;
      bl = c;
    } else {
      r = c;
      g = 0;
      bl = x;
    }

    return Color.fromRGBO((r * 255).round().clamp(0, 255), (g * 255).round().clamp(0, 255), (bl * 255).round().clamp(0, 255), _alpha);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pick Color'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Color preview
          Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              color: _selectedColor,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          // Hue slider
          Row(
            children: [
              const Text('H', style: TextStyle(fontSize: 12)),
              Expanded(
                child: Slider(
                  value: _hue,
                  min: 0,
                  max: 360,
                  divisions: 360,
                  onChanged: (value) {
                    setState(() {
                      _hue = value;
                      _selectedColor = _fromHSB(_hue, _saturation, _brightness).withValues(alpha: _alpha);
                    });
                  },
                ),
              ),
            ],
          ),
          // Saturation slider
          Row(
            children: [
              const Text('S', style: TextStyle(fontSize: 12)),
              Expanded(
                child: Slider(
                  value: _saturation,
                  min: 0,
                  max: 1,
                  onChanged: (value) {
                    setState(() {
                      _saturation = value;
                      _selectedColor = _fromHSB(_hue, _saturation, _brightness).withValues(alpha: _alpha);
                    });
                  },
                ),
              ),
            ],
          ),
          // Brightness slider
          Row(
            children: [
              const Text('B', style: TextStyle(fontSize: 12)),
              Expanded(
                child: Slider(
                  value: _brightness,
                  min: 0,
                  max: 1,
                  onChanged: (value) {
                    setState(() {
                      _brightness = value;
                      _selectedColor = _fromHSB(_hue, _saturation, _brightness).withValues(alpha: _alpha);
                    });
                  },
                ),
              ),
            ],
          ),
          // Alpha slider
          Row(
            children: [
              const Text('A', style: TextStyle(fontSize: 12)),
              Expanded(
                child: Slider(
                  value: _alpha,
                  min: 0,
                  max: 1,
                  onChanged: (value) {
                    setState(() {
                      _alpha = value;
                      _selectedColor = _selectedColor.withValues(alpha: value);
                    });
                  },
                ),
              ),
            ],
          ),
          // Preset colors
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                [
                  Colors.red,
                  Colors.pink,
                  Colors.purple,
                  Colors.deepPurple,
                  Colors.indigo,
                  Colors.blue,
                  Colors.lightBlue,
                  Colors.cyan,
                  Colors.teal,
                  Colors.green,
                  Colors.lightGreen,
                  Colors.lime,
                  Colors.yellow,
                  Colors.amber,
                  Colors.orange,
                  Colors.deepOrange,
                  Colors.brown,
                  Colors.grey,
                  Colors.blueGrey,
                  Colors.black,
                ].map((color) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                        final hsb = _toHSB(color);
                        _hue = hsb[0];
                        _saturation = hsb[1];
                        _brightness = hsb[2];
                      });
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(null), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            setState(() {
              _selectedColor = Colors.grey;
              _alpha = 1.0;
            });
          },
          child: const Text('Reset'),
        ),
        ElevatedButton(onPressed: () => Navigator.of(context).pop(_selectedColor), child: const Text('OK')),
      ],
    );
  }
}

/// Color format for [UwFieldColor].
enum ColorFormat { hex, rgb, rgba }

/// Spec for [UwFieldColor].
class UwFieldColorSpec {
  const UwFieldColorSpec({
    this.label,
    this.hint,
    this.width,
    this.value,
    this.readOnly = false,
    this.format = ColorFormat.hex,
    this.valueIsInt = false,
    this.leftIcon,
    this.leftTooltip,
    this.rightIcon,
    this.rightTooltip,
  });

  final String? label;
  final String? hint;
  final double? width;
  final dynamic value; // String (hex) or int (32-bit color)
  final bool readOnly;
  final ColorFormat format;
  final bool valueIsInt;
  final IconData? leftIcon;
  final String? leftTooltip;
  final IconData? rightIcon;
  final String? rightTooltip;
}
