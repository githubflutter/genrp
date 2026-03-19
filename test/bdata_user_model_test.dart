import 'package:flutter_test/flutter_test.dart';
import 'package:genrp/core/model/bdata/user_model.dart';

void main() {
  test('bdata UserModel round-trips the expected business user fields', () {
    final model = UserModel.fromJson(const <String, dynamic>{
      'i': 1000000000001,
      'd': 1000000000002,
      'e': 1000000000003,
      'a': true,
      'u': 'demo_user',
      'p': 'secret',
      'n': 'Demo User',
      'x': 1000000000999,
      'l': 7,
    });

    expect(model.i, 1000000000001);
    expect(model.d, 1000000000002);
    expect(model.e, 1000000000003);
    expect(model.a, isTrue);
    expect(model.u, 'demo_user');
    expect(model.p, 'secret');
    expect(model.n, 'Demo User');
    expect(model.x, 1000000000999);
    expect(model.l, 7);
    expect(model.toJson(), <String, dynamic>{
      'i': 1000000000001,
      'd': 1000000000002,
      'e': 1000000000003,
      'a': true,
      'u': 'demo_user',
      'p': 'secret',
      'n': 'Demo User',
      'x': 1000000000999,
      'l': 7,
    });
  });

  test('bdata UserModel copyWith updates selected fields only', () {
    const model = UserModel(
      i: 1,
      d: 2,
      e: 3,
      a: true,
      u: 'demo',
      p: 'pw',
      n: 'Demo',
      x: 4,
      l: 1,
    );

    final updated = model.copyWith(a: false, n: 'Updated', l: 9);

    expect(updated.i, 1);
    expect(updated.d, 2);
    expect(updated.e, 3);
    expect(updated.a, isFalse);
    expect(updated.u, 'demo');
    expect(updated.p, 'pw');
    expect(updated.n, 'Updated');
    expect(updated.x, 4);
    expect(updated.l, 9);
  });
}
