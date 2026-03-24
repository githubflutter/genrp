import 'package:flutter/material.dart';
import 'package:genrp/app/aistudio/aistudio.dart';
import 'package:genrp/core/agent/autopilot.dart';
// import removed
import 'package:provider/provider.dart';

void main() {
  // Create autopilot instance
  final autopilot = Autopilot();

  // Presentation mode - no action handlers

  runApp(ChangeNotifierProvider<Autopilot>.value(value: autopilot, child: const MainAIStudioApp()));
}

class MainAIStudioApp extends StatelessWidget {
  const MainAIStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const AIStudioApp(autoSignIn: true);
  }
}
