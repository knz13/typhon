



import 'package:flutter/material.dart';
import 'package:typhon/engine.dart';
import 'package:typhon/main.dart';



enum SubWindowDivision {
  left,
  right,
  top,
  bottom
}


class EngineSubWindow extends StatefulWidget {

  Widget mainChild;
  String? mainChildTitle;
  Widget? secondChild;
  String? secondChildTitle;
  SubWindowDivision division;
  double mainChildProportion;
  bool shouldShowBorder;
  double proportionAllowedRange;
  static double titleHeight = 20;
  static double subWindowBorderWidth = 5;



  EngineSubWindow(
    {
      super.key,
      required this.mainChild,
      this.mainChildTitle,
      this.secondChild,
      this.secondChildTitle,
      this.division = SubWindowDivision.top,
      this.mainChildProportion = 0.5,
      this.shouldShowBorder = true,
      this.proportionAllowedRange = 0.8,
    }
  );

  @override
  State<EngineSubWindow> createState() => _EngineSubWindowState();
}





class _EngineSubWindowState extends State<EngineSubWindow> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Widget build(BuildContext context) {
    
    Widget mainChildWidget = widget.mainChild.runtimeType == EngineSubWindow? widget.mainChild : Column(
      children: [
        Container(
          height: EngineSubWindow.titleHeight,
          color: Colors.blue,
          child: Center(
            child: Text(
              widget.mainChildTitle ?? ""
            ),
          ),
        ),
        Expanded(child: widget.mainChild)
      ],
    );

    if(widget.secondChild == null) {
      return mainChildWidget;
    }

    mainChildWidget = SizedBox(
      width: widget.division == SubWindowDivision.left || widget.division == SubWindowDivision.right ? MediaQuery.of(context).size.width * (widget.mainChildProportion) : null,
      height: widget.division == SubWindowDivision.top || widget.division == SubWindowDivision.bottom? MediaQuery.of(context).size.height * (widget.mainChildProportion) : null,
      child: mainChildWidget 
    );

    Widget secondChildWidget = widget.secondChild!.runtimeType == EngineSubWindow? widget.secondChild! :SizedBox(
      width: widget.division == SubWindowDivision.left || widget.division == SubWindowDivision.right ? MediaQuery.of(context).size.width * (1 - widget.mainChildProportion) : null,
      height: widget.division == SubWindowDivision.top || widget.division == SubWindowDivision.bottom? MediaQuery.of(context).size.height * (1- widget.mainChildProportion) : null,
      child: Column(
        children: [
          //title
          Container(
            height: EngineSubWindow.titleHeight,
            color: Colors.blue,
            child: Center(
              child: Text(
                widget.secondChildTitle ?? "",
              ),
            )
          ),
          Expanded(child: widget.secondChild!)
        ],
      ),
    );
    
    
    //mainChildWidget = mainChildWidget.runtimeType == EngineSubWindow? mainChildWidget : EngineSubWindow(mainChild: mainChildWidget,mainChildTitle: widget.mainChildTitle,);
    //secondChildWidget = secondChildWidget.runtimeType == EngineSubWindow? secondChildWidget : EngineSubWindow(mainChild: secondChildWidget,mainChildTitle: widget.secondChildTitle,);
    
    return widget.division == SubWindowDivision.top || widget.division == SubWindowDivision.bottom? 
    Column(
      children: widget.division == SubWindowDivision.top? 
      [
        Expanded(
          flex: ((widget.mainChildProportion)* 100).toInt(),
          child: mainChildWidget
        ),
        Draggable(
          onDragUpdate: (details) {
            double delta = details.localPosition.dy/MediaQuery.of(context).size.height;
            if(delta > (1 - widget.proportionAllowedRange)/2 && delta < widget.proportionAllowedRange + (1 - widget.proportionAllowedRange)/2){
              setState(() {
                widget.mainChildProportion = delta;
              });
            }
          },
          feedback: Container(),
          child: MouseRegion(
            cursor:SystemMouseCursors.resizeUpDown,
            child: Container(
              color: Colors.black45,
              height: EngineSubWindow.subWindowBorderWidth,
            ),
          ),
        ),
        Expanded(
          flex:((1-(widget.mainChildProportion))* 100).toInt(),
          child: secondChildWidget
        )
      ] 
      :
      [
        Expanded(
          flex:((1-(widget.mainChildProportion - 1))* 100).toInt(),
          child: secondChildWidget
        ),
        Draggable(
          onDragUpdate: (details) {
            double delta = details.localPosition.dy/MediaQuery.of(context).size.height;
            if(delta > (1 - widget.proportionAllowedRange)/2 && delta < widget.proportionAllowedRange + (1 - widget.proportionAllowedRange)/2){
              setState(() {
                widget.mainChildProportion = 1 - delta;
              });
            }
          },
          feedback: Container(),
          child: MouseRegion(
            cursor:SystemMouseCursors.resizeUpDown,
            child: Container(
              color: Colors.black45,
              height: EngineSubWindow.subWindowBorderWidth,
            ),
          ),
        ),
        Expanded(
          flex: ((widget.mainChildProportion - 1)* 100).toInt(),
          child: mainChildWidget
        )
      ]
    ) 
    :
    Row(
      children: widget.division == SubWindowDivision.left?
      [
        Expanded(
          flex: ((widget.mainChildProportion - 1)* 100).toInt(),
          child: mainChildWidget
        ),
        Draggable(
          feedback: Container(),
          onDragUpdate: (details) {
            double delta = details.localPosition.dx/MediaQuery.of(context).size.width;
            if(delta > (1 - widget.proportionAllowedRange)/2 && delta < widget.proportionAllowedRange + (1 - widget.proportionAllowedRange)/2){
              setState(() {
                widget.mainChildProportion = delta;
              });
            }
          },
          child: MouseRegion(
            cursor:SystemMouseCursors.resizeLeftRight,
            child: Container(
              color: Colors.black45,
              width: EngineSubWindow.subWindowBorderWidth,
            ),
          ),
        ),
        Expanded(
          flex:((1-(widget.mainChildProportion - 1))* 100).toInt(),
          child: secondChildWidget
        )
      ] 
      :
      [
        Expanded(
          flex:((1-(widget.mainChildProportion - 1))* 100).toInt(),
          child: secondChildWidget
        ),
        Draggable(
          onDragUpdate: (details) {
            double delta = details.localPosition.dx/MediaQuery.of(context).size.width;
            if(delta > (1 - widget.proportionAllowedRange)/2 && delta < widget.proportionAllowedRange + (1 - widget.proportionAllowedRange)/2){
              setState(() {
                widget.mainChildProportion = 1- delta;
              });
            }
          },
          feedback: Container(),
          child: MouseRegion(
            cursor:SystemMouseCursors.resizeLeftRight,
            child: Container(
              color: Colors.black45,
              width: EngineSubWindow.subWindowBorderWidth,
            ),
          ),
        ),
        Expanded(
          flex: ((widget.mainChildProportion - 1)* 100).toInt(),
          child: mainChildWidget
        )
      ]
    );
  }
}