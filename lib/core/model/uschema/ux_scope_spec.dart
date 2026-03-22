import 'package:genrp/core/model/uschema/ux_node_spec.dart';
import 'package:genrp/core/ux/mixins.dart';

class UxScopeSpec extends UxNodeSpec {
  const UxScopeSpec({
    required this.vid,
    required super.i,
    super.s,
    super.m,
    this.p = '',
  });

  final int vid;
  final String p;

  @override
  String get n => UxRegister.scopes[vid] ?? 'scope$vid';

  @override
  int get code => vid;

  @override
  String get id => '$vid';

  int codeFor({required int pid, required int tid}) =>
      UxRegister.scopeCode(pid: pid, tid: tid, sid: vid);

  String idFor({required int pid, required int tid}) =>
      UxRegister.scopeId(pid: pid, tid: tid, sid: vid);
}
