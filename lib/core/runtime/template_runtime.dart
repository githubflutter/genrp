import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/model/uschema/ux_registry.dart';
import 'package:genrp/core/model/uschema/ux_spec_mapper.dart';
import 'package:genrp/core/theme/genrp_theme.dart';
import 'package:genrp/core/widgets/x_button.dart';
import 'package:genrp/core/widgets/x_text_box.dart';

typedef RuntimeNodeBuilder =
    Widget Function(
      Map<String, dynamic> node,
      Autopilot autopilot,
      Widget Function(Map<String, dynamic> childNode) renderChild,
    );

/// Runtime that renders the current small widget set from JSON nodes.
class TemplateRuntime {
  const TemplateRuntime();

  static const UxSpecMapper _mapper = UxSpecMapper();

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

  Widget render(
    Map<String, dynamic> node,
    Autopilot autopilot, {
    UxRegistry? registry,
    int hostId = 0,
    int bodyId = 0,
  }) {
    final typeId = (node['typeId'] as num?)?.toInt();
    final type =
        registry?.typeName(typeId) ?? node['type']?.toString() ?? 'text';
    final builder = _builders[type] ?? _builders['text']!;
    final scopedNode = <String, dynamic>{
      ...node,
      'hostId': (node['hostId'] as num?)?.toInt() ?? hostId,
      'bodyId': (node['bodyId'] as num?)?.toInt() ?? bodyId,
    };
    return builder(
      scopedNode,
      autopilot,
      (childNode) => render(
        childNode,
        autopilot,
        registry: registry,
        hostId: hostId,
        bodyId: bodyId,
      ),
    );
  }
}

class _RuntimeColumn extends StatelessWidget {
  const _RuntimeColumn({required this.node, required this.renderChild});

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
  const _RuntimeTextField({required this.node, required this.autopilot});

  final Map<String, dynamic> node;
  final Autopilot autopilot;

  @override
  Widget build(BuildContext context) {
    return XTextBox(
      model: TemplateRuntime._mapper.textBoxFromNode(
        node,
        hostId: (node['hostId'] as num?)?.toInt() ?? 0,
        bodyId: (node['bodyId'] as num?)?.toInt() ?? 0,
      ),
      autopilot: autopilot,
    );
  }
}

class _RuntimeButton extends StatelessWidget {
  const _RuntimeButton({required this.node, required this.autopilot});

  final Map<String, dynamic> node;
  final Autopilot autopilot;

  @override
  Widget build(BuildContext context) {
    return XButton(
      model: TemplateRuntime._mapper.buttonFromNode(
        node,
        hostId: (node['hostId'] as num?)?.toInt() ?? 0,
        bodyId: (node['bodyId'] as num?)?.toInt() ?? 0,
      ),
      autopilot: autopilot,
    );
  }
}

class _RuntimeText extends StatelessWidget {
  const _RuntimeText({required this.node, required this.autopilot});

  final Map<String, dynamic> node;
  final Autopilot autopilot;

  @override
  Widget build(BuildContext context) {
    final bind = node['bind']?.toString();
    final src = (node['src'] as num?)?.toInt();
    final fieldId =
        (node['fieldId'] as num?)?.toInt() ?? (node['f'] as num?)?.toInt();
    final resolvedValue = autopilot.resolveFieldBinding(
      src: src,
      fieldId: fieldId,
      fallbackPath: bind,
    );
    final text = bind == null || bind.isEmpty
        ? node['text']?.toString() ?? ''
        : '${node['prefix'] ?? ''}${resolvedValue ?? ''}${node['suffix'] ?? ''}';
    final style = node['style'] == 'headline'
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
