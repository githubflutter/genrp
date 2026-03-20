import 'package:genrp/core/model/uschema/ux_node_spec.dart';
import 'package:genrp/core/model/uschema/uxm_template_spec.dart';
import 'package:genrp/core/ux/ux_register.dart';

class UxPaperSpec extends UxNodeSpec {
  const UxPaperSpec({required this.pid, required super.i, required this.template, super.s, super.m});

  final int pid;
  final UxTemplateSpec template;

  @override
  String get n => UxRegister.papers[pid] ?? 'paper$pid';

  @override
  int get code => UxRegister.paperCode(pid);

  @override
  String get id => UxRegister.paperId(pid);
}
