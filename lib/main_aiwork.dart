import 'package:flutter/material.dart';
import 'package:genrp/app/aiwork/aiwork.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:provider/provider.dart';

void main() {
  final autopilot = Autopilot();

  runApp(ChangeNotifierProvider<Autopilot>.value(value: autopilot, child: const MainAIWorkApp()));
}

class MainAIWorkApp extends StatelessWidget {
  const MainAIWorkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const AIWorkApp(autoSignIn: true);
  }
}
