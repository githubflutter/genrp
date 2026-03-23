import 'package:genrp/core/model/uschema/ux_node_spec.dart';
import 'package:genrp/core/ux/mixins.dart';

class UxAppSpec extends UxNodeSpec {
  const UxAppSpec({
    required super.i,
    required this.shellId,
    super.m,
  });

  final int shellId;

  @override
  int get l => UxLayer.app.code;

  @override
  String get n => UxRegister.apps[i] ?? 'app$i';

  @override
  int get code => i;

  @override
  int get t => shellId;

  String get shellName => UxRegister.appShells[shellId] ?? 'appshell$shellId';
}

class UxAppSpecs {
  UxAppSpecs._();

  static const UxAppSpec aicodex = UxAppSpec(i: 0, shellId: 1);
  static const UxAppSpec aistudio = UxAppSpec(i: 1, shellId: 1);
  static const UxAppSpec aibook = UxAppSpec(i: 2, shellId: 3);
  static const UxAppSpec aiwork = UxAppSpec(i: 3, shellId: 2);

  static const List<UxAppSpec> values = <UxAppSpec>[
    aicodex,
    aistudio,
    aibook,
    aiwork,
  ];

  static UxAppSpec byName(String name) {
    for (final app in values) {
      if (app.n == name) return app;
    }
    throw ArgumentError.value(name, 'name', 'Unknown app spec name');
  }
}
