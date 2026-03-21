import 'package:flutter/material.dart';
import 'package:genrp/core/theme/theme.dart';
import 'package:genrp/meta.dart';

class AICodexApp extends StatelessWidget {
  const AICodexApp({super.key, this.autoSignIn = false});

  final bool autoSignIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AICodex',
      theme: UxTheme.lightTheme(),
      darkTheme: UxTheme.darkTheme(),
      themeMode: ThemeMode.dark,
      home: const AICodexHome(),
    );
  }
}

class AICodexHome extends StatelessWidget {
  const AICodexHome({super.key});

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 12);

    return Scaffold(
      appBar: AppBar(title: const Text('AICodex', style: textStyle)),
      body: const SizedBox.expand(),
      bottomNavigationBar: Container(
        height: 32,
        color: Theme.of(context).colorScheme.surface,
        child: Row(
          children: <Widget>[
            const Text('Status: Ready', style: textStyle),
            const Spacer(),
            Text(
              'AICodex:${AppMeta.aicodex}/${AppMeta.f}/${AppMeta.v}',
              style: textStyle,
            ),
          ],
        ),
      ),
    );
  }
}
