import 'package:genrp/core/model/uschema/ux_action_holder_spec.dart';
import 'package:genrp/core/model/uschema/ux_field_spec.dart';
import 'package:genrp/core/model/uschema/ux_node_spec.dart';
import 'package:genrp/core/model/uschema/ux_scope_spec.dart';
import 'package:genrp/core/model/uschema/ux_template_action_spec.dart';
import 'package:genrp/core/ux/mixins.dart';

abstract class UxTemplateSpec extends UxNodeSpec {
  const UxTemplateSpec({
    required this.tid,
    required super.i,
    super.s,
    super.m,
    this.actions = const <UxTemplateActionSpec>[],
    this.actionHolders = const <UxActionHolderSpec>[],
  });

  final int tid;
  final List<UxTemplateActionSpec> actions;
  final List<UxActionHolderSpec> actionHolders;

  @override
  String get n => UxRegister.templates[tid] ?? 'template$tid';

  @override
  int get code => UxRegister.templateCode(pid: 0, tid: tid);

  @override
  String get id => '$tid';

  int codeForPaper(int pid) => UxRegister.templateCode(pid: pid, tid: tid);

  String idForPaper(int pid) => UxRegister.templateId(pid: pid, tid: tid);
}

class UxWorkspaceTemplateSpec extends UxTemplateSpec {
  const UxWorkspaceTemplateSpec({
    required super.i,
    super.s,
    super.m,
    super.actions = const <UxTemplateActionSpec>[
      UxTemplateActionSpec(action: UxTemplateAction.commit),
      UxTemplateActionSpec(action: UxTemplateAction.refetch),
      UxTemplateActionSpec(action: UxTemplateAction.cancel),
      UxTemplateActionSpec(action: UxTemplateAction.share),
    ],
    super.actionHolders = const <UxActionHolderSpec>[
      UxActionHolderSpec(
        index: 1,
        position: UxActionHolderPosition.top,
        presentation: UxActionHolderPresentation.toolbar,
        actionKinds: <UxTemplateAction>[
          UxTemplateAction.commit,
          UxTemplateAction.refetch,
          UxTemplateAction.cancel,
          UxTemplateAction.share,
        ],
      ),
      UxActionHolderSpec(
        index: 2,
        position: UxActionHolderPosition.bottom,
        presentation: UxActionHolderPresentation.toolbar,
      ),
      UxActionHolderSpec(
        index: 3,
        position: UxActionHolderPosition.floating,
        presentation: UxActionHolderPresentation.floatingIsland,
        actionKinds: <UxTemplateAction>[
          UxTemplateAction.commit,
          UxTemplateAction.refetch,
          UxTemplateAction.cancel,
          UxTemplateAction.share,
        ],
      ),
    ],
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
    this.scopes = const <UxScopeSpec>[
      UxScopeSpec(vid: 4, i: 1),
      UxScopeSpec(vid: 4, i: 2),
      UxScopeSpec(vid: 12, i: 10),
      UxScopeSpec(vid: 6, i: 12),
      UxScopeSpec(vid: 5, i: 13),
      UxScopeSpec(vid: 9, i: 11),
      UxScopeSpec(vid: 11, i: 14),
      UxScopeSpec(vid: 4, i: 3),
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
  final List<UxScopeSpec> scopes;

  UxScopeSpec? scopeById(int vid) {
    for (final scope in scopes) {
      if (scope.vid == vid) return scope;
    }
    return null;
  }
}
