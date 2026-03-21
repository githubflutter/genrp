import 'package:flutter/material.dart';
import 'package:genrp/core/gen/admin_state.dart';
import 'package:genrp/core/gen/explorer_state.dart';
import 'package:genrp/core/gen/uexplorer.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({
    required this.title,
    required this.statusText,
    this.nodes = _defaultNodes,
    this.state,
    super.key,
  });

  final String title;
  final String statusText;
  final List<UExplorerNode> nodes;
  final AdminState? state;

  static const TextStyle textStyle = TextStyle(fontSize: 12);
  static const double leftPanelWidth = 200;
  static const double rightPanelWidth = 200;
  static const double statusBarHeight = 32;
  static const List<UExplorerNode> _defaultNodes = <UExplorerNode>[
    UExplorerNode(
      label: 'Business',
      children: <UExplorerNode>[
        UExplorerNode(label: 'Entity'),
        UExplorerNode(label: 'Field'),
      ],
    ),
    UExplorerNode(
      label: 'Database',
      children: <UExplorerNode>[
        UExplorerNode(label: 'Table'),
        UExplorerNode(label: 'Column'),
        UExplorerNode(label: 'Function'),
      ],
    ),
  ];

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  late final AdminState _state;

  @override
  void initState() {
    super.initState();
    _state = widget.state ?? AdminState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title, style: AdminHome.textStyle)),
      body: Row(
        children: <Widget>[
          SizedBox(
            width: AdminHome.leftPanelWidth,
            child: _AdminMasterPanel(
              state: _state,
              nodes: widget.nodes,
            ),
          ),
          Expanded(
            child: _AdminDetailPanel(state: _state),
          ),
        ],
      ),
      bottomNavigationBar: _AdminStatusBar(
        state: _state,
        statusText: widget.statusText,
      ),
    );
  }
}

class _AdminMasterPanel extends StatelessWidget {
  const _AdminMasterPanel({
    required this.state,
    required this.nodes,
  });

  final AdminState state;
  final List<UExplorerNode> nodes;

