import 'package:genrp/core/model/uschema/ux_node_spec.dart';
import 'package:genrp/core/ux/ux_register.dart';

class UxViewSpec extends UxNodeSpec {
  const UxViewSpec({required this.vid, required super.i, super.s, super.m, this.p = ''});

  final int vid;
  final String p;

  @override
  String get n => UxRegister.views[vid] ?? 'view$vid';

  @override
  int get code => vid;

  @override
  String get id => '$vid';

  int codeFor({required int pid, required int tid}) => UxRegister.viewCode(pid: pid, tid: tid, vid: vid);

  String idFor({required int pid, required int tid}) => UxRegister.viewId(pid: pid, tid: tid, vid: vid);
}
