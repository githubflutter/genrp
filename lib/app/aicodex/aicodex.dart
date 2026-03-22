import 'package:flutter/material.dart';
import 'package:genrp/core/gen/adminhome.dart';
import 'package:genrp/core/gen/uexplorer.dart';
import 'package:genrp/core/model/uschema/ux_template_action_spec.dart';
import 'package:genrp/core/theme/theme.dart';
import 'package:genrp/core/ux/draggable_fab.dart';
import 'package:genrp/meta.dart';

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
  void _handleTemplateAction(
    UxTemplateAction action,
    Map<String, Object?> payload,
  ) {
    final String label = switch (action) {
      UxTemplateAction.commit => 'Commit',
      UxTemplateAction.refetch => 'Refetch',
      UxTemplateAction.cancel => 'Cancel',
      UxTemplateAction.share => 'Share',
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          payload.isEmpty ? '$label triggered' : '$label triggered: $payload',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const AdminHome(title: 'AICodex', statusText: 'AICodex:${AppMeta.aicodex}/${AppMeta.f}/${AppMeta.v}', nodes: AICodexHome._bschemaNodes),
        DraggableFAB(
          icon: Icons.auto_awesome,
          onAction: _handleTemplateAction,
          actions: <UxTemplateActionSpec>[
            UxTemplateActionSpec(
              action: UxTemplateAction.commit,
              payload: <String, Object?>{'scope': 'aicodex'},
            ),
            UxTemplateActionSpec(
              action: UxTemplateAction.refetch,
              payload: <String, Object?>{'scope': 'aicodex'},
            ),
            UxTemplateActionSpec(
              action: UxTemplateAction.cancel,
              payload: <String, Object?>{'scope': 'aicodex'},
            ),
            UxTemplateActionSpec(
              action: UxTemplateAction.share,
              payload: <String, Object?>{'scope': 'aicodex'},
            ),
          ],
        ),
      ],
    );
  }
}
