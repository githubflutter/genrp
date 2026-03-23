import 'dart:async';
import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/ux/mixins.dart';
import 'package:genrp/core/ux/uwidget/uwfield.dart';

/// File information for [UwFieldFile].
class UwFieldFileItem {
  const UwFieldFileItem({required this.name, required this.path, this.size, this.mimeType});

  final String name;
  final String path;
  final int? size;
  final String? mimeType;

  String get formattedSize {
    final s = size;
    if (s == null) return '';
    if (s < 1024) return '$s B';
    if (s < 1024 * 1024) return '${(s / 1024).toStringAsFixed(1)} KB';
    if (s < 1024 * 1024 * 1024) return '${(s / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(s / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// Dedicated file picker field widget.
///
/// Supports single file, multiple files, or file path input.
/// Value is stored as `String` (path) or `List<String>` (paths).
///
/// Use this directly for better performance, or use [UwField] with
/// [UwFieldMode.file] for mode-dispatched convenience.
class UwFieldFile extends StatefulWidget with Ux {
  const UwFieldFile({required this.i, required this.autopilot, required this.spec, this.callbacks = const UwFieldCallbacks(), this.s = 0, super.key});

  final int uwid = 14;
  final int s;
  @override
  final int i;
  @override
  final String n = 'field_file';

  final Autopilot autopilot;
  final UwFieldFileSpec spec;
  final UwFieldCallbacks callbacks;

  @override
  State<UwFieldFile> createState() => _UwFieldFileState();
}

class _UwFieldFileState extends State<UwFieldFile> {
  List<UwFieldFileItem> _selectedFiles = [];

  @override
  void initState() {
    super.initState();
    _syncFiles();
  }

  @override
  void didUpdateWidget(covariant UwFieldFile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.spec.value != oldWidget.spec.value) {
      _syncFiles();
    }
  }

  void _syncFiles() {
    final value = widget.spec.value;
    if (value == null) {
      _selectedFiles = [];
      return;
    }

    if (value is String) {
      _selectedFiles = [UwFieldFileItem(name: _extractFileName(value), path: value)];
    } else if (value is List) {
      _selectedFiles = value.map((e) {
        if (e is String) {
          return UwFieldFileItem(name: _extractFileName(e), path: e);
        } else if (e is UwFieldFileItem) {
          return e;
        }
        return UwFieldFileItem(name: e.toString(), path: e.toString());
      }).toList();
    }
  }

  String _extractFileName(String path) {
    return path.split('/').last.split('\\').last;
  }

  Future<void> _pickFile() async {
    // Simulated file picker - in real app, use file_picker package
    // For now, show a dialog to enter file path
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick File'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'File path',
              hintText: '/path/to/file',
              suffixIcon: IconButton(
                icon: const Icon(Icons.folder_open),
                tooltip: 'Browse',
                onPressed: () {
                  // TODO: Integrate with file_picker package
                  // final result = await FilePicker.platform.pickFiles();
                  // if (result != null) {
                  //   Navigator.of(context).pop(result.files.single.path);
                  // }
                },
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(null), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.of(context).pop(controller.text), child: const Text('OK')),
          ],
        );
      },
    );

    if (result == null || result.isEmpty) return;

    if (widget.spec.allowMultiple) {
      final newFile = UwFieldFileItem(name: _extractFileName(result), path: result);
      _selectedFiles.add(newFile);
      widget.callbacks.onChanged?.call(_selectedFiles.map((f) => f.path).toList());
    } else {
      _selectedFiles = [UwFieldFileItem(name: _extractFileName(result), path: result)];
      widget.callbacks.onChanged?.call(result);
    }
    setState(() {});
  }

  void _removeFile(int index) {
    _selectedFiles.removeAt(index);
    if (widget.spec.allowMultiple) {
      widget.callbacks.onChanged?.call(_selectedFiles.map((f) => f.path).toList());
    } else {
      widget.callbacks.onChanged?.call(null);
      if (_selectedFiles.isNotEmpty) {
        _selectedFiles = [_selectedFiles.first];
      }
    }
    setState(() {});
  }

  void _clearFiles() {
    _selectedFiles = [];
    widget.callbacks.onChanged?.call(widget.spec.allowMultiple ? [] : null);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget fieldBody = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        if (widget.spec.leftIcon != null)
          IconButton(
            icon: Icon(widget.spec.leftIcon),
            tooltip: widget.spec.leftTooltip,
            iconSize: 16,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: widget.callbacks.onLeftPressed,
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.spec.label != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(widget.spec.label!, style: Theme.of(context).textTheme.bodySmall),
                ),
              if (_selectedFiles.isEmpty)
                GestureDetector(
                  onTap: widget.spec.readOnly ? null : _pickFile,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload_file, color: Colors.grey[400]),
                        const SizedBox(width: 8),
                        Text(widget.spec.hint ?? 'Tap to select file', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 150),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _selectedFiles.length,
                    itemBuilder: (context, index) {
                      final file = _selectedFiles[index];
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.insert_drive_file),
                        title: Text(file.name, overflow: TextOverflow.ellipsis),
                        subtitle: file.size != null ? Text(file.formattedSize) : null,
                        trailing: widget.spec.readOnly ? null : IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => _removeFile(index)),
                        onTap: widget.spec.readOnly ? null : () => _removeFile(index),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
        if (_selectedFiles.isNotEmpty && !widget.spec.readOnly)
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear all',
            iconSize: 16,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: _clearFiles,
          )
        else if (!widget.spec.readOnly)
          IconButton(
            icon: Icon(widget.spec.rightIcon ?? Icons.folder_open),
            tooltip: widget.spec.rightTooltip ?? 'Browse',
            iconSize: 16,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: _pickFile,
          ),
      ],
    );

    if (widget.spec.width != null) {
      fieldBody = SizedBox(width: widget.spec.width, child: fieldBody);
    }
    return fieldBody;
  }
}

/// Spec for [UwFieldFile].
class UwFieldFileSpec {
  const UwFieldFileSpec({
    this.label,
    this.hint,
    this.width,
    this.value,
    this.readOnly = false,
    this.allowMultiple = false,
    this.allowedExtensions,
    this.maxFileSize,
    this.leftIcon,
    this.leftTooltip,
    this.rightIcon,
    this.rightTooltip,
  });

  final String? label;
  final String? hint;
  final double? width;
  final dynamic value; // String or List<String>
  final bool readOnly;
  final bool allowMultiple;
  final List<String>? allowedExtensions;
  final int? maxFileSize;
  final IconData? leftIcon;
  final String? leftTooltip;
  final IconData? rightIcon;
  final String? rightTooltip;
}
