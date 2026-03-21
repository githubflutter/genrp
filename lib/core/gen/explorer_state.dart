import 'package:genrp/core/gen/uexplorer.dart';

class ExplorerState {
  ExplorerState({
    this.nodes = const <UExplorerNode>[],
    this.mode = UExplorer.modeMaster,
    this.title,
    this.focusedMaster,
    this.selectedMasterItem,
    this.selectedDetailItem,
    this.expandedItem,
    List<Map<String, dynamic>>? l,
    List<Map<String, dynamic>>? n,
  }) : l = l ?? <Map<String, dynamic>>[],
       n = n ?? <Map<String, dynamic>>[];

  List<UExplorerNode> nodes;
  String mode;
  String? title;
  UExplorerNode? focusedMaster;
  String? selectedMasterItem;
  String? selectedDetailItem;
  String? expandedItem;
  List<Map<String, dynamic>> l;
  List<Map<String, dynamic>> n;

  void setNodes(List<UExplorerNode> value) {
    nodes = value;
  }

  void setMode(String value) {
    mode = value;
  }

  void setTitle(String? value) {
    title = value;
  }

  void setFocusedMaster(UExplorerNode? value) {
    focusedMaster = value;
  }

  void setSelectedMasterItem(String? value) {
    selectedMasterItem = value;
  }

  void setSelectedDetailItem(String? value) {
    selectedDetailItem = value;
  }

  void setExpandedItem(String? value) {
    expandedItem = value;
  }

  void setL(List<Map<String, dynamic>> value) {
    l = value;
  }

  void setN(List<Map<String, dynamic>> value) {
    n = value;
  }
}
