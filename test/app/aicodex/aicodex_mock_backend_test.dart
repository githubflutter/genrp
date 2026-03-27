import 'package:flutter_test/flutter_test.dart';
import 'package:genrp/app/aicodex/aicodex_mock_backend.dart';
import 'package:genrp/core/model/bschema/function_model.dart';

void main() {
  group('AICodexMockBackend', () {
    test('entity catalog supports create update delete', () {
      final backend = AICodexMockBackend();

      final initialCount = backend.countFor('Entity');
      final id = backend.createRecord('Entity', <String, Object?>{
        'a': true,
        'e': 7,
        't': 44,
        'tis': <int>[3, 5, 8],
        'n': 'Invoice',
        's': '',
      });

      expect(backend.countFor('Entity'), initialCount + 1);

      final created = backend.recordFor('Entity', id);
      expect(created, isNotNull);
      expect(created?['n'], 'Invoice');
      expect(created?['s'], 'invoice');
      expect(created?['tis'], <int>[3, 5, 8]);

      backend.updateRecord('Entity', id, <String, Object?>{
        'a': false,
        'e': 9,
        't': 55,
        'tis': <int>[13],
        'n': 'Invoice Archive',
        's': 'invoice-archive',
      });

      final updated = backend.recordFor('Entity', id);
      expect(updated, isNotNull);
      expect(updated?['a'], false);
      expect(updated?['e'], 9);
      expect(updated?['t'], 55);
      expect(updated?['tis'], <int>[13]);
      expect(updated?['n'], 'Invoice Archive');
      expect(updated?['s'], 'invoice-archive');

      backend.deleteRecord('Entity', id);

      expect(backend.countFor('Entity'), initialCount);
      expect(backend.recordFor('Entity', id), isNull);
    });

    test('function catalog persists function type and linked ids', () {
      final backend = AICodexMockBackend();

      final id = backend.createRecord('Function', <String, Object?>{
        'a': true,
        'e': 4,
        'ei': 9,
        't': FunctionType.bizSet,
        'tis': <int>[10, 11],
        'n': 'sync_invoice',
        's': '',
      });

      final created = backend.recordFor('Function', id);
      expect(created, isNotNull);
      expect(created?['ei'], 9);
      expect(created?['t'], FunctionType.bizSet);
      expect(created?['tis'], <int>[10, 11]);
      expect(created?['s'], 'sync-invoice');
    });
  });
}
