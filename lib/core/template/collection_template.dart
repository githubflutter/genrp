import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/model/uschema/ux_template_spec.dart';
import 'package:genrp/core/runtime/template_runtime.dart';
import 'package:genrp/core/template/action_center_bar.dart';

class CollectionTemplate extends StatelessWidget {
  const CollectionTemplate({
    required this.bodySpec,
    required this.autopilot,
    super.key,
  });

  final UxTemplateSpec bodySpec;
  final Autopilot autopilot;

  @override
  Widget build(BuildContext context) {
    const runtime = TemplateRuntime();
    final standardActionCenters = bodySpec.actionCenters.values
        .where((center) => !_isSelectionCenter(center))
        .toList(growable: false);
    final selectionActionCenters = bodySpec.actionCenters.values
        .where(_isSelectionCenter)
        .toList(growable: false);
    final supportedModes = bodySpec.modeIds;
    final activeMode =
        (autopilot.resolve('ux.${bodySpec.modeStateKey}') as num?)?.toInt() ??
        (supportedModes.isEmpty ? null : supportedModes.first);
    final selectedIndex = autopilot.selectedIndexFor(
      hostId: bodySpec.hostId,
      bodyId: bodySpec.bodyId,
    );
    final selectedIndexes = bodySpec.isMultiSelection
        ? autopilot.selectedIndexesFor(
            hostId: bodySpec.hostId,
            bodyId: bodySpec.bodyId,
          )
        : (selectedIndex == null ? const <int>[] : <int>[selectedIndex]);
    final items = List<Object?>.from(
      bodySpec.props['items'] as List? ?? const [],
    );
    final selectedItems = selectedIndexes
        .where((index) => index >= 0 && index < items.length)
        .map((index) => items[index])
        .toList(growable: false);
    final hasSelectedItem = selectedItems.isNotEmpty;
    final selectionPayload = !hasSelectedItem
        ? null
        : _selectionPayload(selectedIndexes, selectedItems);

    void selectItem(int index) {
      if (bodySpec.isMultiSelection) {
        autopilot.toggleSelectedIndex(
          hostId: bodySpec.hostId,
          bodyId: bodySpec.bodyId,
          index: index,
        );
        return;
      }
      autopilot.selectIndex(
        hostId: bodySpec.hostId,
        bodyId: bodySpec.bodyId,
        index: index,
      );
    }

    Widget buildContent() {
      if (supportedModes.isEmpty || items.isEmpty || activeMode == null) {
        return runtime.render(bodySpec.root, autopilot);
      }
      if (!bodySpec.supportsMode(activeMode)) {
        return _CollectionErrorPanel(
          message:
              'Collection mode $activeMode is not supported by body ${bodySpec.bodyId}.',
        );
      }
      return switch (activeMode) {
        UxTemplateMode.list => _CollectionListView(
          bodySpec: bodySpec,
          items: items,
          selectedIndexes: selectedIndexes.toSet(),
          onSelect: selectItem,
        ),
        UxTemplateMode.grid => _CollectionGridView(
          bodySpec: bodySpec,
          items: items,
          selectedIndexes: selectedIndexes.toSet(),
          onSelect: selectItem,
        ),
        UxTemplateMode.table => _CollectionTableView(
          bodySpec: bodySpec,
          items: items,
          selectedIndexes: selectedIndexes.toSet(),
          onSelect: selectItem,
        ),
        _ => _CollectionErrorPanel(
          message: 'Collection mode $activeMode is not implemented.',
        ),
      };
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (bodySpec.title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                bodySpec.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ActionCenterBar(
            actionCenters: standardActionCenters,
            autopilot: autopilot,
          ),
          if (supportedModes.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: supportedModes
                  .map(
                    (modeId) => ChoiceChip(
                      key: ValueKey('collection_mode_$modeId'),
                      label: Text(UxTemplateMode.labelOf(modeId)),
                      selected: modeId == activeMode,
                      onSelected: (_) {
                        autopilot.copilotUX.setValue(
                          bodySpec.modeStateKey,
                          modeId,
                        );
                      },
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(height: 12),
          ],
          if (hasSelectedItem) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _selectionSummary(selectedItems),
                key: const ValueKey('collection_selected_label'),
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            ActionCenterBar(
              actionCenters: selectionActionCenters,
              autopilot: autopilot,
              payload: selectionPayload,
              keyPrefix: 'selection-action-center',
            ),
          ],
          buildContent(),
        ],
      ),
    );
  }
}

