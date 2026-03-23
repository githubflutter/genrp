import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/ux/mixins.dart';
import 'package:genrp/core/ux/uwidget/uwfield.dart';

/// Dedicated filter field widget with operator cycling.
///
/// Use this directly for better performance when you know you need filter mode,
/// or use [UwField] with [UwFieldMode.filter] for mode-dispatched convenience.
class UwFieldFilter extends StatefulWidget with Ux {
  const UwFieldFilter({required this.i, required this.autopilot, required this.spec, this.callbacks = const UwFieldCallbacks(), this.s = 0, super.key});

  final int uwid = 14;
  final int s;
  @override
  final int i;
  @override
  final String n = 'field_filter';

  final Autopilot autopilot;
  final UwFieldFilterSpec spec;
  final UwFieldCallbacks callbacks;

  @override
  State<UwFieldFilter> createState() => _UwFieldFilterState();
}

class _UwFieldFilterState extends State<UwFieldFilter> {
  late TextEditingController _controller;
  late FilterOp _currentOp;
  bool _isApplied = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _currentOp = widget.spec.filterOp;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _cycleOp() {
    setState(() {
      switch (_currentOp) {
        case FilterOp.contains:
          _currentOp = FilterOp.startsWith;
          break;
        case FilterOp.startsWith:
          _currentOp = FilterOp.endsWith;
          break;
        case FilterOp.endsWith:
          _currentOp = FilterOp.except;
          break;
        case FilterOp.except:
          _currentOp = FilterOp.contains;
          break;
      }
      if (_isApplied) {
        _apply();
      }
    });
  }

  void _apply() {
    setState(() {
      _isApplied = true;
    });
    widget.callbacks.onFilterApplied?.call({'op': _currentOp, 'value': _controller.text});
    widget.callbacks.onChanged?.call({'op': _currentOp, 'value': _controller.text});
  }

  void _clear() {
    _controller.clear();
    setState(() {
      _isApplied = false;
      _currentOp = FilterOp.contains;
    });
    widget.callbacks.onFilterCleared?.call();
    widget.callbacks.onChanged?.call(null);
  }

  String _badgeLabel() {
    switch (_currentOp) {
      case FilterOp.contains:
        return 'C';
      case FilterOp.startsWith:
        return 'S';
      case FilterOp.endsWith:
        return 'E';
      case FilterOp.except:
        return 'X';
    }
  }

  Color _badgeColor(BuildContext context) {
    switch (_currentOp) {
      case FilterOp.contains:
        return Colors.blue;
      case FilterOp.startsWith:
        return Colors.green;
      case FilterOp.endsWith:
        return Colors.orange;
      case FilterOp.except:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget fieldBody = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        InkWell(
          onTap: _cycleOp,
          child: Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: _badgeColor(context), shape: BoxShape.circle),
            child: Text(
              _badgeLabel(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: widget.spec.label,
              hintText: widget.spec.hint ?? 'Search...',
              suffixIcon: IconButton(
                icon: Icon(_isApplied ? Icons.close : Icons.check),
                tooltip: _isApplied ? 'Clear filter' : 'Apply filter',
                iconSize: 16,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: _isApplied ? _clear : _apply,
              ),
            ),
            onChanged: (String val) {
              if (_isApplied) {
                setState(() {
                  _isApplied = false;
                });
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
}

/// Spec for [UwFieldFilter] - filter with operator cycling.
class UwFieldFilterSpec {
  const UwFieldFilterSpec({this.label, this.hint, this.width, this.filterOp = FilterOp.contains, this.leftTooltip, this.rightTooltip});

  final String? label;
  final String? hint;
  final double? width;
  final FilterOp filterOp;
  final String? leftTooltip;
  final String? rightTooltip;
}
