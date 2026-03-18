import 'package:genrp/core/model/ux/ux_button_model.dart';
import 'package:genrp/core/model/ux/ux_checkbox_model.dart';
import 'package:genrp/core/model/ux/ux_text_box_model.dart';

class UxSpecMapper {
  const UxSpecMapper();

  UxButtonModel buttonFromNode(Map<String, dynamic> node, {int hostId = 0, int bodyId = 0}) {
    final actionValue = node['action'];
    return UxButtonModel(
      i: (node['widgetId'] as num?)?.toInt() ?? (node['i'] as num?)?.toInt() ?? 0,
      a: node['a'] as bool? ?? true,
      d: (node['d'] as num?)?.toInt() ?? 0,
      e: (node['e'] as num?)?.toInt() ?? 0,
      t: (node['t'] as num?)?.toInt() ?? 0,
      hostId: (node['hostId'] as num?)?.toInt() ?? hostId,
      bodyId: (node['bodyId'] as num?)?.toInt() ?? bodyId,
      n: node['text']?.toString() ?? node['n']?.toString() ?? '',
      s: node['s']?.toString() ?? '',
      actionId: (node['actionId'] as num?)?.toInt() ?? (actionValue is num ? actionValue.toInt() : 0),
      actionName: actionValue is String ? actionValue : '',
    );
  }

  UxTextBoxModel textBoxFromNode(Map<String, dynamic> node, {int hostId = 0, int bodyId = 0}) {
    return UxTextBoxModel(
      i: (node['widgetId'] as num?)?.toInt() ?? (node['i'] as num?)?.toInt() ?? 0,
      a: node['a'] as bool? ?? true,
      d: (node['d'] as num?)?.toInt() ?? 0,
      e: (node['e'] as num?)?.toInt() ?? 0,
      t: (node['t'] as num?)?.toInt() ?? 0,
      hostId: (node['hostId'] as num?)?.toInt() ?? hostId,
      bodyId: (node['bodyId'] as num?)?.toInt() ?? bodyId,
      n: node['label']?.toString() ?? node['n']?.toString() ?? '',
      s: node['s']?.toString() ?? '',
      bind: node['bind']?.toString() ?? '',
      src: (node['src'] as num?)?.toInt(),
      fieldId: (node['f'] as num?)?.toInt(),
    );
  }

  UxCheckBoxModel checkBoxFromNode(Map<String, dynamic> node, {int hostId = 0, int bodyId = 0}) {
    return UxCheckBoxModel(
      i: (node['widgetId'] as num?)?.toInt() ?? (node['i'] as num?)?.toInt() ?? 0,
      a: node['a'] as bool? ?? true,
      d: (node['d'] as num?)?.toInt() ?? 0,
      e: (node['e'] as num?)?.toInt() ?? 0,
      t: (node['t'] as num?)?.toInt() ?? 0,
      hostId: (node['hostId'] as num?)?.toInt() ?? hostId,
      bodyId: (node['bodyId'] as num?)?.toInt() ?? bodyId,
      n: node['label']?.toString() ?? node['n']?.toString() ?? '',
      s: node['s']?.toString() ?? '',
      bind: node['bind']?.toString() ?? '',
      src: (node['src'] as num?)?.toInt(),
      fieldId: (node['f'] as num?)?.toInt(),
    );
  }
}