class _CollectionListView extends StatelessWidget {
  const _CollectionListView({
    required this.bodySpec,
    required this.items,
    required this.selectedIndexes,
    required this.onSelect,
  });

  final UxTemplateSpec bodySpec;
  final List<Object?> items;
  final Set<int> selectedIndexes;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('collection_view_list'),
      children: List<Widget>.generate(items.length, (index) {
        final item = items[index];
        final isSelected = selectedIndexes.contains(index);
        return Card(
          child: ListTile(
            key: ValueKey(
              'collection_item_${bodySpec.bodyId}_${UxTemplateMode.list}_$index',
            ),
            selected: isSelected,
            title: Text(_itemLabel(item)),
            onTap: () => onSelect(index),
          ),
        );
      }),
    );
  }
}

class _CollectionGridView extends StatelessWidget {
  const _CollectionGridView({
    required this.bodySpec,
    required this.items,
    required this.selectedIndexes,
    required this.onSelect,
  });

  final UxTemplateSpec bodySpec;
  final List<Object?> items;
  final Set<int> selectedIndexes;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      key: const ValueKey('collection_view_grid'),
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 3,
      children: List<Widget>.generate(items.length, (index) {
        final item = items[index];
        final isSelected = selectedIndexes.contains(index);
        return Card(
          shape: RoundedRectangleBorder(
            side: isSelected
                ? BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : BorderSide.none,
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            key: ValueKey(
              'collection_item_${bodySpec.bodyId}_${UxTemplateMode.grid}_$index',
            ),
            borderRadius: BorderRadius.circular(12),
            onTap: () => onSelect(index),
            child: Center(child: Text(_itemLabel(item))),
          ),
        );
      }),
    );
  }
}

class _CollectionTableView extends StatelessWidget {
  const _CollectionTableView({
    required this.bodySpec,
    required this.items,
    required this.selectedIndexes,
    required this.onSelect,
  });

  final UxTemplateSpec bodySpec;
  final List<Object?> items;
  final Set<int> selectedIndexes;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return DataTable(
      key: const ValueKey('collection_view_table'),
      columns: const [DataColumn(label: Text('Value'))],
      rows: List<DataRow>.generate(items.length, (index) {
        final item = items[index];
        return DataRow.byIndex(
          index: index,
          selected: selectedIndexes.contains(index),
          onSelectChanged: (_) => onSelect(index),
          cells: [
            DataCell(
              Text(
                _itemLabel(item),
                key: ValueKey(
                  'collection_item_${bodySpec.bodyId}_${UxTemplateMode.table}_$index',
                ),
              ),
              onTap: () => onSelect(index),
            ),
          ],
        );
      }),
    );
  }
}

class _CollectionErrorPanel extends StatelessWidget {
  const _CollectionErrorPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      key: const ValueKey('collection_error_panel'),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.error,
      ),
    );
  }
}

String _itemLabel(Object? item) {
  if (item is Map && item['label'] != null) {
    return item['label'].toString();
  }
  return item?.toString() ?? '';
}

bool _isSelectionCenter(UxActionCenterSpec center) {
  return center.props['selection'] == true || center.id == 'selection';
}

Map<String, dynamic> _selectionPayload(List<int> indexes, List<Object?> items) {
  final labels = items.map(_itemLabel).toList(growable: false);
  final payload = <String, dynamic>{
    'indices': indexes,
    'items': items,
    'labels': labels,
    'count': indexes.length,
  };
  if (indexes.length == 1 && items.length == 1) {
    final item = items.first;
    payload['index'] = indexes.first;
    payload['item'] = item;
    payload['label'] = labels.first;
    if (item is Map) {
      for (final entry in item.entries) {
        payload[entry.key.toString()] = entry.value;
      }
    }
  }
  return payload;
}

String _selectionSummary(List<Object?> items) {
  if (items.length == 1) {
    return 'Selected: ${_itemLabel(items.first)}';
  }
  return 'Selected: ${items.length} items';
}
