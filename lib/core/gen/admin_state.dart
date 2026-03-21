import 'package:flutter/foundation.dart';
import 'package:genrp/core/gen/uexplorer.dart';

enum AdminMode { schema, preview, compare }

class AdminState extends ChangeNotifier {
  AdminState({
    this.mode = AdminMode.schema,
    this.master1,
    this.detail1,
    this.master2,
    this.lastItem,
    this.expandedItem,
  });

  AdminMode mode;
  String? master1;
  String? detail1;
  String? master2;
  UExplorerNode? lastItem;
  String? expandedItem;

  void setMode(AdminMode value) {
    if (mode == value) {
      return;
    }
    mode = value;
    notifyListeners();
  }

  void cycleMode() {
    switch (mode) {
      case AdminMode.schema:
        setMode(AdminMode.preview);
      case AdminMode.preview:
        setMode(AdminMode.compare);
      case AdminMode.compare:
        setMode(AdminMode.schema);
    }
  }

  void setMaster1(String value) {
    if (master1 == value) {
      return;
    }
    master1 = value;
    notifyListeners();
  }

  void setDetail1(String value) {
    if (detail1 == value) {
      return;
    }
    detail1 = value;
    notifyListeners();
  }

  void setDetailItem(UExplorerNode item) {
    final sameDetail = detail1 == item.label;
    final sameItem = identical(lastItem, item);
    if (sameDetail && sameItem) {
      return;
    }
    detail1 = item.label;
    lastItem = item;
    notifyListeners();
  }

  void setMaster2(String value) {
    if (master2 == value) {
      return;
    }
    master2 = value;
    notifyListeners();
  }

  void setExpandedItem(String? value) {
    if (expandedItem == value) {
      return;
    }
    expandedItem = value;
    notifyListeners();
  }
}
