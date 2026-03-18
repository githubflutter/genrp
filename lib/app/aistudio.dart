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
        body: Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.grey.shade100,
                child: const Center(child: Text('Model Navigation')),
              ),
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(
              flex: 5,
              child: Container(
                color: Colors.white,
                child: const Center(child: Text('Master/Main Editor')),
              ),
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.grey.shade100,
                child: const Center(child: Text('Property Editor')),
              ),
            ),
          ],
        ),
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
