




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



class HierarchyScrollableTreeView extends StatelessWidget {
  final List<ObjectFromCPP> rootObjects;
  final double levelPadding;

  const HierarchyScrollableTreeView({Key? key, required this.rootObjects, this.levelPadding = 16.0}) : super(key: key);

  List<Widget> _buildTree(ObjectFromCPP node, int level) {
    return [
      Padding(
        padding: EdgeInsets.only(left: level * levelPadding),
        child: CustomExpansionTile(
          title: Text(node.name),
          children: node.children.expand((child) => _buildTree(child, level + 1)).toList(),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: IntrinsicWidth(
        child: SingleChildScrollView(
          child: Column(
            children: rootObjects.expand((node) => _buildTree(node, 0)).toList(),
          ),
        ),
      ),
    );
  }
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
    required this.rootObjects,
    required this.onClick,
    required this.childBasedOnID,
    required this.feedbackBasedOnID,
    this.onWillAcceptDrag,
    this.onAccept,
    this.spacingAddedBeforeChildren = 16
  });


  double spacingAddedBeforeChildren;
  final List<ObjectFromCPP> rootObjects;
  void Function(ObjectFromCPP) onClick;
  bool Function(Object?,ObjectFromCPP)? onWillAcceptDrag;
  Widget Function(ObjectFromCPP) childBasedOnID;
  Widget Function(ObjectFromCPP) feedbackBasedOnID;
  void Function(Object?,ObjectFromCPP)? onAccept;

  @override
  State<HierarchyWidget> createState() => _HierarchyWidgetState();
}

class _HierarchyWidgetState extends State<HierarchyWidget> {
  bool mouseInside = false;
  bool dragging = false;
  final GlobalKey _draggableKey = GlobalKey();

  Widget _buildTree(ObjectFromCPP node, int level) {
    print(node.children.map((child) => _buildTree(child, level + 1)).toList());
    return 
      Padding(
        padding: EdgeInsets.only(left: level * widget.spacingAddedBeforeChildren),
        child: DragTarget(
          onWillAccept:(data) {
            return widget.onWillAcceptDrag?.call(data,node) ?? false;
          },
          onAccept: (data) {
            widget.onAccept?.call(data,node);
          },
          builder:(context, candidateData, rejectedData) => Draggable(
            data: '{"type":"cpp_object","id":${node.id}}',
            feedback: Material(child: HierarchyWidgetWhenDragging(key: _draggableKey)),
            onDragEnd: (details) {
              setState(() {
                dragging = false;
              });
              if(mouseInside){
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
                  (_draggableKey.currentState as _HierarchyWidgetWhenDraggingState).updateDisplayWidget(widget.feedbackBasedOnID(node));
                }
              },
              child: CustomExpansionTile(
                title: Container(
                  child: widget.childBasedOnID(node)
                ),
                children: node.children.map((child) => _buildTree(child, level + 1)).toList(),
              )
            )
          )
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: IntrinsicWidth(
        child: SingleChildScrollView(
          child: Column(
            children: widget.rootObjects.map((node) => _buildTree(node, 0)).toList(),
          ),
        ),
      ),
    );
  }

  
    
    
}