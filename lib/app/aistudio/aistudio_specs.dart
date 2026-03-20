import 'package:genrp/core/agent/copilot_route.dart';
import 'package:genrp/meta.dart';

class AIStudioSection {
  const AIStudioSection({
    required this.route,
    required this.title,
    required this.subtitle,
  });

  final CopilotRoute route;
  final String title;
  final String subtitle;

  String get path => route.path;
}

class AIStudioSpecs {
  AIStudioSpecs._();

  static const String appName = 'aistudio';
  static const String title = 'AIStudio';
  static const int appMeta = AppMeta.aistudio;
  static const int paperZeroSpecId = 40001;
  static const int paperOneSpecId = 40002;

  static List<AIStudioSection> presets() => <AIStudioSection>[
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
    List<AIStudioSection> presets = const <AIStudioSection>[],
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
    List<AIStudioSection> presets = const <AIStudioSection>[],
  }) {
    return initialRoute(
      explicitPath: explicitPath,
      currentUri: currentUri,
      presets: presets,
    ).path;
  }

  static AIStudioSection resolve(
    CopilotRoute route, {
    List<AIStudioSection> presets = const <AIStudioSection>[],
  }) {
    for (final preset in presets) {
      if (preset.path == route.path) {
        return preset;
      }
    }
    return buildSection(route);
  }

  static AIStudioSection buildSection(CopilotRoute route) {
    final isBoard = route.pageSpecId != paperOneSpecId;
    return AIStudioSection(
      route: route,
      title: isBoard ? 'Studio Board' : 'Review Queue',
      subtitle: isBoard
          ? 'Hard-coded explorer, draft, and inspector workspace for UX/spec authoring.'
          : 'Hard-coded review lane for publish checks, notes, and release prep.',
    );
  }
}
