import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/ux/bound_text_field.dart';

typedef RuntimeNodeBuilder = Widget Function(
  Map<String, dynamic> node,
  Autopilot autopilot,
  Widget Function(Map<String, dynamic> childNode) renderChild,
);

/// Runtime that renders the current small widget set from JSON nodes.
class TemplateRuntime {
  const TemplateRuntime();

  static final Map<String, RuntimeNodeBuilder> _builders = {
    'column': (node, autopilot, renderChild) => _RuntimeColumn(
          node: node,
          renderChild: renderChild,
        ),
    'spacer': (node, autopilot, renderChild) => _RuntimeSpacer(node: node),
    'textField': (node, autopilot, renderChild) => _RuntimeTextField(
          node: node,
          autopilot: autopilot,
        ),
    'button': (node, autopilot, renderChild) => _RuntimeButton(
          node: node,
          autopilot: autopilot,
        ),
    'text': (node, autopilot, renderChild) => _RuntimeText(
          node: node,
          autopilot: autopilot,
        ),
  };

  Widget render(Map<String, dynamic> node, Autopilot autopilot) {
    final type = node['type']?.toString() ?? 'text';
    final builder = _builders[type] ?? _builders['text']!;
    return builder(node, autopilot, (childNode) => render(childNode, autopilot));
  }
}

class _RuntimeColumn extends StatelessWidget {
  const _RuntimeColumn({
    required this.node,
    required this.renderChild,
  });

  final Map<String, dynamic> node;
  final Widget Function(Map<String, dynamic> childNode) renderChild;

  @override
  Widget build(BuildContext context) {
    final children = List<Object?>.from(node['children'] as List? ?? const [])
        .whereType<Map>()
        .map((child) => renderChild(Map<String, dynamic>.from(child)))
        .toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

class _RuntimeSpacer extends StatelessWidget {
  const _RuntimeSpacer({required this.node});

  final Map<String, dynamic> node;

  @override
  Widget build(BuildContext context) {
    final height = (node['height'] as num?)?.toDouble() ?? 12;
    return SizedBox(height: height);
  }
}

class _RuntimeTextField extends StatelessWidget {
  const _RuntimeTextField({
    required this.node,
    required this.autopilot,
  });

  final Map<String, dynamic> node;
  final Autopilot autopilot;

  @override
  Widget build(BuildContext context) {
    return BoundTextField(
      autopilot: autopilot,
      bind: node['bind']?.toString() ?? '',
      label: node['label']?.toString(),
    );
  }
}

class _RuntimeButton extends StatelessWidget {
  const _RuntimeButton({
    required this.node,
    required this.autopilot,
  });

  final Map<String, dynamic> node;
  final Autopilot autopilot;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: ElevatedButton(
        onPressed: () => autopilot.triggerAction(node['action']?.toString() ?? ''),
        child: Text(node['text']?.toString() ?? 'Action'),
      ),
    );
  }
}

class _RuntimeText extends StatelessWidget {
  const _RuntimeText({
    required this.node,
    required this.autopilot,
  });

  final Map<String, dynamic> node;
  final Autopilot autopilot;

  @override
  Widget build(BuildContext context) {
    final bind = node['bind']?.toString();
    final text = bind == null || bind.isEmpty
        ? node['text']?.toString() ?? ''
        : '${node['prefix'] ?? ''}${autopilot.resolve(bind) ?? ''}${node['suffix'] ?? ''}';
    final style = node['style'] == 'headline'
        ? const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
        : null;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(text, style: style),
    );
  }
}
