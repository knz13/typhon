import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:typhon/config/colors.dart';
import 'package:typhon/general_widgets.dart';
import 'package:typhon/general_widgets/arrow_up.dart';
import 'package:typhon/general_widgets/half_square.dart';
import 'package:typhon/general_widgets/horizontal_line.dart';
import 'package:typhon/general_widgets/rotating_arrow_button.dart';
import 'package:typhon/general_widgets/spacings.dart';
import 'package:typhon/general_widgets/t_line.dart';
import 'package:typhon/general_widgets/vertical_line.dart';

import 'custom_expansion_tile.dart';

abstract class HierarchyWidgetData<T extends HierarchyWidgetData<T>> {
  HierarchyWidgetData({this.isOpen = true, this.id = ""});

  String id;
  bool isOpen;
  List<T> _children = [];

  List<T> get children => _children;

  set children(List<T> value) {
    for (var element in value) {
      element.parent = this as T;
    }
    _children = value;
  }

  T? _parent;

  T? get parent => _parent;

  set parent(T? value) {
    if (_parent != null && value != _parent) {
      _parent!._children.remove(this);
    }
    if (value != null) {
      value.children.add(this as T);
    }

    _parent = value;
  }

  String getDraggingJSON();
}

void fillOldHierarchyMap<T extends HierarchyWidgetData<T>>(
    List<T> data, Map<String, T> map) {
  for (var child in data) {
    map[child.id] = child;
    fillOldHierarchyMap<T>(child.children, map);
  }
}

void updateNewHierarchyMap<T extends HierarchyWidgetData<T>>(
    List<T> data, Map<String, T> map) {
  for (var child in data) {
    if (map.containsKey(child.id)) {
      child.isOpen = map[child.id]!.isOpen;
    }
    map[child.id] = child;
    updateNewHierarchyMap(child.children, map);
  }
}

void updateOpenedHierarchyWidgetData<T extends HierarchyWidgetData<T>>(
    List<T> oldValue, List<T> newValue) {
  Map<String, T> map = {};
  fillOldHierarchyMap<T>(oldValue, map);
  updateNewHierarchyMap(newValue, map);
  oldValue.clear();
  for (var element in newValue) {
    oldValue.add(element);
  }
}

class HierarchyWidgetWhenDragging extends StatefulWidget {
  HierarchyWidgetWhenDragging({super.key});

  @override
  State<HierarchyWidgetWhenDragging> createState() =>
      _HierarchyWidgetWhenDraggingState();
}

class _HierarchyWidgetWhenDraggingState
    extends State<HierarchyWidgetWhenDragging> {
  Widget displayWidget = Container();

  void updateDisplayWidget(Widget myWidget) {
    setState(() {
      displayWidget = myWidget;
    });
  }

  @override
  Widget build(BuildContext context) {
    return displayWidget;
  }
}

class HierarchyWidgetController<T extends HierarchyWidgetData<T>> {
  HierarchyWidgetController(this._objects);

  List<T> _objects;
  ValueNotifier<String?> _idToHighlight = ValueNotifier(null);

  List<T> get objects => _objects;

  set objects(List<T> value) {
    updateOpenedHierarchyWidgetData(_objects, value);
  }

  T? _findObjectWithIDInChildren(T current, String id) {
    if (current.id == id) {
      return current;
    }
    for (var element in current._children) {
      T? obj = _findObjectWithIDInChildren(element, id);
      if (obj != null) {
        return obj;
      }
    }
    return null;
  }

  bool highlightObjectWithID(String id) {
    T? obj;
    for (var element in _objects) {
      obj = _findObjectWithIDInChildren(element, id);
      if (obj != null) {
        _idToHighlight.value = obj.id;
        return true;
      }
    }
    return false;
  }

  void hightlightObject(T obj) {
    _idToHighlight.value = obj.id;
  }

  void disableHightlight() {
    _idToHighlight.value = null;
  }
}

class HierarchyWidget<T extends HierarchyWidgetData<T>> extends StatefulWidget {
  static double initialSpacing = 0;
  static double iconSize = 16;

