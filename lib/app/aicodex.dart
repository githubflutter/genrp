import 'package:flutter/material.dart';
import 'package:genrp/meta.dart';

class AICodexApp extends StatelessWidget {
  const AICodexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AICodex',
      home: Scaffold(
        appBar: AppBar(title: const Text('AICodex')),
        body: const Center(child: Text('AICodex Home')),
        floatingActionButton: FloatingActionButton(onPressed: () {}, child: const Icon(Icons.add)),
        bottomNavigationBar: BottomAppBar(
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [const Spacer(), Text('AICodex:${AppMeta.aicode}/${AppMeta.f}/${AppMeta.v}')]),
          ),
        ),
      ),
    );
  }
}
