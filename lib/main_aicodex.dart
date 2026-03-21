import 'package:flutter/material.dart';
import 'package:genrp/app/aicodex/aicodex.dart';

void main() {
  runApp(const MainAICodexApp());
}

class MainAICodexApp extends StatelessWidget {
  const MainAICodexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const AICodexApp(autoSignIn: true);
  }
}
