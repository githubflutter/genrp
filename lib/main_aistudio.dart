import 'package:flutter/material.dart';
import 'package:genrp/app/aistudio/aistudio.dart';

void main() {
  runApp(const MainAIStudioApp());
}

class MainAIStudioApp extends StatelessWidget {
  const MainAIStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const AIStudioApp(autoSignIn: true);
  }
}
