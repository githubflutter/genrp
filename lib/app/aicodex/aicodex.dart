import 'package:flutter/material.dart';
import 'package:genrp/core/gen/adminhome.dart';
import 'package:genrp/core/gen/uexplorer.dart';
import 'package:genrp/meta.dart';
import 'package:genrp/core/theme/theme.dart';

class AICodexApp extends StatelessWidget {
  const AICodexApp({super.key, this.autoSignIn = false});

  final bool autoSignIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, title: 'AICodex', theme: UxTheme.lightTheme(), darkTheme: UxTheme.darkTheme(), themeMode: ThemeMode.dark, home: const AICodexHome());
  }
}

class AICodexHome extends StatefulWidget {
  const AICodexHome({super.key});

  static const List<UExplorerNode> _bschemaNodes = <UExplorerNode>[
    UExplorerNode(label: 'Entity'),
    UExplorerNode(label: 'Field'),
    UExplorerNode(label: 'Table'),
    UExplorerNode(label: 'Column'),
    UExplorerNode(label: 'Function'),
    UExplorerNode(label: 'Parameter'),
  ];

  @override
  State<AICodexHome> createState() => _AICodexHomeState();
}

class _AICodexHomeState extends State<AICodexHome> {

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const AdminHome(title: 'AICodex', statusText: 'AICodex:${AppMeta.aicodex}/${AppMeta.f}/${AppMeta.v}', nodes: AICodexHome._bschemaNodes),
      ],
    );
  }
}
