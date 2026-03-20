import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:genrp/core/base/x.dart';
import 'package:genrp/core/model/uschema/ux_document_spec.dart';

class MockTransport {
  static Future<Map<String, dynamic>> fetchSpec() async {
    final specRaw = await rootBundle.loadString('assets/json/aibook_spec.json');
    final registryRaw = await rootBundle.loadString(
      'assets/json/aibook_registry.json',
    );
    final spec = Map<String, dynamic>.from(jsonDecode(specRaw) as Map);
    final registry = Map<String, dynamic>.from(jsonDecode(registryRaw) as Map);
    return {...spec, 'registry': registry};
  }

  static Future<UxSpecDocument> fetchSpecDocument() async {
    final spec = await fetchSpec();
    return UxSpecDocument.fromJson(spec);
  }

  static Future<X> saveRow(X row) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    // Return a patched version simulating a backend save response
    // For simplicity we just return a new instance with the same values.
    return X(v: List.from(row.v));
  }
}
