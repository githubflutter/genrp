import 'package:flutter/material.dart';
import 'package:genrp/app/aibook/aibook.dart';
import 'package:genrp/app/aicodex/aicodex.dart';
import 'package:genrp/app/aistudio/aistudio.dart';
import 'package:genrp/app/aiwork/aiwork.dart';
import 'package:genrp/app/aiwork/aiwork_specs.dart';
import 'package:genrp/app/aibook/aibook_specs.dart';
import 'package:genrp/app/aicodex/aicodex_specs.dart';
import 'package:genrp/app/aistudio/aistudio_specs.dart';
import 'package:genrp/core/agent/copilot_route.dart';
import 'package:genrp/core/theme/theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, this.initialRoutePath, this.autoSignIn = false});

  final String? initialRoutePath;
  final bool autoSignIn;

  @override
  Widget build(BuildContext context) {
    final directPath = initialRoutePath ?? Uri.base.path;
    final directAppName = _directAppName(directPath);
    if (directAppName != null) {
      return _buildApp(
        directAppName,
        initialRoutePath: directPath,
        autoSignIn: autoSignIn,
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GenRP',
      theme: UxTheme.lightTheme(),
      darkTheme: UxTheme.darkTheme(),
      themeMode: ThemeMode.dark,
      home: MainLauncher(autoSignIn: autoSignIn),
    );
  }
}

class MainLauncher extends StatelessWidget {
  const MainLauncher({super.key, this.autoSignIn = false});

  final bool autoSignIn;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose App')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: ListView(
            padding: const EdgeInsets.all(24),
            shrinkWrap: true,
            children: _launcherEntries
                .map<Widget>(
                  (_LauncherEntry app) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                _buildHome(app.name, autoSignIn: autoSignIn),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(app.title),
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ),
      ),
    );
  }
}

Widget _buildApp(
  String appName, {
  String? initialRoutePath,
  bool autoSignIn = false,
}) {
  switch (appName) {
    case 'aibook':
      return AIBookApp(
        initialRoutePath: initialRoutePath,
        autoSignIn: autoSignIn,
      );
    case 'aicodex':
      return AICodexApp(
        initialRoutePath: initialRoutePath,
        autoSignIn: autoSignIn,
      );
    case 'aistudio':
      return AIStudioApp(
        initialRoutePath: initialRoutePath,
        autoSignIn: autoSignIn,
      );
    case 'aiwork':
    default:
      return AIWorkApp(
        initialRoutePath: initialRoutePath,
        autoSignIn: autoSignIn,
      );
  }
}

Widget _buildHome(String appName, {bool autoSignIn = false}) {
  switch (appName) {
    case 'aibook':
      return AIBookHome(autoSignIn: autoSignIn);
    case 'aicodex':
      return AICodexHome(autoSignIn: autoSignIn);
    case 'aistudio':
      return AIStudioHome(autoSignIn: autoSignIn);
    case 'aiwork':
    default:
      return AIWorkHome(autoSignIn: autoSignIn);
  }
}

String? _directAppName(String? raw) {
  if (raw == null || raw.trim().isEmpty || raw == '/') {
    return null;
  }
  try {
    final route = CopilotRoute.parse(raw);
    switch (route.appName) {
      case AIWorkSpecs.appName:
      case AIBookSpecs.appName:
      case AICodexSpecs.appName:
      case AIStudioSpecs.appName:
        return route.appName;
      default:
        return null;
    }
  } on FormatException {
    return null;
  }
}

class _LauncherEntry {
  const _LauncherEntry(this.name, this.title);

  final String name;
  final String title;
}

const List<_LauncherEntry> _launcherEntries = <_LauncherEntry>[
  _LauncherEntry(AIWorkSpecs.appName, AIWorkSpecs.title),
  _LauncherEntry(AIBookSpecs.appName, AIBookSpecs.title),
  _LauncherEntry(AICodexSpecs.appName, AICodexSpecs.title),
  _LauncherEntry(AIStudioSpecs.appName, AIStudioSpecs.title),
];
