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
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      const TabBar(
                        labelColor: Colors.black87,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.blue,
                        tabs: [
                          Tab(text: 'Data'),
                          Tab(text: 'UX/Spec'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            ListView(
                              children: const [
                                ListTile(title: Text('Entity')),
                                ListTile(title: Text('Field')),
                                ListTile(title: Text('Relation')),
                                ListTile(title: Text('Action')),
                                ListTile(title: Text('Function')),
                              ],
                            ),
                            ListView(
                              children: const [
                                ListTile(title: Text('Host')),
                                ListTile(title: Text('Body')),
                                ListTile(title: Text('Template')),
                                ListTile(title: Text('Type')),
                                ListTile(title: Text('Widget')),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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
