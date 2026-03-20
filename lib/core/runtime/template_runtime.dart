import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/model/uschema/ux_template_spec.dart';
import 'package:genrp/core/theme/genrp_theme.dart';
import 'package:genrp/core/widgets/x_button.dart';
import 'package:genrp/core/widgets/x_text_box.dart';

typedef RuntimeNodeBuilder =
    Widget Function(
      UxNodeSpec node,
      Autopilot autopilot,
      Widget Function(UxNodeSpec childNode) renderChild,
    );

/// Runtime that renders the current small widget set from JSON nodes.
class TemplateRuntime {
  const TemplateRuntime();

  static final Map<String, RuntimeNodeBuilder> _builders = {
    'column': (node, autopilot, renderChild) =>
        _RuntimeColumn(node: node, renderChild: renderChild),
    'spacer': (node, autopilot, renderChild) => _RuntimeSpacer(node: node),
    'textField': (node, autopilot, renderChild) =>
        _RuntimeTextField(node: node, autopilot: autopilot),
    'button': (node, autopilot, renderChild) =>
        _RuntimeButton(node: node, autopilot: autopilot),
    'text': (node, autopilot, renderChild) =>
        _RuntimeText(node: node, autopilot: autopilot),
  };

  Widget render(dynamic nodeInput, Autopilot autopilot) {
    final node = nodeInput is UxNodeSpec
        ? nodeInput
        : UxNodeSpec.fromJson(Map<String, dynamic>.from(nodeInput as Map));
    final type = node.type.isEmpty ? 'text' : node.type;
    final builder = _builders[type] ?? _builders['text']!;
    return builder(
      node,
      autopilot,
      (childNode) => render(childNode, autopilot),
    );
  }
}

class _RuntimeColumn extends StatelessWidget {
  const _RuntimeColumn({required this.node, required this.renderChild});

  final UxNodeSpec node;
  final Widget Function(UxNodeSpec childNode) renderChild;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: node.children.map(renderChild).toList(growable: false),
    );
  }
}

class _RuntimeSpacer extends StatelessWidget {
  const _RuntimeSpacer({required this.node});

  final UxNodeSpec node;

  @override
  Widget build(BuildContext context) {
    final height = node.height ?? 12;
    return SizedBox(height: height);
  }
}

class _RuntimeTextField extends StatelessWidget {
  const _RuntimeTextField({required this.node, required this.autopilot});

  final UxNodeSpec node;
  final Autopilot autopilot;

  @override
  Widget build(BuildContext context) {
    return XTextBox(node: node, autopilot: autopilot);
  }
}

class _RuntimeButton extends StatelessWidget {
  const _RuntimeButton({required this.node, required this.autopilot});

  final UxNodeSpec node;
  final Autopilot autopilot;

  @override
  Widget build(BuildContext context) {
    return XButton(node: node, autopilot: autopilot);
  }
}

class _RuntimeText extends StatelessWidget {
  const _RuntimeText({required this.node, required this.autopilot});

  final UxNodeSpec node;
  final Autopilot autopilot;

  @override
  Widget build(BuildContext context) {
    final resolvedValue = autopilot.resolveFieldBinding(
      src: node.src,
      fieldId: node.fieldId,
      fallbackPath: node.bind,
    );
    final text = node.bind.isEmpty
        ? node.text
        : '${node.prefix}${resolvedValue ?? ''}${node.suffix}';
    final style = node.style == 'headline'
        ? Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: GenrpTheme.fontXl,
            fontWeight: FontWeight.w700,
          )
        : null;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(text, style: style),
    );
  }
}
