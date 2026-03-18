# lib_core_base_x_readme

This document describes `lib/core/base/x.dart`.

File
- `lib/core/base/x.dart`

Classes
- `X` - base class with `List<dynamic> v`
- `Xi` - extends `X`, adds `int i`
- `Xia` - extends `X`, adds `int i` and `bool a`
- `Xiad` - extends `X`, adds `int i`, `bool a`, and `int d`
- `Xiade` - extends `X`, adds `int i`, `bool a`, `int d`, and `int e`

JSON API
- `X.fromJson(Map<String, dynamic>)`
- `Xi.fromJson(Map<String, dynamic>)`
- `Xia.fromJson(Map<String, dynamic>)`
- `Xiad.fromJson(Map<String, dynamic>)`
- `Xiade.fromJson(Map<String, dynamic>)`
- `toJson()` implemented on all classes

Notes
- All variants depend directly on `X`.
- The shared payload field is `v`.