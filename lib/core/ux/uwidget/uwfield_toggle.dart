import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/theme/theme.dart';
import 'package:genrp/core/ux/uwidget/uwfield.dart';

class UwFieldToggle extends StatefulWidget {
  const UwFieldToggle({
    required this.spec,
    required this.callbacks,
    required this.autopilot,
    required this.controller,
    super.key,
  });

  final UwFieldSpec spec;
  final UwFieldCallbacks callbacks;
  final Autopilot autopilot;
  final TextEditingController controller;

  @override
  State<UwFieldToggle> createState() => _UwFieldToggleState();
}

class _UwFieldToggleState extends State<UwFieldToggle> {
  bool _isLinked = true;

  @override
  void initState() {
    super.initState();
    _isLinked = widget.spec.mode == UwFieldMode.link;
    if (_isLinked) {
      widget.autopilot.addListener(_onAutopilotChanged);
      _syncFromAutopilot();
    }
  }

  @override
  void dispose() {
    widget.autopilot.removeListener(_onAutopilotChanged);
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
    if (widget.controller.text != text) {
      widget.controller.text = text;
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _pushToAutopilot() {
    if (widget.spec.stateKey == null) return;
    final value = widget.controller.text;
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
    return Container(
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
              controller: widget.controller,
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
  }
}
