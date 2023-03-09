



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
  double titleHeightPercentage;



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
      this.titleHeightPercentage = 0.03
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
        Expanded(
          flex: ((widget.titleHeightPercentage)*100).toInt(),
          child: Container(
            color: Colors.blue,
            child: Center(
              child: Text(
                widget.mainChildTitle ?? ""
              ),
            ),
          ),
        ),
        Expanded(
          flex: ((1 - widget.titleHeightPercentage) * 100).toInt(),
          child: widget.mainChild
        )
      ],
    );

    if(widget.secondChild == null) {
      return mainChildWidget;
    }

    Widget secondChildWidget = widget.secondChild!.runtimeType == EngineSubWindow? widget.secondChild! :Column(
      children: [
        //title
        Expanded(
          flex: ((widget.titleHeightPercentage)*100).toInt(),
          child: Container(
            
            color: Colors.blue,
            child: Center(
              child: Text(
                widget.secondChildTitle ?? "",
              ),
            )
          ),
        ),
        Expanded(
          flex: ((1 - widget.titleHeightPercentage)*100).toInt(),
          child:widget.secondChild!
        )
      ],
    );

    
    //mainChildWidget = mainChildWidget.runtimeType == EngineSubWindow? mainChildWidget : EngineSubWindow(mainChild: mainChildWidget,mainChildTitle: widget.mainChildTitle,);
    //secondChildWidget = secondChildWidget.runtimeType == EngineSubWindow? secondChildWidget : EngineSubWindow(mainChild: secondChildWidget,mainChildTitle: widget.secondChildTitle,);

    return widget.division == SubWindowDivision.top || widget.division == SubWindowDivision.bottom? 
    Column(
      children: widget.division == SubWindowDivision.top? 
      [
        Expanded(
          flex: ((widget.mainChildProportion - 1)* 100).toInt(),
          child: mainChildWidget
        ),
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.black87,
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
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.black87,
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
        Expanded(
          flex: 2,
          child: Container(
            color: Colors.black87,
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
        Expanded(
          flex: 2,
          child: Container(
            color: Colors.black87,
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