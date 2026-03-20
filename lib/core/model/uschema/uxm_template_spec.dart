import 'package:genrp/core/model/uschema/ux_field_spec.dart';
import 'package:genrp/core/model/uschema/ux_node_spec.dart';
import 'package:genrp/core/model/uschema/ux_view_spec.dart';
import 'package:genrp/core/ux/ux_register.dart';

abstract class UxTemplateSpec extends UxNodeSpec {
  const UxTemplateSpec({required this.tid, required super.i, super.s, super.m});

  final int tid;

  @override
  String get n => UxRegister.templates[tid] ?? 'template$tid';

  @override
  int get code => UxRegister.templateCode(pid: 0, tid: tid);

  @override
  String get id => '$tid';

  int codeForPaper(int pid) => UxRegister.templateCode(pid: pid, tid: tid);

  String idForPaper(int pid) => UxRegister.templateId(pid: pid, tid: tid);
}

class UxCrudTemplateSpec extends UxTemplateSpec {
  const UxCrudTemplateSpec({
    required super.i,
    super.s,
    super.m,
    this.collectionTitle = 'Collection',
    this.collectionColumns = const <String>[],
    this.collectionRows = const <List<Object?>>[],
    this.collectionViewModes = const <int>[3],
    this.properties = const <String, Object?>{},
    this.formFields = const <UxFieldSpec>[],
    this.summaryText = '',
    this.emptyTitle = 'No selection',
    this.emptyMessage = 'Choose an item from the collection to inspect it.',
    this.defaultAlertMessage = 'Something needs your attention.',
    this.collectionFlex = 7,
    this.detailFlex = 5,
    this.views = const <UxViewSpec>[
      UxViewSpec(vid: 4, i: 1),
      UxViewSpec(vid: 4, i: 2),
      UxViewSpec(vid: 12, i: 10),
      UxViewSpec(vid: 6, i: 12),
      UxViewSpec(vid: 5, i: 13),
      UxViewSpec(vid: 9, i: 11),
      UxViewSpec(vid: 11, i: 14),
      UxViewSpec(vid: 4, i: 3),
    ],
  }) : super(tid: 1);

  final String collectionTitle;
  final List<String> collectionColumns;
  final List<List<Object?>> collectionRows;
  final List<int> collectionViewModes;
  final Map<String, Object?> properties;
  final List<UxFieldSpec> formFields;
  final String summaryText;
  final String emptyTitle;
  final String emptyMessage;
  final String defaultAlertMessage;
  final int collectionFlex;
  final int detailFlex;
  final List<UxViewSpec> views;

  UxViewSpec? viewById(int vid) {
    for (final view in views) {
      if (view.vid == vid) return view;
    }
    return null;
  }
}
