import 'package:flutter/material.dart';
import 'package:genrp/core/gen/explorer_state.dart';

class UExplorerNode {
  const UExplorerNode({
    required this.label,
    this.children = const <UExplorerNode>[],
  });

  final String label;
  final List<UExplorerNode> children;

  bool get isLeaf => children.isEmpty;
}

class UExplorer extends StatelessWidget {
  const UExplorer({
    required this.state,
    this.onExpandedItemChanged,
    this.onBackToMaster,
    this.onViewTap,
    this.onMasterTap,
    this.onDetailTap,
    super.key,
  });

  static const String modeMaster = 'master';
  static const String modeDetail = 'detail';

  final ExplorerState state;
  final ValueChanged<String?>? onExpandedItemChanged;
  final VoidCallback? onBackToMaster;
  final ValueChanged<UExplorerNode>? onViewTap;
  final ValueChanged<UExplorerNode>? onMasterTap;
  final ValueChanged<UExplorerNode>? onDetailTap;

  static const TextStyle textStyle = TextStyle(fontSize: 12);
  static const Color masterHighlight = Color.fromARGB(255, 0, 120, 212);
  static const Color detailHighlight = Color.fromARGB(255, 0, 120, 212);

  @override
  Widget build(BuildContext context) {
    final headerCount = state.mode == modeDetail && state.focusedMaster != null
        ? state.focusedMaster!.children.length
        : state.nodes.length;
    final headerTitle = state.mode == modeDetail && state.focusedMaster != null
        ? state.focusedMaster!.label
        : state.title;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (headerTitle != null)
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: <Widget>[
                if (state.mode == modeDetail)
                  SizedBox(
                    width: 32,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: 16,
                      onPressed: onBackToMaster,
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ),
                Expanded(
                  child: Text(headerTitle, style: textStyle),
                ),
                const SizedBox(width: 8),
                Text('$headerCount', style: textStyle),
              ],
            ),
          ),
        Expanded(
          child: state.mode == modeDetail && state.focusedMaster != null
              ? ListView(
                  children: state.focusedMaster!.children.map((UExplorerNode node) {
                    return _DetailExplorerTile(
                      node: node,
                      selectedDetailItem: state.selectedDetailItem,
                      onDetailTap: onDetailTap,
                    );
                  }).toList(),
                )
              : ListView(
                  children: state.nodes.map((UExplorerNode node) {
                    return _ExplorerTile(
                      node: node,
                      isMaster: true,
                      selectedMasterItem: state.selectedMasterItem,
                      selectedDetailItem: state.selectedDetailItem,
                      expandedItem: state.expandedItem,
                      onExpandedItemChanged: onExpandedItemChanged,
                      onViewTap: onViewTap,
                      onMasterTap: onMasterTap,
                      onDetailTap: onDetailTap,
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
}

class _DetailExplorerTile extends StatelessWidget {
  const _DetailExplorerTile({
    required this.node,
    required this.selectedDetailItem,
    this.onDetailTap,
  });

  final UExplorerNode node;
  final String? selectedDetailItem;
  final ValueChanged<UExplorerNode>? onDetailTap;

  bool get _isSelectedDetail => selectedDetailItem == node.label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onDetailTap == null ? null : () => onDetailTap!(node),
      child: Container(
        height: 32,
        color: _isSelectedDetail ? UExplorer.detailHighlight : null,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(node.label, style: UExplorer.textStyle),
      ),
    );
  }
}

class _ExplorerTile extends StatelessWidget {
  const _ExplorerTile({
    required this.node,
    required this.isMaster,
    required this.selectedMasterItem,
    required this.selectedDetailItem,
    required this.expandedItem,
    this.onExpandedItemChanged,
    this.onViewTap,
    this.onMasterTap,
    this.onDetailTap,
  });

  final UExplorerNode node;
  final bool isMaster;
  final String? selectedMasterItem;
  final String? selectedDetailItem;
  final String? expandedItem;
  final ValueChanged<String?>? onExpandedItemChanged;
  final ValueChanged<UExplorerNode>? onViewTap;
  final ValueChanged<UExplorerNode>? onMasterTap;
  final ValueChanged<UExplorerNode>? onDetailTap;

  bool get _isSelectedMaster => selectedMasterItem == node.label;
  bool get _isSelectedDetail => selectedDetailItem == node.label;
  bool get _isExpanded => expandedItem == node.label;

  @override
  Widget build(BuildContext context) {
    if (!isMaster && node.isLeaf) {
      return InkWell(
        onTap: onDetailTap == null ? null : () => onDetailTap!(node),
        child: Container(
          height: 32,
          color: _isSelectedDetail ? UExplorer.detailHighlight : null,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(node.label, style: UExplorer.textStyle),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          height: 32,
          color: _isSelectedMaster ? UExplorer.masterHighlight : null,
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 32,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 16,
                  onPressed: onViewTap == null ? null : () => onViewTap!(node),
                  icon: const Icon(Icons.visibility_outlined),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    if (onMasterTap != null) {
                      onMasterTap!(node);
                    }
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(node.label, style: UExplorer.textStyle),
                  ),
                ),
              ),
              SizedBox(
                width: 32,
                child: node.children.isEmpty
                    ? const SizedBox.shrink()
                    : IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 16,
                        onPressed: _toggleExpanded,
                        icon: Icon(
                          _isExpanded ? Icons.expand_more : Icons.chevron_right,
                        ),
                      ),
              ),
            ],
          ),
        ),
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: node.children.map((UExplorerNode child) {
                return _ExplorerTile(
                  node: child,
                  isMaster: false,
                  selectedMasterItem: selectedMasterItem,
                  selectedDetailItem: selectedDetailItem,
                  expandedItem: expandedItem,
                  onExpandedItemChanged: onExpandedItemChanged,
                  onViewTap: onViewTap,
                  onMasterTap: onMasterTap,
                  onDetailTap: onDetailTap,
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  void _toggleExpanded() {
    if (onExpandedItemChanged == null) {
      return;
    }
    onExpandedItemChanged!(_isExpanded ? null : node.label);
  }
}
