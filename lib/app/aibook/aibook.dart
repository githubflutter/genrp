import 'package:flutter/material.dart';

import 'package:genrp/meta.dart';
import 'package:genrp/app/aibook/autopilotgo.dart';
import 'package:genrp/core/agent/mock_transport.dart';
import 'package:genrp/core/generator/boilerplate_generator.dart';
import 'package:genrp/core/model/uschema/ux_document_spec.dart';
import 'package:genrp/core/theme/genrp_theme.dart';
import 'package:provider/provider.dart';

class AIBookApp extends StatelessWidget {
  const AIBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AutopilotGo>(
      create: (_) => AutopilotGo(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AIBook',
        theme: GenrpTheme.lightTheme(),
        darkTheme: GenrpTheme.darkTheme(),
        themeMode: ThemeMode.dark,
        home: const _AIBookHome(),
      ),
    );
  }
}

class _AIBookHome extends StatefulWidget {
  const _AIBookHome();

  @override
  State<_AIBookHome> createState() => _AIBookHomeState();
}

class _AIBookHomeState extends State<_AIBookHome> {
  late final Future<UxSpecDocument> _specFuture;

  @override
  void initState() {
    super.initState();
    _specFuture = _loadSpec();
  }

  Future<UxSpecDocument> _loadSpec() async {
    return MockTransport.fetchSpecDocument();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AutopilotGo>(
      builder: (context, autopilot, _) {
        return FutureBuilder<UxSpecDocument>(
          future: _specFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Scaffold(
                appBar: AppBar(title: const Text('Error')),
                body: Center(
                  child: Text(
                    'Failed to load spec:\n${snapshot.error}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final spec = snapshot.data!;
            autopilot.configureSpec(spec);

            if (autopilot.specError != null) {
              return Scaffold(
                appBar: AppBar(title: const Text('Validation Error')),
                body: Center(
                  child: Text(
                    autopilot.specError!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final status =
                autopilot.resolve('ux.status')?.toString() ?? 'Ready';

            return Scaffold(
              appBar: AppBar(title: Text(spec.toolbarTitle)),
              body: DynamicSpecBody(spec: spec, autopilot: autopilot),
              bottomNavigationBar: BottomAppBar(
                child: Row(
                  children: [
                    Text('Status: $status'),
                    const Spacer(),
                    Text('AIBook:${AppMeta.aibook}/${AppMeta.f}/${AppMeta.v}'),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