  @override
  Widget build(BuildContext context) {
    final dividerColor = Theme.of(context).dividerColor;
    return Container(
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: dividerColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: _AdminExplorerPanel(
              state: state,
              nodes: nodes,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminModeSelector extends StatefulWidget {
  const _AdminModeSelector({required this.state});

  final AdminState state;

  @override
  State<_AdminModeSelector> createState() => _AdminModeSelectorState();
}

class _AdminModeSelectorState extends State<_AdminModeSelector> {
  late final VoidCallback _listener;

  @override
  void initState() {
    super.initState();
    _listener = () {
      if (mounted) {
        setState(() {});
      }
    };
    widget.state.addListener(_listener);
  }

  @override
  void dispose() {
    widget.state.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: Align(
        alignment: Alignment.centerLeft,
        child: IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          iconSize: 16,
          tooltip: _labelFor(widget.state.mode),
          onPressed: widget.state.cycleMode,
          icon: Icon(_iconFor(widget.state.mode)),
        ),
      ),
    );
  }

  IconData _iconFor(AdminMode mode) {
    switch (mode) {
      case AdminMode.schema:
        return Icons.crop_16_9_outlined;
      case AdminMode.preview:
        return Icons.view_sidebar_outlined;
      case AdminMode.compare:
        return Icons.view_week_outlined;
    }
  }

  String _labelFor(AdminMode mode) {
    switch (mode) {
      case AdminMode.schema:
        return 'Schema';
      case AdminMode.preview:
        return 'Preview';
      case AdminMode.compare:
        return 'Compare';
    }
  }
}

class _AdminExplorerPanel extends StatefulWidget {
  const _AdminExplorerPanel({
    required this.state,
    required this.nodes,
  });

  final AdminState state;
  final List<UExplorerNode> nodes;

  @override
  State<_AdminExplorerPanel> createState() => _AdminExplorerPanelState();
}

class _AdminExplorerPanelState extends State<_AdminExplorerPanel> {
  late final VoidCallback _listener;
  late final ExplorerState _explorerState;
  String? _master1;
  String? _detail1;
  String? _expandedItem;

  @override
  void initState() {
    super.initState();
    _explorerState = ExplorerState(
      nodes: widget.nodes,
      title: 'Explorer',
      selectedMasterItem: widget.state.master1,
      selectedDetailItem: widget.state.detail1,
      expandedItem: widget.state.expandedItem,
    );
    _master1 = widget.state.master1;
    _detail1 = widget.state.detail1;
    _expandedItem = widget.state.expandedItem;
    _listener = () {
      final nextMaster1 = widget.state.master1;
      final nextDetail1 = widget.state.detail1;
      final nextExpandedItem = widget.state.expandedItem;
      if (_master1 != nextMaster1 ||
          _detail1 != nextDetail1 ||
          _expandedItem != nextExpandedItem) {
        _master1 = nextMaster1;
        _detail1 = nextDetail1;
        _expandedItem = nextExpandedItem;
        _explorerState.setSelectedMasterItem(nextMaster1);
        _explorerState.setSelectedDetailItem(nextDetail1);
        _explorerState.setExpandedItem(nextExpandedItem);
        if (mounted) {
          setState(() {});
        }
      }
    };
    widget.state.addListener(_listener);
  }

  @override
  void dispose() {
    widget.state.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UExplorer(
      state: _explorerState,
      onExpandedItemChanged: widget.state.setExpandedItem,
      onBackToMaster: () {
        _explorerState.setMode(UExplorer.modeMaster);
        _explorerState.setFocusedMaster(null);
        setState(() {});
      },
      onViewTap: (UExplorerNode node) {
        _explorerState.setMode(UExplorer.modeDetail);
        _explorerState.setFocusedMaster(node);
        widget.state.setMaster2(node.label);
        widget.state.setMode(AdminMode.preview);
        setState(() {});
      },
      onMasterTap: (UExplorerNode node) {
        widget.state.setMaster1(node.label);
      },
      onDetailTap: (UExplorerNode node) {
        widget.state.setDetailItem(node);
      },
    );
  }
}

class _AdminDetailPanel extends StatefulWidget {
  const _AdminDetailPanel({required this.state});

  final AdminState state;

  @override
  State<_AdminDetailPanel> createState() => _AdminDetailPanelState();
}

class _AdminDetailPanelState extends State<_AdminDetailPanel> {
  late final VoidCallback _listener;

  String get _masterTitle {
    final value = widget.state.master1;
    if (value == null || value.trim().isEmpty) {
      return 'please select item';
    }
    return value;
  }

  @override
  void initState() {
    super.initState();
    _listener = () {
      if (mounted) {
        setState(() {});
      }
    };
    widget.state.addListener(_listener);
  }

  @override
  void dispose() {
    widget.state.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dividerColor = Theme.of(context).dividerColor;
    return _buildDetailContent(dividerColor);
  }

  Widget _buildDetailContent(Color dividerColor) {
    switch (widget.state.mode) {
      case AdminMode.schema:
        return _detailMainPanel(dividerColor);
      case AdminMode.preview:
        return Row(
          children: <Widget>[
            Expanded(child: _detailMainPanel(dividerColor)),
            SizedBox(
              width: AdminHome.rightPanelWidth,
              child: _detailSidePanel(),
            ),
          ],
        );
      case AdminMode.compare:
        return Row(
          children: <Widget>[
            Expanded(child: _detailMainPanel(dividerColor)),
            Expanded(child: _compareRightPanel()),
          ],
        );
    }
  }

  Widget _detailMainPanel(Color dividerColor) {
    return Container(
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: dividerColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: 32,
            child: Row(
              children: <Widget>[
                _AdminModeSelector(state: widget.state),
                Expanded(
                  child: Text(
                    _masterTitle,
                    style: AdminHome.textStyle,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _AdminModelTable(modelName: widget.state.master1),
          ),
        ],
      ),
    );
  }

  Widget _detailSidePanel() {
    return _lastItemPanel();
  }

  Widget _compareRightPanel() {
    return _lastItemPanel();
  }

  Widget _lastItemPanel() {
    return Container(
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.all(8),
      child: Text(
        widget.state.lastItem?.label ?? '',
        style: AdminHome.textStyle,
      ),
    );
  }
}

class _AdminModelTable extends StatelessWidget {
  const _AdminModelTable({required this.modelName});

  final String? modelName;

  @override
  Widget build(BuildContext context) {
    final columns = _columnsFor(modelName);
    final rows = _rowsFor(modelName);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: DataTable(
        headingRowHeight: 32,
        dataRowMinHeight: 32,
        dataRowMaxHeight: 32,
        columns: columns
            .map((String column) => DataColumn(label: Text(column, style: AdminHome.textStyle)))
            .toList(),
        rows: rows
            .map(
              (Map<String, String> row) => DataRow(
                cells: columns
                    .map((String column) => DataCell(Text(row[column] ?? '', style: AdminHome.textStyle)))
                    .toList(),
              ),
            )
            .toList(),
      ),
    );
  }

  List<String> _columnsFor(String? name) {
    switch (name) {
      case 'Entity':
        return const <String>['i', 'a', 'd', 'e', 't', 'tis', 'n', 's'];
      case 'Field':
        return const <String>['i', 'a', 'd', 'e', 'ci', 't', 'n', 's'];
      case 'Table':
        return const <String>['i', 'a', 'd', 'e', 't', 'n', 's'];
      case 'Column':
        return const <String>['i', 'a', 'd', 'e', 't', 'n', 's'];
      case 'Function':
        return const <String>['i', 'a', 'd', 'e', 'ei', 't', 'tis', 'n', 's'];
      case 'Parameter':
        return const <String>['i', 'a', 'd', 'e', 'fi', 'n', 's'];
      default:
        return const <String>['i', 'a', 'd', 'e', 'n', 's'];
    }
  }

  List<Map<String, String>> _rowsFor(String? name) {
    if (name == null || name.trim().isEmpty) {
      return const <Map<String, String>>[];
    }
    switch (name) {
      case 'Entity':
        return const <Map<String, String>>[
          <String, String>{'i': '1', 'a': '1', 'd': '1742550000000', 'e': '1', 't': '10', 'tis': '[1,2]', 'n': 'Customer', 's': 'customer'},
          <String, String>{'i': '2', 'a': '1', 'd': '1742550001000', 'e': '1', 't': '11', 'tis': '[3]', 'n': 'Order', 's': 'order'},
        ];
      case 'Field':
        return const <Map<String, String>>[
          <String, String>{'i': '1', 'a': '1', 'd': '1742550000000', 'e': '1', 'ci': '1', 't': '2', 'n': 'Name', 's': 'name'},
          <String, String>{'i': '2', 'a': '1', 'd': '1742550001000', 'e': '1', 'ci': '2', 't': '3', 'n': 'Active', 's': 'active'},
        ];
      case 'Table':
        return const <Map<String, String>>[
          <String, String>{'i': '1', 'a': '1', 'd': '1742550000000', 'e': '1', 't': '1', 'n': 't1', 's': 't1'},
          <String, String>{'i': '2', 'a': '1', 'd': '1742550001000', 'e': '1', 't': '1', 'n': 't2', 's': 't2'},
        ];
      case 'Column':
        return const <Map<String, String>>[
          <String, String>{'i': '1', 'a': '1', 'd': '1742550000000', 'e': '1', 't': '1', 'n': 'c1', 's': 'c1'},
          <String, String>{'i': '2', 'a': '1', 'd': '1742550001000', 'e': '1', 't': '2', 'n': 'c2', 's': 'c2'},
        ];
      case 'Function':
        return const <Map<String, String>>[
          <String, String>{'i': '1', 'a': '1', 'd': '1742550000000', 'e': '1', 'ei': '1', 't': '4', 'tis': '[1]', 'n': 'get_customer', 's': 'get_customer'},
          <String, String>{'i': '2', 'a': '1', 'd': '1742550001000', 'e': '1', 'ei': '2', 't': '5', 'tis': '[2]', 'n': 'set_customer', 's': 'set_customer'},
        ];
      case 'Parameter':
        return const <Map<String, String>>[
          <String, String>{'i': '1', 'a': '1', 'd': '1742550000000', 'e': '1', 'fi': '1', 'n': 'customer_id', 's': 'customer_id'},
          <String, String>{'i': '2', 'a': '1', 'd': '1742550001000', 'e': '1', 'fi': '2', 'n': 'payload', 's': 'payload'},
        ];
      default:
        return <Map<String, String>>[
          <String, String>{'i': '1', 'a': '1', 'd': '1742550000000', 'e': '1', 'n': name, 's': name.toLowerCase()},
        ];
    }
  }
}

class _AdminStatusBar extends StatefulWidget {
  const _AdminStatusBar({
    required this.state,
    required this.statusText,
  });

  final AdminState state;
  final String statusText;

  @override
  State<_AdminStatusBar> createState() => _AdminStatusBarState();
}

class _AdminStatusBarState extends State<_AdminStatusBar> {
  late final VoidCallback _listener;

  @override
  void initState() {
    super.initState();
    _listener = () {
      if (mounted) {
        setState(() {});
      }
    };
    widget.state.addListener(_listener);
  }

  @override
  void dispose() {
    widget.state.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AdminHome.statusBarHeight,
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.centerLeft,
      child: Row(
        children: <Widget>[
          Text(_statusLabel(widget.state.mode), style: AdminHome.textStyle),
          const Spacer(),
          Text(widget.statusText, style: AdminHome.textStyle),
        ],
      ),
    );
  }

  String _statusLabel(AdminMode mode) {
    switch (mode) {
      case AdminMode.schema:
        return 'Status: Schema';
      case AdminMode.preview:
        return 'Status: Preview';
      case AdminMode.compare:
        return 'Status: Compare';
    }
  }
}
