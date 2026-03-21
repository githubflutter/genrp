import 'package:flutter/material.dart';
import 'package:genrp/core/ux/uwidget/uwfield.dart';

class UwFieldChips extends StatelessWidget {
  const UwFieldChips({
    required this.spec,
    required this.callbacks,
    required this.isDeleteMode,
    super.key,
  });

  final UwFieldSpec spec;
  final UwFieldCallbacks callbacks;
  final bool isDeleteMode;

  @override
  Widget build(BuildContext context) {
    final tags = spec.tags ?? <dynamic>[];

    return InputDecorator(
      decoration: InputDecoration(
        labelText: spec.label,
        contentPadding: const EdgeInsets.all(8),
      ),
      child: spec.showChips
          ? Wrap(
              spacing: 8,
              runSpacing: 4,
              children: List.generate(tags.length, (int index) {
                final tag = tags[index];
                final label = spec.itemLabelBuilder?.call(tag) ?? tag.toString();
                return InputChip(
                  label: Text(label),
                  onDeleted: isDeleteMode ? () => callbacks.onTagRemoved?.call(index) : null,
                  deleteIcon: isDeleteMode ? const Icon(Icons.close, size: 16) : null,
                  onPressed: isDeleteMode ? null : () {},
                );
              }),
            )
          : Text(tags.map((dynamic t) => spec.itemLabelBuilder?.call(t) ?? t.toString()).join(spec.tagDelimiter)),
    );
  }
}
