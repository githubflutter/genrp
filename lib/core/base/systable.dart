import 'package:genrp/core/db/db_contract.dart';

class SysTableEntry {
  const SysTableEntry({
    required this.entrypoint,
    required this.description,
    required this.spec,
  });

  final String entrypoint;
  final String description;
  final DbTableSpec spec;
}

const sysTableEntrypoints = <SysTableEntry>[
  SysTableEntry(
    entrypoint: 'app_kv',
    description: 'Foundation key/value storage entrypoint.',
    spec: DbTableSpec(
      name: 'app_kv',
      columns: <DbColumnSpec>[
        DbColumnSpec(name: 'k', type: 'text', primaryKey: true),
        DbColumnSpec(name: 'v', type: 'text'),
        DbColumnSpec(name: 'updated_at', type: 'integer'),
      ],
      kind: DbTargetKind.foundation,
    ),
  ),
  SysTableEntry(
    entrypoint: 'catalog_row',
    description: 'Foundation generic catalog row storage entrypoint.',
    spec: DbTableSpec(
      name: 'catalog_row',
      columns: <DbColumnSpec>[
        DbColumnSpec(name: 'catalog', type: 'text'),
        DbColumnSpec(name: 'i', type: 'integer'),
        DbColumnSpec(name: 'a', type: 'integer'),
        DbColumnSpec(name: 'd', type: 'integer'),
        DbColumnSpec(name: 'e', type: 'integer'),
        DbColumnSpec(name: 't', type: 'integer'),
        DbColumnSpec(name: 'n', type: 'text'),
        DbColumnSpec(name: 's', type: 'text'),
        DbColumnSpec(name: 'payload', type: 'text'),
        DbColumnSpec(name: 'updated_at', type: 'integer'),
      ],
      kind: DbTargetKind.foundation,
    ),
  ),
  SysTableEntry(
    entrypoint: 'vfun',
    description: 'SQLite-side function/script storage entrypoint.',
    spec: DbTableSpec(
      name: 'vfun',
      columns: <DbColumnSpec>[
        DbColumnSpec(name: 'i', type: 'integer', primaryKey: true),
        DbColumnSpec(name: 'a', type: 'integer'),
        DbColumnSpec(name: 'd', type: 'integer'),
        DbColumnSpec(name: 'e', type: 'integer'),
        DbColumnSpec(name: 'ei', type: 'integer'),
        DbColumnSpec(name: 't', type: 'integer'),
        DbColumnSpec(name: 'n', type: 'text'),
        DbColumnSpec(name: 's', type: 'text'),
        DbColumnSpec(name: 'tis', type: 'text'),
        DbColumnSpec(name: 'sql1', type: 'text'),
        DbColumnSpec(name: 'sql2', type: 'text'),
        DbColumnSpec(name: 'sql3', type: 'text'),
      ],
      kind: DbTargetKind.foundation,
    ),
  ),
];
