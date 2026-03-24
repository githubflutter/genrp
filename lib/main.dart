import 'package:flutter/material.dart';
import 'package:genrp/app/aicodex/aicodex.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:provider/provider.dart';

void main() {
  // Create autopilot instance
  final autopilot = Autopilot();


  runApp(ChangeNotifierProvider<Autopilot>.value(value: autopilot, child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, this.initialRoutePath, this.autoSignIn = false});

  final String? initialRoutePath;
  final bool autoSignIn;

  @override
  Widget build(BuildContext context) {
    return AICodexApp(autoSignIn: autoSignIn);
  }
}
