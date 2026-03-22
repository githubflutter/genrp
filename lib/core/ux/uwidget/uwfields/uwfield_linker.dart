import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/ux/mixins.dart';
import 'package:genrp/core/ux/uwidget/uwfield.dart';
import 'package:genrp/core/theme/theme.dart';

/// Dedicated link/unlink field widget for state-bound values.
///
/// Use this directly for better performance when you know you need link mode,
/// or use [UwField] with [UwFieldMode.link] for mode-dispatched convenience.
class UwFieldLinker extends StatefulWidget with Uwidget {
  const UwFieldLinker({
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
  final String n = 'field_linker';

  final Autopilot autopilot;
  final UwFieldLinkerSpec spec;
  final UwFieldCallbacks callbacks;

  @override
  State<UwFieldLinker> createState() => _UwFieldLinkerState();
}

class _UwFieldLinkerState extends State<UwFieldLinker> {
  late TextEditingController _controller;
  bool _isLinked = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _isLinked = true;
    if (_isLinked) {
      widget.autopilot.addListener(_onAutopilotChanged);
      _syncFromAutopilot();
    }
  }

  @override
  void dispose() {
    widget.autopilot.removeListener(_onAutopilotChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onAutopilotChanged() {
    if (_isLinked) {
      _syncFromAutopilot();
    }
  }

  void _syncFromAutopilot() {
    if (widget.spec.stateKey == null) return;
    dynamic value;
    switch (widget.spec.stateSrc) {
      case 0: // chrome
        value = widget.autopilot.stateSet.chrome<dynamic>(widget.spec.stateKey!);
        break;
      case 1: // dataSet
        value = widget.autopilot.data(widget.spec.stateKey!);
        break;
      case 2: // scoped
        if (widget.spec.stateScope != null) {
          value = widget.autopilot.stateSet.getPaper<dynamic>(widget.spec.stateScope!, widget.spec.stateKey!);
          value ??= widget.autopilot.stateSet.getTemplate<dynamic>(widget.spec.stateScope!, widget.spec.stateKey!);
        }
        break;
    }
    final text = value?.toString() ?? '';
    if (_controller.text != text) {
      _controller.text = text;
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _pushToAutopilot() {
    if (widget.spec.stateKey == null) return;
    final value = _controller.text;
    switch (widget.spec.stateSrc) {
      case 0:
        widget.autopilot.setChromeState(widget.spec.stateKey!, value, notify: true);
        break;
      case 1:
        widget.autopilot.setData(widget.spec.stateKey!, value, notify: true);
        break;
      case 2:
        if (widget.spec.stateScope != null) {
          widget.autopilot.setPaperState(widget.spec.stateScope!, widget.spec.stateKey!, value, notify: true);
        }
        break;
    }
    widget.callbacks.onPush?.call(value);
  }

  void _toggleLink() {
    setState(() {
      _isLinked = !_isLinked;
      if (_isLinked) {
        widget.autopilot.addListener(_onAutopilotChanged);
        _pushToAutopilot();
      } else {
        widget.autopilot.removeListener(_onAutopilotChanged);
      }
    });
    widget.callbacks.onLink?.call(_isLinked);
  }

  @override
  Widget build(BuildContext context) {
    Widget fieldBody = Container(
      decoration: _isLinked
          ? BoxDecoration(
              border: Border.all(color: UxTheme.colors(context).secondary.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(4),
            )
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          IconButton(
            icon: Icon(_isLinked ? Icons.link : Icons.link_off),
            tooltip: _isLinked ? 'Unlink' : 'Link',
            iconSize: 16,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: _toggleLink,
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              readOnly: _isLinked || widget.spec.readOnly,
              decoration: InputDecoration(
                labelText: widget.spec.label,
                hintText: widget.spec.hint,
                suffixIcon: IconButton(
                  icon: Icon(_isLinked ? Icons.refresh : Icons.upload),
                  tooltip: _isLinked ? 'Refresh from state' : 'Push to state',
                  iconSize: 16,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: _isLinked ? _syncFromAutopilot : _pushToAutopilot,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              onChanged: widget.callbacks.onChanged,
            ),
          ),
        ],
      ),
    );

    if (widget.spec.width != null) {
      fieldBody = SizedBox(width: widget.spec.width, child: fieldBody);
    }
    return fieldBody;
  }
}

/// Spec for [UwFieldLinker] - state-bound link/unlink field.
class UwFieldLinkerSpec {
  const UwFieldLinkerSpec({
    this.label,
    this.hint,
    this.width,
    this.value,
    this.readOnly = false,
    this.stateKey,
    this.stateSrc = 0,
    this.stateScope,
    this.leftTooltip,
    this.rightTooltip,
  });

  final String? label;
  final String? hint;
  final double? width;
  final dynamic value;
  final bool readOnly;
  final String? stateKey;
  final int stateSrc; // 0 = chrome, 1 = dataSet, 2 = scoped
  final String? stateScope;
  final String? leftTooltip;
  final String? rightTooltip;
}
