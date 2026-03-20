import 'package:genrp/core/model/base/usr_model.dart';
import 'package:genrp/core/model/bdata/user_model.dart';
import 'package:genrp/core/ux/a/pilot.dart';

class UxMockAuthSession {
  const UxMockAuthSession({required this.usr, required this.user});

  final UsrModel usr;
  final UserModel user;
}

class UxMockAuth {
  const UxMockAuth();

  static const String username = 'admin';
  static const String password = 'admin';

  bool validate({required String username, required String password}) {
    return username == UxMockAuth.username && password == UxMockAuth.password;
  }

  UxMockAuthSession? signIn({
    required String username,
    required String password,
  }) {
    if (!validate(username: username, password: password)) {
      return null;
    }

    const usr = UsrModel(
      i: 0,
      d: 0,
      e: 0,
      a: true,
      u: UxMockAuth.username,
      p: UxMockAuth.password,
      n: 'Administrator',
      x: 0,
      l: 0,
    );
    const user = UserModel(
      i: 0,
      d: 0,
      e: 0,
      a: true,
      u: UxMockAuth.username,
      p: UxMockAuth.password,
      n: 'Administrator',
      x: 0,
      l: 0,
    );

    return const UxMockAuthSession(usr: usr, user: user);
  }

  bool applyToPilot(
    UxPilot pilot, {
    String username = UxMockAuth.username,
    String password = UxMockAuth.password,
    bool notify = true,
  }) {
    final session = signIn(username: username, password: password);
    if (session == null) {
      return false;
    }
    pilot.setContext(usr: session.usr, user: session.user, notify: notify);
    return true;
  }
}
