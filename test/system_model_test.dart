import 'package:genrp/core/base/bootstrap.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genrp/core/model/base/system_model.dart';

void main() {
  test('SystemModel round-trips structural metadata fields', () {
    final model = SystemModel.fromJson(const <String, dynamic>{
      'sid': 10,
      'n': 'genrp',
      'fv': 2,
      'cv': 3,
      'ld': 1000,
      'lds': 2000,
      'ldu': 3000,
      'ctm': <String, dynamic>{'entity': 'Entity'},
      'uxm': <String, dynamic>{'widget': 'Widget'},
      'm1': <String, dynamic>{'future': 1},
      'm2': <String, dynamic>{'extra': true},
    });

    expect(model.sid, 10);
    expect(model.n, 'genrp');
    expect(model.fv, 2);
    expect(model.cv, 3);
    expect(model.ld, 1000);
    expect(model.lds, 2000);
    expect(model.ldu, 3000);
    expect(model.ctm, <String, dynamic>{'entity': 'Entity'});
    expect(model.uxm, <String, dynamic>{'widget': 'Widget'});
    expect(model.m1, <String, dynamic>{'future': 1});
    expect(model.m2, <String, dynamic>{'extra': true});

    expect(model.toJson(), const <String, dynamic>{
      'sid': 10,
      'n': 'genrp',
      'fv': 2,
      'cv': 3,
      'ld': 1000,
      'lds': 2000,
      'ldu': 3000,
      'ctm': <String, dynamic>{'entity': 'Entity'},
      'uxm': <String, dynamic>{'widget': 'Widget'},
      'm1': <String, dynamic>{'future': 1},
      'm2': <String, dynamic>{'extra': true},
    });
  });

  test('SystemModel copyWith updates selected fields only', () {
    const model = SystemModel(
      sid: 1,
      n: 'genrp',
      fv: 1,
      cv: 1,
      ld: 10,
      lds: 20,
      ldu: 30,
      ctm: <String, dynamic>{'entity': 'Entity'},
      uxm: <String, dynamic>{'host': 'Host'},
      m1: <String, dynamic>{},
      m2: <String, dynamic>{},
    );

    final updated = model.copyWith(
      n: 'genrp-next',
      cv: 2,
      lds: 99,
      uxm: <String, dynamic>{'host': 'Host', 'body': 'Body'},
    );

    expect(updated.sid, 1);
    expect(updated.n, 'genrp-next');
    expect(updated.fv, 1);
    expect(updated.cv, 2);
    expect(updated.ld, 10);
    expect(updated.lds, 99);
    expect(updated.ldu, 30);
    expect(updated.ctm, <String, dynamic>{'entity': 'Entity'});
    expect(updated.uxm, <String, dynamic>{'host': 'Host', 'body': 'Body'});
  });

  test('SystemDefaults builds seed row and update helper', () {
    final seed = SystemDefaults.seedCatalogRow();
    expect(seed.catalog, 'System');
    expect(seed.i, 1);
    expect(seed.s, SystemDefaults.systemName);
    expect(seed.payload['sid'], 1);
    expect(seed.payload['ctm'], containsPair('entity', 'Entity'));
    expect(seed.payload['uxm'], containsPair('widget', 'Widget'));

    final model = SystemDefaults.fromPayload(
      Map<String, dynamic>.from(seed.payload),
    );
    final updated = SystemDefaults.update(
      model,
      n: 'Next',
      m1: <String, dynamic>{'feature': 'alpha'},
      touchEditedAt: true,
    );

    expect(updated.n, 'Next');
    expect(updated.m1, <String, dynamic>{'feature': 'alpha'});
    expect(updated.ctm, containsPair('entity', 'Entity'));
    expect(updated.ld, greaterThan(0));
    expect(updated.ldu, greaterThan(0));
  });
}
