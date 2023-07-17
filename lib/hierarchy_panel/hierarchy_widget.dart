




import 'package:flutter/material.dart';
import 'package:typhon/config/colors.dart';
import 'package:typhon/general_widgets.dart';
import 'package:typhon/general_widgets/arrow_up.dart';
import 'package:typhon/general_widgets/half_square.dart';
import 'package:typhon/general_widgets/horizontal_line.dart';
import 'package:typhon/general_widgets/spacings.dart';
import 'package:typhon/general_widgets/t_line.dart';
import 'package:typhon/general_widgets/vertical_line.dart';

import '../general_widgets/custom_expansion_tile.dart';




class ObjectFromCPP {

  ObjectFromCPP({required this.id,this.name = "",this.isOpen = true});

  bool isOpen;
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

  static double initialSpacing = 0;
  static double iconSize = 16;

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

  List<Widget> _buildTree(ObjectFromCPP node, int level) {
   
    return [
      Row(children: [
        SizedBox(
          width: HierarchyWidget.initialSpacing,
        ),
        for(var i in List.generate(level, (index) => index))
        Container(
          width: widget.spacingAddedBeforeChildren,
          child: VerticalLine(size: widget.spacingAddedBeforeChildren,color: platinumGray,)
        ),
        Container(
          width: widget.spacingAddedBeforeChildren,
          child: TLine(size: widget.spacingAddedBeforeChildren,color: platinumGray,)
        ),
        DragTarget(
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
              child: Row(
                children: [
                  if(node.children.isNotEmpty)
                  InkWell(
                    onTap: (){
                      setState(() {
                        node.isOpen = !node.isOpen;
                      });
                    },
                    child: AnimatedRotation(
                      duration: Duration(milliseconds: 200),
                      turns: node.isOpen? 0.5 : 0.25,
                      child: ArrowUp(size: widget.spacingAddedBeforeChildren,color: platinumGray,)
                    ),
                  )
                  else 
                  Container(
                    width: widget.spacingAddedBeforeChildren,
                    child: HorizontalLine(size: widget.spacingAddedBeforeChildren,color: platinumGray,)
                  ),
                  Container(
                    child: widget.childBasedOnID(node)
                  ),
                ],
              ),
              )
            )
          ),
        ],
      ),
        if(node.isOpen)
        ...node.children.expand((child) => _buildTree(child, level + 1)).toList()
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
            children: widget.rootObjects.expand((node) => _buildTree(node, 0)).toList(),
          ),
        ),
      ),
    );
  }

  
    
    
}