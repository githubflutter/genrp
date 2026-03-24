class CopilotRoute {
  const CopilotRoute({
    required this.appName,
    required this.pageSpecId,
    this.optionalId,
  });

  factory CopilotRoute.fromJson(Map<String, dynamic> json) {
    return CopilotRoute(
      appName: json['appName'] as String? ?? '',
      pageSpecId: (json['pageSpecId'] as num?)?.toInt() ?? 0,
      optionalId: json['optionalId'] as String?,
    );
  }

  factory CopilotRoute.parse(String raw) {
    final uri = Uri.parse(raw.startsWith('/') ? raw : '/$raw');
    final segments = uri.pathSegments;
    if (segments.length < 2) {
      throw const FormatException(
        'Route must follow /<appname>/<pagespecid>/<optionalid?>',
      );
    }

    final pageSpecId = int.tryParse(segments[1]);
    if (pageSpecId == null) {
      throw FormatException(
        'Route page spec id must be an integer: ${segments[1]}',
      );
    }

    return CopilotRoute(
      appName: segments[0],
      pageSpecId: pageSpecId,
      optionalId: segments.length > 2 ? segments[2] : null,
    );
  }

  final String appName;
  final int pageSpecId;
  final String? optionalId;

  String get path =>
      '/$appName/$pageSpecId${optionalId == null ? '' : '/$optionalId'}';

  String get scopeKey =>
      '$appName.$pageSpecId${optionalId == null ? '' : '.$optionalId'}';

  Map<String, dynamic> toJson() => <String, dynamic>{
    'appName': appName,
    'pageSpecId': pageSpecId,
    'optionalId': optionalId,
  };

  @override
  String toString() => path;
}
