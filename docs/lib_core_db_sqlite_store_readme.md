# lib_core_db_sqlite_store_readme

This document describes `lib/core/db/sqlite_store.dart`.

File
- `lib/core/db/sqlite_store.dart`

Purpose
- Provides the current local SQLite foundation for the repo.
- Keeps the first persistence shape generic and low-overhead.
- Supports local catalog-row persistence for `AIStudio` style editing work.
- Can also support local cache/key-value storage for `AIBook`.

Directory direction
- Under `lib/core/db`, the intended structure is moving toward app-specific directories:
  - `lib/core/db/aibook/`
  - `lib/core/db/aicodex/`
  - `lib/core/db/aistudio/`
- Shared low-level database foundation can stay shared, but app-facing database code should live under the matching app directory.
- `lib/core/db/sqlite_store.dart` is currently the shared SQLite foundation and should be treated as shared infrastructure until the db layout is split further.

Current schema
- `app_kv`
  - simple key/value JSON storage
- `catalog_row`
  - generic row storage for catalog-based editing
  - primary key is `(catalog, i)`

Main types
- `SqliteCatalogRow`
  - generic persisted row shape
  - fields:
    - `catalog`
    - `i`
    - `a`
    - `d`
    - `e`
    - `t`
    - `n`
    - `s`
    - `payload`
    - `updatedAt`
- `SqliteStore`
  - opens the database
  - creates schema
  - lists rows by catalog
  - gets one row
  - upserts one row
  - deletes one row
  - stores and reads JSON values from `app_kv`

Platform direction
- Uses `sqflite` for Flutter/mobile-compatible database access.
- Uses `sqflite_common_ffi` for desktop-compatible database access.
- Web is not configured for this SQLite path.

Current intended usage
- `AIStudio`
  - local persistence for data model rows and UX/spec rows
- `AIBook`
  - local cache for spec data or base `X` business data when needed
- Future app-specific db code should sit under the matching app db directory rather than accumulating in the db root.

Current quality status
- Covered by `test/sqlite_store_test.dart`
- `flutter analyze` passes
- `flutter test` passes
