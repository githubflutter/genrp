import 'package:genrp/core/ux/ux_register.dart';

mixin V implements Ux {
  // vid -> 1:listview, 2:gridview, 3:datatableview, 4:toolbarview,
  // 5:fromview, 6:plistview, 7:cardview, 8:itemvew, 9:emptyview,
  // 10:chooseview, 11:alertview, 12:collectionview, 13:tabview
  // n -> same as the mapped view name above
  // View is a reusable primitive layer and does not get a shared runtime host
  // by default.
  int get vid;

  @override
  int get s;

  @override
  int get i;

  @override
  String get n;

  @override
  Map<String, dynamic> get m => const <String, dynamic>{};
}
