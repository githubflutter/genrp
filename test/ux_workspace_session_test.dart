import 'package:flutter_test/flutter_test.dart';
import 'package:genrp/core/ux/a/a.dart';

void main() {
  test(
    'workspace session rejects invalid credentials and stays at login',
    () async {
      final session = UxWorkspaceSession(
        pilot: UxPilot(),
        initialRoutePath: '/workspace/10001/42',
      );

      final signedIn = await session.signIn(
        username: 'admin',
        password: 'wrong',
      );

      expect(signedIn, isFalse);
      expect(session.stage, UxWorkspaceStage.login);
      expect(session.errorMessage, contains('admin / admin'));
      expect(session.routePath, isNull);

      session.dispose();
    },
  );

  test(
    'workspace session signs in, bootstraps route, and applies mock user context',
    () async {
      final session = UxWorkspaceSession(
        pilot: UxPilot(),
        initialRoutePath: '/workspace/10002/84',
      );

      final future = session.signIn(
        username: UxMockAuth.username,
        password: UxMockAuth.password,
      );

      expect(session.stage, UxWorkspaceStage.loading);

      final signedIn = await future;

      expect(signedIn, isTrue);
      expect(session.stage, UxWorkspaceStage.ready);
      expect(session.routePath, '/workspace/10002/84');
      expect(session.route.path, '/workspace/10002/84');
      expect((session.pilot.usr as dynamic).i, 0);
      expect((session.pilot.user as dynamic).i, 0);

      session.openRoute('/workspace/10001/42');

      expect(session.routePath, '/workspace/10001/42');
      expect(session.route.path, '/workspace/10001/42');

      session.dispose();
    },
  );
}
