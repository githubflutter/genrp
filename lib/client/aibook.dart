import 'package:flutter/material.dart';
import 'package:genrp/meta.dart';

class AIBookApp extends StatelessWidget {
  const AIBookApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AIBook',
      home: Scaffold(
        appBar: AppBar(title: const Text('AIBook')),
        body: const Center(child: Text('AIBook Home')),
        floatingActionButton: FloatingActionButton(onPressed: () {}, child: const Icon(Icons.book)),
        bottomNavigationBar: BottomAppBar(
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [const Spacer(), Text('AIBook:${AppMeta.aibook}/${AppMeta.f}/${AppMeta.v}')]),
          ),
        ),
      ),
    );
  }
}
