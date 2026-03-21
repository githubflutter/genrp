import 'package:flutter/material.dart';
import 'package:genrp/core/ux/uwidget/uwfield.dart';

class UwFieldOverlay extends StatefulWidget {
  const UwFieldOverlay({
    required this.spec,
    required this.callbacks,
    required this.controller,
    required this.isSelectMode,
    required this.isTagAddMode,
    super.key,
  });

  final UwFieldSpec spec;
  final UwFieldCallbacks callbacks;
  final TextEditingController controller;
  final bool isSelectMode;
  final bool isTagAddMode;

  @override
  State<UwFieldOverlay> createState() => _UwFieldOverlayState();
}

class _UwFieldOverlayState extends State<UwFieldOverlay> {
  final LayerLink _layerLink = LayerLink();
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  List<dynamic> _filteredItems = <dynamic>[];

  @override
  void initState() {
    super.initState();
    _filteredItems = _getAvailableItems();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _showOverlay();
      } else {
        _hideOverlay();
      }
    });
    if (!widget.isSelectMode && !widget.isTagAddMode) {
      widget.controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _hideOverlay();
    if (!widget.isSelectMode && !widget.isTagAddMode) {
      widget.controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  List<dynamic> _getAvailableItems() {
    List<dynamic> all = <dynamic>[];
    if (widget.isTagAddMode) {
      all.addAll(widget.spec.tags ?? <dynamic>[]);
    }
    all.addAll(widget.spec.items ?? <dynamic>[]);
    return all.toSet().toList(); // Quick deduplicate
  }

  void _onTextChanged() {
    final text = widget.controller.text.toLowerCase();
    setState(() {
      if (text.isEmpty) {
        _filteredItems = _getAvailableItems();
      } else {
        _filteredItems = _getAvailableItems().where((dynamic item) {
          final label = widget.spec.itemLabelBuilder?.call(item) ?? item.toString();
          return label.toLowerCase().contains(text);
        }).toList();
      }
      _overlayEntry?.markNeedsBuild();
    });
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return Positioned(
          width: size.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0.0, size.height + 5.0),
            child: Material(
              elevation: 4.0,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: _filteredItems.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = _filteredItems[index];
                    final label = widget.spec.itemLabelBuilder?.call(item) ?? item.toString();
                    return ListTile(
                      title: Text(label),
                      onTap: () {
                        widget.controller.text = label;
                        if (widget.isTagAddMode) {
                          widget.callbacks.onTagAdded?.call(item);
                        } else {
                          widget.callbacks.onChanged?.call(item);
                        }
                        _hideOverlay();
                        _focusNode.unfocus();
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          if (widget.spec.leftIcon != null || widget.spec.mode == UwFieldMode.combo || widget.spec.mode == UwFieldMode.select)
            IconButton(
              icon: Icon(widget.spec.leftIcon ?? Icons.refresh),
              tooltip: widget.spec.leftTooltip ?? 'Refresh',
              iconSize: 16,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              onPressed: widget.callbacks.onRefresh ?? widget.callbacks.onLeftPressed,
            ),
          Expanded(
            child: GestureDetector(
              onTap: widget.isSelectMode ? () {
                _focusNode.requestFocus();
                _showOverlay();
              } : null,
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                readOnly: widget.isSelectMode,
                enabled: !widget.spec.readOnly,
                decoration: InputDecoration(
                  labelText: widget.spec.label,
                  hintText: widget.spec.hint,
                  suffixIcon: IconButton(
                    icon: Icon(widget.spec.rightIcon ?? Icons.arrow_drop_down),
                    tooltip: widget.spec.rightTooltip ?? 'Show suggestions',
                    iconSize: 16,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: widget.spec.readOnly ? null : () {
                      if (_focusNode.hasFocus && _overlayEntry != null) {
                        _hideOverlay();
                        _focusNode.unfocus();
                      } else {
                        _focusNode.requestFocus();
                        _showOverlay();
                      }
                    },
                  ),
                ),
                onSubmitted: widget.isTagAddMode ? (String val) {
                  if (val.trim().isNotEmpty) {
                    widget.callbacks.onTagAdded?.call(val.trim());
                  }
                } : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
