import 'package:genrp/core/agent/copilot_route.dart';
import 'package:genrp/core/gen/uschema_cache.dart';
import 'package:genrp/core/gen/uschema_codec.dart';
import 'package:genrp/core/gen/uschema_compiled.dart';
import 'package:genrp/core/model/uschema/ux_specs.dart';

/// Small runtime helper for compile/cache access to unified UX specs.
///
/// Raw `UxSpec` remains the truth. This helper owns the practical
/// compile-on-demand and refresh behavior used by runtime surfaces.
class UschemaRuntime {
  UschemaRuntime({
    UschemaCache? cache,
    UschemaCodec codec = const UschemaCodec(),
  })  : _cache = cache ?? UschemaCache(),
        _codec = codec;

  final UschemaCache _cache;
  final UschemaCodec _codec;

  UschemaCompiled compiled(UxSpec spec) {
    final cached = _cache.get(spec.i);
    if (cached != null && cached.matches(spec)) return cached.compiled;
    final compiled = _codec.compile(spec);
    _cache.put(spec, compiled);
    return compiled;
  }

  UschemaCompiled refresh(UxSpec spec) {
    _cache.remove(spec.i);
    final compiled = _codec.compile(spec);
    _cache.put(spec, compiled);
    return compiled;
  }

  UschemaCompiled refreshResolved(
    String routePath, {
    required List<UxRouteSpec> presets,
    required UxRouteSpec Function(CopilotRoute route, {List<UxRouteSpec> presets}) resolve,
  }) {
    final route = CopilotRoute.parse(routePath);
    final routeSpec = resolve(route, presets: presets);
    return refresh(routeSpec.spec);
  }

  void remove(int specId) {
    _cache.remove(specId);
  }

  void clear() {
    _cache.clear();
  }
}
