import 'package:genrp/core/ux/ux.dart';

abstract class UxNodeSpec with Ux {
  const UxNodeSpec({
    required this.i,
    this.s = 0,
    this.m = const <String, dynamic>{},
  });

  @override
  final int i;

  @override
  final int s;

  @override
  final Map<String, dynamic> m;

  int get code;

  String get id;
}
