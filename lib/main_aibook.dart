import 'package:flutter/material.dart';
import 'package:genrp/app/aibook/aibook.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:provider/provider.dart';

void main() {
  final autopilot = Autopilot();

  runApp(ChangeNotifierProvider<Autopilot>.value(value: autopilot, child: const MainAIBookApp()));
}

class MainAIBookApp extends StatelessWidget {
  const MainAIBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const AIBookApp(autoSignIn: true);
  }
}
