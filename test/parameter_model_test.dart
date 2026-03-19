import 'package:genrp/core/model/data/entity_model.dart';
import 'package:genrp/core/model/data/field_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genrp/core/model/data/function_model.dart';
import 'package:genrp/core/model/data/parameter_model.dart';

void main() {
  test('ParameterModel uses fi as function id and accepts legacy t JSON', () {
    final model = ParameterModel.fromJson(const <String, dynamic>{
      'i': 7,
      'a': true,
      'd': 100,
      'e': 200,
      't': 300,
      'n': 'save_param',
      's': 'legacy shape',
    });

    expect(model.fi, 300);
    expect(model.toJson(), const <String, dynamic>{
      'i': 7,
      'a': true,
      'd': 100,
      'e': 200,
      'fi': 300,
      'n': 'save_param',
      's': 'legacy shape',
    });
  });

  test('ParameterModel copyWith updates fi only when requested', () {
    const model = ParameterModel(
      i: 1,
      a: true,
      d: 2,
      e: 3,
      fi: 4,
      n: 'run',
      s: 'parameter',
    );

    final updated = model.copyWith(fi: 9, n: 'execute');

    expect(updated.i, 1);
    expect(updated.e, 3);
    expect(updated.fi, 9);
    expect(updated.n, 'execute');
    expect(updated.s, 'parameter');
  });

  test('FunctionModel keeps t as function type and uses tis for table ids', () {
    final model = FunctionModel.fromJson(const <String, dynamic>{
      'i': 9,
      'a': true,
      'd': 100,
      'e': 200,
      'ei': 15,
      't': FunctionType.jssSet,
      'tis': <int>[0, 4, 8],
      'n': 'sync_user',
      's': 'multi table',
    });

    expect(model.ei, 15);
    expect(model.t, FunctionType.jssSet);
    expect(model.tis, const <int>[0, 4, 8]);
    expect(model.toJson(), const <String, dynamic>{
      'i': 9,
      'a': true,
      'd': 100,
      'e': 200,
      'ei': 15,
      't': FunctionType.jssSet,
      'tis': <int>[0, 4, 8],
      'n': 'sync_user',
      's': 'multi table',
    });

    final updated = model.copyWith(
      ei: 20,
      t: FunctionType.bizSet,
      tis: const <int>[5],
    );
    expect(updated.ei, 20);
    expect(updated.t, FunctionType.bizSet);
    expect(updated.tis, const <int>[5]);

    final defaults = FunctionModel.fromJson(const <String, dynamic>{});
    expect(defaults.ei, 0);
    expect(defaults.t, 0);
    expect(defaults.tis, const <int>[0]);
  });

  test('FunctionType exposes the sys/jss/biz get/set vocabulary', () {
    expect(FunctionType.labelById(FunctionType.sysGet), 'sys-get');
    expect(FunctionType.labelById(FunctionType.jssSet), 'jss-set');
    expect(FunctionType.labelById(FunctionType.bizSet), 'biz-set');
    expect(FunctionType.idByLabel('SYS-SET'), FunctionType.sysSet);
    expect(FunctionType.idByLabel('jss-get'), FunctionType.jssGet);
    expect(FunctionType.idByLabel('biz-get'), FunctionType.bizGet);
    expect(FunctionType.isSystem(FunctionType.sysGet), isTrue);
    expect(FunctionType.isJss(FunctionType.jssSet), isTrue);
    expect(FunctionType.isBusiness(FunctionType.bizSet), isTrue);
    expect(FunctionType.isGetter(FunctionType.jssGet), isTrue);
    expect(FunctionType.isGetter(FunctionType.bizGet), isTrue);
    expect(FunctionType.isSetter(FunctionType.sysSet), isTrue);
    expect(FunctionType.isSetter(FunctionType.jssSet), isTrue);
  });

  test('EntityModel keeps t as entity type and uses tis for table ids', () {
    final model = EntityModel.fromJson(const <String, dynamic>{
      'i': 5,
      'a': true,
      'd': 9,
      'e': 12,
      't': 3,
      'tis': <int>[0, 7, 8],
      'n': 'Book',
      's': 'book',
    });

    expect(model.t, 3);
    expect(model.tis, const <int>[0, 7, 8]);
    expect(model.toJson(), const <String, dynamic>{
      'i': 5,
      'a': true,
      'd': 9,
      'e': 12,
      't': 3,
      'tis': <int>[0, 7, 8],
      'n': 'Book',
      's': 'book',
    });

    final updated = model.copyWith(t: 6, tis: const <int>[10]);
    expect(updated.t, 6);
    expect(updated.tis, const <int>[10]);

    final defaults = EntityModel.fromJson(const <String, dynamic>{});
    expect(defaults.t, 0);
    expect(defaults.tis, const <int>[0]);
  });

  test('FieldModel keeps t as field type and uses ci for mapped column id', () {
    final model = FieldModel.fromJson(const <String, dynamic>{
      'i': 8,
      'a': true,
      'd': 11,
      'e': 5,
      'ci': 13,
      't': 2,
      'n': 'Title',
      's': 'title',
    });

    expect(model.ci, 13);
    expect(model.t, 2);
    expect(model.toJson(), const <String, dynamic>{
      'i': 8,
      'a': true,
      'd': 11,
      'e': 5,
      'ci': 13,
      't': 2,
      'n': 'Title',
      's': 'title',
    });

    final updated = model.copyWith(ci: 21, t: 4);
    expect(updated.ci, 21);
    expect(updated.t, 4);

    final defaults = FieldModel.fromJson(const <String, dynamic>{});
    expect(defaults.ci, 0);
    expect(defaults.t, 0);
  });
}
