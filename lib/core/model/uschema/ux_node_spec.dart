import 'package:genrp/core/ux/mixins.dart';

abstract class UxNodeSpec with Ux {
  const UxNodeSpec({
    required this.i,
    this.m = const <String, dynamic>{},
  });

  @override
  final int i;

  @override
  bool get a => true;

  @override
  int get d => 0;

  @override
  int get e => 0;

  @override
  final Map<String, dynamic> m;

  int get code;

  @override
  int get t;
}
