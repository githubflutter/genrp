import 'package:genrp/core/db/db_contract.dart';

class SysFunctionEntry {
  const SysFunctionEntry({
    required this.entrypoint,
    required this.description,
    required this.spec,
  });

  final String entrypoint;
  final String description;
  final DbFunctionSpec spec;
}

const sysFunctionEntrypoints = <SysFunctionEntry>[
  SysFunctionEntry(
    entrypoint: 'edit_foundation_row',
    description: 'Direct foundation-table function entrypoint.',
    spec: DbFunctionSpec(
      name: 'edit_foundation_row',
      schema: 'public',
      returns: 'json',
      body: '-- foundation function body is generated later',
      kind: DbTargetKind.foundation,
    ),
  ),
  SysFunctionEntry(
    entrypoint: 'invoke_business_action',
    description: 'Business-table function/action entrypoint.',
    spec: DbFunctionSpec(
      name: 'invoke_business_action',
      schema: 'public',
      returns: 'json',
      body: '-- business function body is generated later',
      kind: DbTargetKind.business,
    ),
  ),
];
