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

Role in AIBook
- For `AIBook`, these classes are the preferred transport shape for business-bound row data.
- They are intended for machine-oriented transport where correct indexing matters more than human-readable property names.
- The shared list field `v` is the intended compact payload surface for bound business values.
- UX/UI composition data is a different concern and can remain normal JSON.

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
- In binding-oriented runtime flows, `src + fieldId` should preferably resolve to slot/index access into `v`.
- Human-readable dotted paths are acceptable as migration fallback, but they are not the preferred long-term transport contract for dynamic business data.
- This `base X` family is separate from `X*` wrapped Flutter controls under `lib/core/widgets`.
- `Xi` uses a simple `max(i) + 1` allocation strategy.
- The richer variants (`Xia`, `Xiad`, `Xiade`) are intended to use epoch-millisecond-based IDs rather than `max(i) + 1`.
- Planned formula direction for those richer variants is:
  - `epochMs * 10/100/1000 + suffix`
  - where the suffix stays inside `0..999`
- Keep those runtime/business integers within signed 53-bit safe range for Flutter web / JSON transport even if PostgreSQL stores them as `bigint`.
- In practice, `Xiad.d` and `Xiade.d/e` are part of that web-safe `int^53` / PostgreSQL `bigint` rule.
- In business/data-side transport, `Xiade.e` should be treated as the last editor reference and point to `UserModel.i`.
- Prefer a deterministic per-millisecond suffix allocator over uncontrolled random collision risk when implementing the `0..999` part.
