import 'package:flutter/material.dart';
import 'package:genrp/core/theme/genrp_theme.dart';

enum HybridShellLayoutMode { single, dual, split }

class HybridShellTab {
  const HybridShellTab({required this.label, required this.child});

  final String label;
  final Widget child;
}

class HybridShellMajorTab {
  const HybridShellMajorTab({required this.label, required this.layoutMode});

  final String label;
  final HybridShellLayoutMode layoutMode;
}

class HybridAuthoringShell extends StatefulWidget {
  const HybridAuthoringShell({
    super.key,
    required this.minorTabs,
    required this.majorTabs,
    required this.buildMidPanel,
    required this.buildRightPanel,
    this.initialMinorTabIndex = 0,
    this.initialMajorTabIndex = 0,
    this.onMinorTabChanged,
    this.onMajorTabChanged,
    this.minorFlex = 1,
    this.majorFlex = 4,
  }) : assert(minorTabs.length == 2, 'Hybrid shell requires 2 minor tabs.'),
       assert(majorTabs.length == 3, 'Hybrid shell requires 3 major tabs.');

  final List<HybridShellTab> minorTabs;
  final List<HybridShellMajorTab> majorTabs;
  final Widget Function(BuildContext context, HybridShellLayoutMode mode)
  buildMidPanel;
  final Widget Function(BuildContext context, HybridShellLayoutMode mode)
  buildRightPanel;
  final int initialMinorTabIndex;
  final int initialMajorTabIndex;
  final ValueChanged<int>? onMinorTabChanged;
  final ValueChanged<int>? onMajorTabChanged;
  final int minorFlex;
  final int majorFlex;

  @override
  State<HybridAuthoringShell> createState() => _HybridAuthoringShellState();
}

class _HybridAuthoringShellState extends State<HybridAuthoringShell>
    with TickerProviderStateMixin {
  late final TabController _minorController;
  late final TabController _majorController;

  @override
  void initState() {
    super.initState();
    _minorController = TabController(
      length: widget.minorTabs.length,
      vsync: this,
      initialIndex: widget.initialMinorTabIndex,
    )..addListener(_handleMinorTabChange);
    _majorController = TabController(
      length: widget.majorTabs.length,
      vsync: this,
      initialIndex: widget.initialMajorTabIndex,
    )..addListener(_handleMajorTabChange);
  }

  @override
  void dispose() {
    _minorController
      ..removeListener(_handleMinorTabChange)
      ..dispose();
    _majorController
      ..removeListener(_handleMajorTabChange)
      ..dispose();
    super.dispose();
  }

  void _handleMinorTabChange() {
    if (_minorController.indexIsChanging) return;
    widget.onMinorTabChanged?.call(_minorController.index);
  }

  void _handleMajorTabChange() {
    if (_majorController.indexIsChanging) return;
    widget.onMajorTabChanged?.call(_majorController.index);
  }

  Widget _buildMajorLayout(HybridShellLayoutMode mode) {
    final midPanel = widget.buildMidPanel(context, mode);
    if (mode == HybridShellLayoutMode.single) {
      return midPanel;
    }

    final rightPanel = widget.buildRightPanel(context, mode);
    final midFlex = mode == HybridShellLayoutMode.dual ? 3 : 1;
    final rightFlex = mode == HybridShellLayoutMode.dual ? 1 : 1;

    return Row(
      children: [
        Expanded(flex: midFlex, child: midPanel),
        const VerticalDivider(width: 1, thickness: 1),
        Expanded(flex: rightFlex, child: rightPanel),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final toolbarHeight = GenrpTheme.toolbarHeightOf(context);
    final tabLabelColor = Theme.of(context).colorScheme.onSurface;
    final tabUnselectedColor = tabLabelColor.withValues(alpha: 0.64);
    final tabIndicatorColor = Theme.of(context).colorScheme.secondary;
    final sidePanelColor = GenrpTheme.panelColorOf(context);

    return Row(
      children: [
        Expanded(
          flex: widget.minorFlex,
          child: Container(
            color: sidePanelColor,
            child: Column(
              children: [
                SizedBox(
                  height: toolbarHeight,
                  child: TabBar(
                    controller: _minorController,
                    labelColor: tabLabelColor,
                    unselectedLabelColor: tabUnselectedColor,
                    indicatorColor: tabIndicatorColor,
                    tabs: widget.minorTabs
                        .map(
                          (tab) => Tab(height: toolbarHeight, text: tab.label),
                        )
                        .toList(growable: false),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _minorController,
                    children: widget.minorTabs
                        .map((tab) => tab.child)
                        .toList(growable: false),
                  ),
                ),
              ],
            ),
          ),
        ),
        const VerticalDivider(width: 1, thickness: 1),
        Expanded(
          flex: widget.majorFlex,
          child: Column(
            children: [
              Material(
                color: sidePanelColor,
                child: SizedBox(
                  height: toolbarHeight,
                  child: TabBar(
                    controller: _majorController,
                    labelColor: tabLabelColor,
                    unselectedLabelColor: tabUnselectedColor,
                    indicatorColor: tabIndicatorColor,
                    tabs: widget.majorTabs
                        .map(
                          (tab) => Tab(height: toolbarHeight, text: tab.label),
                        )
                        .toList(growable: false),
                  ),
                ),
              ),
              Expanded(
                child: AnimatedBuilder(
                  animation: _majorController.animation ?? _majorController,
                  builder: (context, _) {
                    final currentTab = widget.majorTabs[_majorController.index];
                    return _buildMajorLayout(currentTab.layoutMode);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
