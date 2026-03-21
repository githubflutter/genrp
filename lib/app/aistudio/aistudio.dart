import 'package:flutter/material.dart';
import 'package:genrp/core/gen/adminhome.dart';
import 'package:genrp/core/theme/theme.dart';
import 'package:genrp/meta.dart';

class AIStudioApp extends StatelessWidget {
  const AIStudioApp({super.key, this.autoSignIn = false});

  final bool autoSignIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AIStudio',
      theme: UxTheme.lightTheme(),
      darkTheme: UxTheme.darkTheme(),
      themeMode: ThemeMode.dark,
      home: const AIStudioHome(),
    );
  }
}

class AIStudioHome extends StatelessWidget {
  const AIStudioHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminHome(
      title: 'AIStudio',
      statusText: 'AIStudio:${AppMeta.aistudio}/${AppMeta.f}/${AppMeta.v}',
    );
  }
}
