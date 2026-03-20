import 'package:flutter/material.dart';
import 'package:genrp/app/aiwork/aiwork.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, this.initialRoutePath, this.autoSignIn = false});

  final String? initialRoutePath;
  final bool autoSignIn;

  @override
  Widget build(BuildContext context) {
    return AIWorkApp(
      initialRoutePath: initialRoutePath,
      autoSignIn: autoSignIn,
    );
  }
}
