import 'package:flutter/material.dart';
import 'package:genrp/app/aibook/aibook.dart';
import 'package:genrp/app/aicodex/aicodex.dart';
import 'package:genrp/app/aistudio/aistudio.dart';
import 'package:genrp/app/workspace/workspace.dart';
import 'package:genrp/core/ux/a/a.dart';
import 'package:genrp/core/theme/genrp_theme.dart';

void main() {
  runApp(const MainApp());
}

enum _SelectedApp { workspaceDemo, workspace, aibook, aicodex, aistudio }

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final String? _initialWorkspacePath = UxWorkspaceBootstrap.directPath(
    currentUri: Uri.base,
  );
  _SelectedApp? _selectedApp;

  @override
  void initState() {
    super.initState();
    if (_initialWorkspacePath != null) {
      _selectedApp = _SelectedApp.workspace;
    }
  }

  void _open(_SelectedApp app) {
    if (_selectedApp != null) return;
    setState(() {
      _selectedApp = app;
    });
  }

  @override
  Widget build(BuildContext context) {
    return switch (_selectedApp) {
      _SelectedApp.workspaceDemo => WorkSpaceApp(
        initialRoutePath:
            _initialWorkspacePath ??
            '/workspace/${UxWorkspaceSpecs.paperZeroSpecId}/42',
        autoSignIn: true,
      ),
      _SelectedApp.workspace => WorkSpaceApp(
        initialRoutePath: _initialWorkspacePath,
      ),
      _SelectedApp.aibook => const AIBookApp(),
      _SelectedApp.aicodex => const AICodexApp(),
      _SelectedApp.aistudio => const AIStudioApp(),
      null => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'GenRP',
        theme: GenrpTheme.lightTheme(),
        darkTheme: GenrpTheme.darkTheme(),
        themeMode: ThemeMode.dark,
        home: _LauncherHome(onSelect: _open),
      ),
    };
  }
}

class _LauncherHome extends StatelessWidget {
  const _LauncherHome({required this.onSelect});

  final ValueChanged<_SelectedApp> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('GenRP')),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 48,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Choose App',
                        style: theme.textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Selection is one-way for this runtime session.',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),
                      _LauncherButton(
                        title: 'WorkSpace Demo',
                        subtitle:
                            'One-tap mock sign-in to the CRUD concept screen',
                        onPressed: () => onSelect(_SelectedApp.workspaceDemo),
                      ),
                      const SizedBox(height: 12),
                      _LauncherButton(
                        title: 'WorkSpace',
                        subtitle:
                            'Experimental route-first UX runtime with login',
                        onPressed: () => onSelect(_SelectedApp.workspace),
                      ),
                      const SizedBox(height: 12),
                      _LauncherButton(
                        title: 'AIBook',
                        subtitle: 'Runtime reader and preview flow',
                        onPressed: () => onSelect(_SelectedApp.aibook),
                      ),
                      const SizedBox(height: 12),
                      _LauncherButton(
                        title: 'AICodex',
                        subtitle: 'Configurator and schema application surface',
                        onPressed: () => onSelect(_SelectedApp.aicodex),
                      ),
                      const SizedBox(height: 12),
                      _LauncherButton(
                        title: 'AIStudio',
                        subtitle: 'Model-row editing surface',
                        onPressed: () => onSelect(_SelectedApp.aistudio),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LauncherButton extends StatelessWidget {
  const _LauncherButton({
    required this.title,
    required this.subtitle,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(title), const SizedBox(height: 4), Text(subtitle)],
        ),
      ),
    );
  }
}
