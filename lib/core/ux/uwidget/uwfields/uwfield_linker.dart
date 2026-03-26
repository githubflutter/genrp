import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/ux/mixins.dart';
import 'package:genrp/core/ux/uwidget/uwfield.dart';
import 'package:genrp/core/theme/theme.dart';

/// Dedicated link/unlink field widget for state-bound values.
///
/// Use this directly for better performance when you know you need link mode,
/// or use [UwField] with [UwFieldMode.link] for mode-dispatched convenience.
class UwFieldLinker extends StatefulWidget with Ux {
  const UwFieldLinker({
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
    final value = widget.autopilot.readBindable(widget.spec, context: context);
    final text = value?.toString() ?? '';
    if (_controller.text != text) {
      _controller.text = text;
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _pushToAutopilot() {
    final value = _controller.text;
    widget.autopilot.writeBindable(
      widget.spec,
      value,
      context: context,
      notify: true,
    );
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
              border: Border.all(
                color: UxTheme.colors(context).secondary.withValues(alpha: 0.5),
              ),
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
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  onPressed: _isLinked ? _syncFromAutopilot : _pushToAutopilot,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
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
class UwFieldLinkerSpec with UwStateBindable {
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
  @override
  final String? stateKey;
  @override
  final int stateSrc; // 0 = chrome, 1 = data, 3 = template
  @override
  final String? stateScope;
  final String? leftTooltip;
  final String? rightTooltip;
}
