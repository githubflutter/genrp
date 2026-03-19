import 'package:flutter_test/flutter_test.dart';
import 'package:genrp/core/model/base/usr_model.dart';

void main() {
  test('UsrModel round-trips the expected base user fields', () {
    final model = UsrModel.fromJson(const <String, dynamic>{
      'i': 101,
      'd': 202,
      'e': 303,
      'a': true,
      'u': 'admin',
      'p': 'secret',
      'n': 'Administrator',
      'x': 404,
      'l': 9,
    });

    expect(model.i, 101);
    expect(model.d, 202);
    expect(model.e, 303);
    expect(model.a, isTrue);
    expect(model.u, 'admin');
    expect(model.p, 'secret');
    expect(model.n, 'Administrator');
    expect(model.x, 404);
    expect(model.l, 9);
    expect(model.toJson(), <String, dynamic>{
      'i': 101,
      'd': 202,
      'e': 303,
      'a': true,
      'u': 'admin',
      'p': 'secret',
      'n': 'Administrator',
      'x': 404,
      'l': 9,
    });
  });

  test('UsrModel copyWith updates selected fields only', () {
    const model = UsrModel(
      i: 1,
      d: 2,
      e: 3,
      a: true,
      u: 'root',
      p: 'pw',
      n: 'Root',
      x: 4,
      l: 1,
    );

    final updated = model.copyWith(a: false, n: 'Updated', l: 7);

    expect(updated.i, 1);
    expect(updated.d, 2);
    expect(updated.e, 3);
    expect(updated.a, isFalse);
    expect(updated.u, 'root');
    expect(updated.p, 'pw');
    expect(updated.n, 'Updated');
    expect(updated.x, 4);
    expect(updated.l, 7);
  });
}
