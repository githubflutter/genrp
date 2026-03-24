import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/model/base/usr_model.dart';
import 'package:genrp/core/model/bdata/user_model.dart';

class MockAuth {
  const MockAuth._();

  static const String username = 'admin';
  static const String password = 'admin';

  static const UsrModel _usr = UsrModel(
    i: 0,
    d: 0,
    e: 0,
    a: true,
    u: username,
    p: password,
    n: 'Administrator',
    x: 0,
    l: 0,
  );

  static const UserModel _user = UserModel(
    i: 0,
    d: 0,
    e: 0,
    a: true,
    u: username,
    p: password,
    n: 'Administrator',
    x: 0,
    l: 0,
  );

  static bool validate({
    required String username,
    required String password,
  }) {
    return username == MockAuth.username && password == MockAuth.password;
  }

  static bool apply(
    Autopilot autopilot, {
    String username = MockAuth.username,
    String password = MockAuth.password,
    bool notify = true,
  }) {
    if (!validate(username: username, password: password)) {
      return false;
    }
    autopilot.setContext(usr: _usr, user: _user, notify: notify);
    return true;
  }
}