  HierarchyWidget(
      {super.key,
      required this.controller,
      required this.onClick,
      required this.childBasedOnID,
      required this.feedbackBasedOnID,
      this.onWillAcceptDrag,
      this.onAccept,
      this.highlightColor = Colors.lightBlue,
      this.selectedColor = Colors.blue,
      this.spacingAddedBeforeChildren = 16});

  HierarchyWidgetController<T> controller;
  double spacingAddedBeforeChildren;
  void Function(T) onClick;
  bool Function(Object?, T)? onWillAcceptDrag;
  Widget Function(T) childBasedOnID;
  Widget Function(T) feedbackBasedOnID;
  void Function(Object?, T)? onAccept;
  Color highlightColor;
  Color selectedColor;

  @override
  State<HierarchyWidget<T>> createState() => _HierarchyWidgetState<T>();
}

class _HierarchyWidgetState<T extends HierarchyWidgetData<T>>
    extends State<HierarchyWidget<T>> {
  bool mouseInside = false;
  bool dragging = false;
  String? idHovered;
  final GlobalKey _draggableKey = GlobalKey();

  void rebuild() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    widget.controller._idToHighlight.addListener(rebuild);
  }

  @override
  void dispose() {
    super.dispose();

    widget.controller._idToHighlight.removeListener(rebuild);
  }

  List<Widget> _buildTree(T node, int level) {
    return [
      Row(
        children: [
          SizedBox(
            width: HierarchyWidget.initialSpacing,
          ),
          for (var i in List.generate(level, (index) => index))
            Container(
                width: widget.spacingAddedBeforeChildren,
                child: VerticalLine(
                  size: widget.spacingAddedBeforeChildren,
                  color: platinumGray,
                )),
          Container(
              width: widget.spacingAddedBeforeChildren,
              child: TLine(
                size: widget.spacingAddedBeforeChildren,
                color: platinumGray,
              )),
          DragTarget(
              onWillAccept: (data) {
                return widget.onWillAcceptDrag?.call(data, node) ?? false;
              },
              onAccept: (data) {
                widget.onAccept?.call(data, node);
              },
              builder: (context, candidateData, rejectedData) => Draggable(
                  data: node.getDraggingJSON(),
                  feedback: Material(
                      child: HierarchyWidgetWhenDragging(key: _draggableKey)),
                  onDragEnd: (details) {
                    setState(() {
                      dragging = false;
                    });
                    if (mouseInside) {
                      setState(() {
                        widget.controller.highlightObjectWithID(node.id);
                      });
                      widget.onClick(node);
                    }
                  },
                  onDragStarted: () {
                    setState(() {
                      dragging = true;
                    });
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (event) {
                      setState(() {
                        idHovered = node.id;
                        mouseInside = true;
                      });
                      if (dragging) {
                        (_draggableKey.currentState
                                as _HierarchyWidgetWhenDraggingState)
                            .updateDisplayWidget(Container());
                      }
                    },
                    onExit: (event) {
                      setState(() {
                        idHovered = null;
                        mouseInside = false;
                      });
                      if (dragging) {
                        (_draggableKey.currentState
                                as _HierarchyWidgetWhenDraggingState)
                            .updateDisplayWidget(
                                widget.feedbackBasedOnID(node));
                      }
                    },
                    child: Row(
                      children: [
                        if (node.children.isNotEmpty)
                          RotatingArrowButton(
                            key: Key(node.id),
                            onTap: () {
                              setState(() {
                                node.isOpen = !node.isOpen;
                              });
                            },
                            value: node.isOpen,
                            size: widget.spacingAddedBeforeChildren,
                          )
                        else
                          Container(
                              width: widget.spacingAddedBeforeChildren,
                              child: HorizontalLine(
                                size: widget.spacingAddedBeforeChildren,
                                color: platinumGray,
                              )),
                        Container(
                            color: widget.controller._idToHighlight.value ==
                                    node.id
                                ? widget.selectedColor
                                : (idHovered == node.id
                                    ? widget.highlightColor
                                    : null),
                            child: widget.childBasedOnID(node)),
                      ],
                    ),
                  ))),
        ],
      ),
      if (node.isOpen)
        ...node.children
            .expand((child) => _buildTree(child as T, level + 1))
            .toList()
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: IntrinsicWidth(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.controller.objects
                .expand((node) => _buildTree(node as T, 0))
                .toList(),
          ),
        ),
      ),
    );
  }
}
