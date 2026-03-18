# lib_core_base_data_type_readme

This document describes `lib/core/base/data_type.dart`.

File
- `lib/core/base/data_type.dart`

Classes
- `DataType` - value object for type metadata fields `i`, `n`, `d`, `p`, `s`, `j`
- `TypeMapper` - static registry and lookup helper for known types

Field meanings
- `i` - type id
- `n` - display name
- `d` - Dart type
- `p` - PostgreSQL type
- `s` - SQLite type
- `j` - JSON type

Built-in ids
- `0` - `bool`
- `1` - `Int32`
- `2` - `Int53`
- `3` - `Int64`
- `4` - `Double`
- `5` - `Binary`
- `6` - `Json`
- `7` - `Jsonb`
- `9` - `Guid`
- `10` - `String`
- `11` - `Base64`

Lookup API
- `DataType.fromJson(Map<String, dynamic>)`
- `DataType.toJson()`
- `TypeMapper.byId(int id)`
- `TypeMapper.byDisplayName(String name)`

Numeric ids above 99
- Any id greater than `99` is treated as a generated numeric type.
- The last two digits are the number of digits to the right of the decimal point.
- The remaining digits to the left are the number of digits to the left of the decimal point.
- Example: `1202` becomes `Numeric(12,2)` and PostgreSQL `numeric(14, 2)`.

Notes
- Dynamic numeric ids map to Dart `String`, PostgreSQL `numeric(precision, scale)`, SQLite `text`, and JSON `string`.