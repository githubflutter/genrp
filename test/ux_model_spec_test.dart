import 'package:flutter_test/flutter_test.dart';
import 'package:genrp/core/ux/a/route.dart';
import 'package:genrp/core/ux/m/m.dart';

void main() {
  test('ux model specs derive ids and packed codes consistently', () {
    const template = UxCrudTemplateSpec(i: 20001);
    const paper = UxPaperSpec(pid: 1, i: 10002, template: template);
    const route = UxRouteSpec(
      appName: 'workspace',
      pageSpecId: 10002,
      optionalId: '42',
      title: 'Paperone / 42',
      subtitle: 'Scroll host with the same CRUD workspace',
      paper: paper,
    );

    expect(paper.n, 'paperone');
    expect(paper.id, '1');
    expect(paper.code, 1000000);

    expect(template.n, 'tcrud');
    expect(template.idForPaper(1), '1.1');
    expect(template.codeForPaper(1), 1001000);

    final collectionView = template.viewById(12)!;
    expect(collectionView.n, 'collectionview');
    expect(collectionView.idFor(pid: 1, tid: 1), '1.1.12');
    expect(collectionView.codeFor(pid: 1, tid: 1), 1001012);

    expect(route.pageSpecId, paper.i);
    expect(route.path, '/workspace/10002/42');
    expect(route.scopeKey, 'workspace.10002.42');
  });

  test('route spec and parsed route align on path and page spec id', () {
    const routeSpec = UxRouteSpec(
      appName: 'workspace',
      pageSpecId: 10001,
      optionalId: '84',
      title: 'Paperzero / 84',
      subtitle: 'Bare container host with CRUD workspace',
      paper: UxPaperSpec(
        pid: 0,
        i: 10001,
        template: UxCrudTemplateSpec(i: 20001),
      ),
    );

    final parsed = UxRoute.parse(routeSpec.path);

    expect(routeSpec.pageSpecId, routeSpec.paper.i);
    expect(parsed.appName, routeSpec.appName);
    expect(parsed.pageSpecId, routeSpec.pageSpecId);
    expect(parsed.optionalId, routeSpec.optionalId);
  });
}
