import 'package:flutter/material.dart';
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
    const textStyle = TextStyle(fontSize: 12);

    return Scaffold(
      appBar: AppBar(title: const Text('AIStudio', style: textStyle)),
      body: const SizedBox.expand(),
      bottomNavigationBar: Container(
        height: 32,
        color: Theme.of(context).colorScheme.surface,
        child: Row(
          children: <Widget>[
            const Text('Status: Ready', style: textStyle),
            const Spacer(),
            Text(
              'AIStudio:${AppMeta.aistudio}/${AppMeta.f}/${AppMeta.v}',
              style: textStyle,
            ),
          ],
        ),
      ),
    );
  }
}
