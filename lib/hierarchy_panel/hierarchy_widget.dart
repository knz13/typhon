




import 'package:flutter/material.dart';
import 'package:typhon/config/colors.dart';
import 'package:typhon/general_widgets.dart';
import 'package:typhon/general_widgets/spacings.dart';

import '../general_widgets/custom_expansion_tile.dart';

class ObjectFromCPP {

  ObjectFromCPP({required this.id,this.name = ""});

  int id;
  String name;
  List<ObjectFromCPP> children = [];
}

class HierarchyWidgetWhenDragging extends StatefulWidget {


  HierarchyWidgetWhenDragging({super.key});

  @override
  State<HierarchyWidgetWhenDragging> createState() => _HierarchyWidgetWhenDraggingState();
}

class _HierarchyWidgetWhenDraggingState extends State<HierarchyWidgetWhenDragging> {
  Widget displayWidget = Container();

  void updateDisplayWidget(Widget myWidget) {
    setState(() {
      displayWidget = myWidget;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return displayWidget;
  }
}

class HierarchyWidget extends StatefulWidget{
  HierarchyWidget({
    super.key,
    required this.objectData,
    required this.onClick,
    required this.onDragEnd,
    required this.childBasedOnID,
    required this.feedbackBasedOnID,
    this.spacingAddedBeforeChildren = 0
  });


  double spacingAddedBeforeChildren;
  ObjectFromCPP objectData;
  void Function(ObjectFromCPP) onClick;
  void Function(DraggableDetails?,ObjectFromCPP) onDragEnd;
  Widget Function(ObjectFromCPP) childBasedOnID;
  Widget Function(ObjectFromCPP) feedbackBasedOnID;

  @override
  State<HierarchyWidget> createState() => _HierarchyWidgetState();
}

class _HierarchyWidgetState extends State<HierarchyWidget> {
  bool mouseInside = false;
  bool dragging = false;
  final GlobalKey _draggableKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Draggable(
      feedback: Material(child: HierarchyWidgetWhenDragging(key: _draggableKey)),
      onDragEnd: (details) {
        setState(() {
          dragging = false;
        });
        if(mouseInside){
          widget.onClick(widget.objectData);
        }
        else {
          widget.onDragEnd(details,widget.objectData);
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
            mouseInside = true;
          });
          if(dragging){
            (_draggableKey.currentState as _HierarchyWidgetWhenDraggingState).updateDisplayWidget(Container());
          }
        },
        onExit: (event) {
          setState(() {
            mouseInside = false;
          });
          if(dragging) {
            (_draggableKey.currentState as _HierarchyWidgetWhenDraggingState).updateDisplayWidget(widget.feedbackBasedOnID(widget.objectData));
          }
        },
        child: CustomExpansionTile(
          title: Container(
            width: double.infinity,
            child: widget.childBasedOnID(widget.objectData)
          ),
          children: widget.objectData.children.map((e) => Row(
            children: [
              SizedBox(
                width: widget.spacingAddedBeforeChildren,
              ),
              HierarchyWidget(
                objectData: e,
                onClick: widget.onClick,
                onDragEnd: widget.onDragEnd,
                spacingAddedBeforeChildren: widget.spacingAddedBeforeChildren,
                childBasedOnID: widget.childBasedOnID,
                feedbackBasedOnID: widget.feedbackBasedOnID,
              ),
            ],
          )).toList(),
        )
      ),
    );
    
    
    
  }
}