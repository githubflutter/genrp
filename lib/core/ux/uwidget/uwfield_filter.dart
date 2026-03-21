import 'package:flutter/material.dart';
import 'package:genrp/core/ux/uwidget/uwfield.dart';

class UwFieldFilter extends StatefulWidget {
  const UwFieldFilter({
    required this.spec,
    required this.callbacks,
    required this.controller,
    super.key,
  });

  final UwFieldSpec spec;
  final UwFieldCallbacks callbacks;
  final TextEditingController controller;

  @override
  State<UwFieldFilter> createState() => _UwFieldFilterState();
}

class _UwFieldFilterState extends State<UwFieldFilter> {
  late FilterOp _currentOp;
  bool _isApplied = false;

  @override
  void initState() {
    super.initState();
    _currentOp = widget.spec.filterOp;
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
    widget.callbacks.onFilterApplied?.call({
      'op': _currentOp,
      'value': widget.controller.text,
    });
    widget.callbacks.onChanged?.call({
      'op': _currentOp,
      'value': widget.controller.text,
    });
  }

  void _clear() {
    widget.controller.clear();
    setState(() {
      _isApplied = false;
      _currentOp = FilterOp.contains;
    });
    widget.callbacks.onFilterCleared?.call();
    widget.callbacks.onChanged?.call(null);
  }

  String _badgeLabel() {
    switch (_currentOp) {
      case FilterOp.contains: return 'C';
      case FilterOp.startsWith: return 'S';
      case FilterOp.endsWith: return 'E';
      case FilterOp.except: return 'X';
    }
  }

  Color _badgeColor(BuildContext context) {
    switch (_currentOp) {
      case FilterOp.contains: return Colors.blue;
      case FilterOp.startsWith: return Colors.green;
      case FilterOp.endsWith: return Colors.orange;
      case FilterOp.except: return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        InkWell(
          onTap: _cycleOp,
          child: Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _badgeColor(context),
              shape: BoxShape.circle,
            ),
            child: Text(
              _badgeLabel(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: widget.controller,
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
  }
}
