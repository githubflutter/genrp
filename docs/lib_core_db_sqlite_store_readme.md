# lib_core_db_sqlite_store_readme

This document describes `lib/core/db/sqlite_store.dart`.

File
- `lib/core/db/sqlite_store.dart`

Purpose
- Provides the current local SQLite foundation for the repo.
- Keeps the first persistence shape generic and low-overhead.
- Supports local catalog-row persistence for `AIStudio` style editing work.
- Can also support local cache/key-value storage for `AIBook`.
- Sits beside the new shared DB builder layer rather than replacing it.

Directory direction
- Under `lib/core/db`, the intended structure is moving toward app-specific directories:
  - `lib/core/db/aibook/`
  - `lib/core/db/aicodex/`
  - `lib/core/db/aistudio/`
- Shared low-level database foundation can stay shared, but app-facing database code should live under the matching app directory.
- `lib/core/db/sqlite_store.dart` is currently the shared SQLite foundation and should be treated as shared infrastructure until the db layout is split further.

Related shared DB files
- `lib/core/db/db_contract.dart` — generic specs for database, table, function, and CRUD definitions
- `lib/core/db/sqliteadmin.dart` — SQLite admin SQL/script generation
- `lib/core/db/sqliteclient.dart` — SQLite foundation CRUD generation
- `lib/core/db/pgsqladmin.dart` / `lib/core/db/pgsqlclient.dart` — PostgreSQL-side admin/client generation
- `lib/core/db/webclient.dart` — generic web request/action payload builder
- `lib/core/base/systable.dart`, `lib/core/base/sysfunc.dart`, `lib/core/base/systype.dart` — entrypoint seeds for shared table/function/type routing

Current schema
- `app_kv`
  - simple key/value JSON storage
- `catalog_row`
  - generic row storage for catalog-based editing
  - primary key is `(catalog, i)`
- `virtualfun` (planned/admin-generated)
  - SQLite-side substitute for database functions in this architecture
  - stored as a shared table spec today, but not yet provisioned by `SqliteStore`
  - stores scripts/payloads to run when function-like behavior is needed locally

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

Planned divergence from PostgreSQL
- SQLite is local foundation/cache infrastructure, not a mirror of PostgreSQL function support.
- PostgreSQL can use real foundation and business functions.
- SQLite should represent that function layer through a `virtualfun` table/model rather than direct database functions.
- Direct CRUD is acceptable for foundation tables.
- Business data should stay function/script-driven rather than relying on generic direct table CRUD.
- The shared create-table builders currently emit `NOT NULL` for every generated column.

Current intended usage
- `AIStudio`
  - local persistence for foundation/model rows and UX/spec rows
- `AIBook`
  - local cache for spec data or base `X` business data when needed
  - may later cache `virtualfun` records/scripts when function-like behavior needs local representation
- `AICodex`
  - reads local foundation rows and may later generate/store SQLite-side `virtualfun` scripts
- `catalog_row` is a shared starting point, not the final direct-access pattern for business tables
- Future app-specific db code should sit under the matching app db directory rather than accumulating in the db root.

Current quality status
- Covered by `test/sqlite_store_test.dart`
- `flutter analyze` passes
- `flutter test` passes
