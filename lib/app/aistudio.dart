import 'package:flutter/material.dart';
import 'package:genrp/meta.dart';

class AIStudioApp extends StatelessWidget {
  const AIStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AIStudio',
      home: Scaffold(
        appBar: AppBar(title: const Text('AIStudio')),
        body: const Center(child: Text('AIStudio Home')),
        floatingActionButton: FloatingActionButton(onPressed: () {}, child: const Icon(Icons.edit)),
        bottomNavigationBar: BottomAppBar(
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [const Spacer(), Text('AIStudio:${AppMeta.aistudio}/${AppMeta.f}/${AppMeta.v}')]),
          ),
        ),
      ),
    );
  }
}
