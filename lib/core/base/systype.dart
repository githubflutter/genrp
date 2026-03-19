enum DbTargetKind { foundation, business }

class SysTypeEntry {
  const SysTypeEntry({
    required this.entrypoint,
    required this.description,
    required this.kind,
  });

  final String entrypoint;
  final String description;
  final DbTargetKind kind;
}

const sysTypeEntrypoints = <SysTypeEntry>[
  SysTypeEntry(
    entrypoint: 'foundation',
    description: 'Allows admin create scripts and direct CRUD clients.',
    kind: DbTargetKind.foundation,
  ),
  SysTypeEntry(
    entrypoint: 'business',
    description:
        'Allows admin create scripts, but runtime CRUD must go through function actions.',
    kind: DbTargetKind.business,
  ),
];
