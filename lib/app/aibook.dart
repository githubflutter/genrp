import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genrp/meta.dart';
import 'package:genrp/app/autopilotgo.dart';
import 'package:genrp/core/generator/boilerplate_generator.dart';
import 'package:provider/provider.dart';

class AIBookApp extends StatelessWidget {
  const AIBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AutopilotGo>(
      create: (_) => AutopilotGo(),
      child: MaterialApp(debugShowCheckedModeBanner: false, title: 'AIBook', home: const _AIBookHome()),
    );
  }
}

class _AIBookHome extends StatefulWidget {
  const _AIBookHome();

  @override
  State<_AIBookHome> createState() => _AIBookHomeState();
}

class _AIBookHomeState extends State<_AIBookHome> {
  late final Future<Map<String, dynamic>> _specFuture;

  @override
  void initState() {
    super.initState();
    _specFuture = _loadSpec();
  }

  Future<Map<String, dynamic>> _loadSpec() async {
    final specRaw = await rootBundle.loadString('assets/json/aibook_spec.json');
    final registryRaw = await rootBundle.loadString('assets/json/aibook_registry.json');
    final spec = Map<String, dynamic>.from(jsonDecode(specRaw) as Map);
    final registry = Map<String, dynamic>.from(jsonDecode(registryRaw) as Map);
    final mergedRegistry = <String, dynamic>{
      ...registry,
      'bodiesRegistry': registry['bodies'],
    }..remove('bodies');
    return {
      ...spec,
      ...mergedRegistry,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AutopilotGo>(
      builder: (context, autopilot, _) {
        return FutureBuilder<Map<String, dynamic>>(
          future: _specFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            final spec = snapshot.data!;
            autopilot.configureSpec(spec);
            final toolbar = Map<String, dynamic>.from(spec['toolbar'] as Map? ?? const {});
            final status = autopilot.resolve('ux.status')?.toString() ?? 'Ready';

            return Scaffold(
              appBar: AppBar(title: Text(toolbar['title']?.toString() ?? 'AIBook')),
              body: DynamicSpecBody(spec: spec, autopilot: autopilot),
              floatingActionButton: FloatingActionButton(onPressed: () => autopilot.triggerAction('showPreview'), child: const Icon(Icons.book)),
              bottomNavigationBar: BottomAppBar(
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(children: [Text('Status: $status'), const Spacer(), Text('AIBook:${AppMeta.aibook}/${AppMeta.f}/${AppMeta.v}')]),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
