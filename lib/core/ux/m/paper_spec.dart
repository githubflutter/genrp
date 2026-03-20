import 'package:genrp/core/ux/m/node_spec.dart';
import 'package:genrp/core/ux/m/template_spec.dart';
import 'package:genrp/core/ux/ux.dart';

class UxPaperSpec extends UxNodeSpec {
  const UxPaperSpec({
    required this.pid,
    required super.i,
    required this.template,
    super.s,
    super.m,
  });

  final int pid;
  final UxTemplateSpec template;

  @override
  String get n => UxRegister.papers[pid] ?? 'paper$pid';

  @override
  int get code => UxRegister.paperCode(pid);

  @override
  String get id => UxRegister.paperId(pid);
}
