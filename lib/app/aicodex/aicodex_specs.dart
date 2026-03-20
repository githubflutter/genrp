import 'package:genrp/core/agent/copilot_route.dart';
import 'package:genrp/meta.dart';

class AICodexSection {
  const AICodexSection({
    required this.route,
    required this.title,
    required this.subtitle,
  });

  final CopilotRoute route;
  final String title;
  final String subtitle;

  String get path => route.path;
}

class AICodexSpecs {
  AICodexSpecs._();

  static const String appName = 'aicodex';
  static const String title = 'AICodex';
  static const int appMeta = AppMeta.aicodex;
  static const int paperZeroSpecId = 30001;
  static const int paperOneSpecId = 30002;

  static List<AICodexSection> presets() => <AICodexSection>[
    buildSection(
      const CopilotRoute(
        appName: appName,
        pageSpecId: paperZeroSpecId,
        optionalId: '42',
      ),
    ),
    buildSection(
      const CopilotRoute(
        appName: appName,
        pageSpecId: paperOneSpecId,
        optionalId: '42',
      ),
    ),
  ];

  static CopilotRoute? directRoute({String? explicitPath, Uri? currentUri}) {
    final candidates = <String?>[
      explicitPath,
      currentUri?.path,
      currentUri == null ? Uri.base.path : null,
    ];
    for (final candidate in candidates) {
      if (candidate == null || candidate.trim().isEmpty || candidate == '/') {
        continue;
      }
      try {
        final route = CopilotRoute.parse(candidate);
        if (route.appName == appName) {
          return route;
        }
      } on FormatException {
        continue;
      }
    }
    return null;
  }

  static String? directPath({String? explicitPath, Uri? currentUri}) =>
      directRoute(explicitPath: explicitPath, currentUri: currentUri)?.path;

  static CopilotRoute initialRoute({
    String? explicitPath,
    Uri? currentUri,
    List<AICodexSection> presets = const <AICodexSection>[],
  }) {
    final direct = directRoute(
      explicitPath: explicitPath,
      currentUri: currentUri,
    );
    if (direct != null) {
      return direct;
    }
    if (presets.isNotEmpty) {
      return presets.first.route;
    }
    return const CopilotRoute(
      appName: appName,
      pageSpecId: paperZeroSpecId,
      optionalId: '42',
    );
  }

  static String initialPath({
    String? explicitPath,
    Uri? currentUri,
    List<AICodexSection> presets = const <AICodexSection>[],
  }) {
    return initialRoute(
      explicitPath: explicitPath,
      currentUri: currentUri,
      presets: presets,
    ).path;
  }

  static AICodexSection resolve({
    required CopilotRoute route,
    List<AICodexSection> presets = const <AICodexSection>[],
  }) {
    for (final preset in presets) {
      if (preset.path == route.path) {
        return preset;
      }
    }
    return buildSection(route);
  }

  static AICodexSection buildSection(CopilotRoute route) {
    final isSchema = route.pageSpecId != paperOneSpecId;
    return AICodexSection(
      route: route,
      title: isSchema ? 'Schema Canvas' : 'Function Lab',
      subtitle: isSchema
          ? 'Hard-coded schema workspace for model catalogs, drafts, and preview SQL.'
          : 'Hard-coded function workspace for scripts, envelopes, and deploy checks.',
    );
  }
}
