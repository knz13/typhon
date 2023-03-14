



import 'dart:ui';

import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tabbed_view/tabbed_view.dart';
import 'package:typhon/engine.dart';
import 'package:typhon/main.dart';



enum SubWindowDivision {
  left,
  right,
  top,
  bottom
}

class EngineSubWindowData {
  Widget child;
  String title;
  bool closable;
  List<TabbedViewMenuItem> menuItems;

  EngineSubWindowData({required this.child,required this.title,this.closable = true,this.menuItems = const []});

}


class EngineSubWindow extends StatefulWidget {

  List<EngineSubWindowData> tabs;
  EngineSubWindow? splitSubWindow;
  EngineSubWindow? mainSubWindow;
  SubWindowDivision division;
  double mainChildProportion;
  double proportionAllowedRange;
  TextStyle? titleStyle;
  static List<EngineSubWindow> aliveWindows = [];
  static double titleHeight = 20;
  static double subWindowBorderWidth = 2;
  static Color tabAreaColor = Colors.black;
  static Color tabColor = const Color.fromARGB(255, 60, 60, 60);
  static Color backgroundColor = const Color.fromARGB(255, 100, 100, 100);
  ValueNotifier emptyNotifier = ValueNotifier(false);


  EngineSubWindow(
    {
      super.key,
      this.mainSubWindow,
      this.splitSubWindow,
      this.titleStyle,
      this.tabs = const [],
      this.division = SubWindowDivision.top,
      this.mainChildProportion = 0.5,
      this.proportionAllowedRange = 0.8
    }
  );


 
  

  @override
  State<EngineSubWindow> createState() => _EngineSubWindowState();
}







class _EngineSubWindowState extends State<EngineSubWindow>  {
  late TabbedViewController _controller;

  

  void clone(EngineSubWindow other) {
    setState(() {
      widget.tabs = other.tabs;
      widget.division = other.division;
      widget.mainChildProportion = other.mainChildProportion;
      widget.proportionAllowedRange = other.proportionAllowedRange;
      widget.splitSubWindow = other.splitSubWindow;
      widget.mainSubWindow = other.mainSubWindow;
    });



    initializeNotifiers();
  }

  @override
  void initState() {
    super.initState();

    

    if(((widget.mainSubWindow != null && widget.splitSubWindow != null) || (widget.mainSubWindow != null && widget.splitSubWindow == null))|| widget.tabs.length != 0){
    }
    else {
      throw Exception("Please only add tabs to a leaf window (one without main or split sub windows)");

    }

    if(widget.tabs.length != 0){
      EngineSubWindow.aliveWindows.add(widget);
    }

    List<TabData> data = [];

    _controller = TabbedViewController(data);

    initializeNotifiers();
  }

  void initializeNotifiers() {
    if(widget.splitSubWindow != null){
      widget.splitSubWindow!.emptyNotifier.addListener(() {
        if(mounted){
          setState(() {
            widget.splitSubWindow = null;
          });
        }
      });
     
    }
    if(widget.mainSubWindow != null){
      widget.mainSubWindow?.emptyNotifier.addListener(() {
        if(mounted){

          setState(() {
            if(widget.splitSubWindow != null){
              widget.mainSubWindow = widget.splitSubWindow;
              widget.splitSubWindow = null;
              initializeNotifiers();
            }
            else {
              widget.emptyNotifier.value = true;
            }  
          
          });
        }
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose

    if(EngineSubWindow.aliveWindows.contains(widget)){
      EngineSubWindow.aliveWindows.remove(widget);  
    }
    

    super.dispose();
  }
 

  @override
  Widget build(BuildContext context) {
    
    Widget mainChildWidget = Container();

    if(widget.tabs.length != 0){

      
      List<TabData> tabData = [];
      for(EngineSubWindowData data in widget.tabs){
        tabData.add(
          TabData(
            closable: false,
            text: data.title,
            content: data.child,
          )
        );
      }

      //print("called! len = ${_controller.tabs}");

      _controller = TabbedViewController(tabData);


      
      mainChildWidget = TabbedView(
        controller: _controller,
        tabsAreaButtonsBuilder:(context, tabsCount) {

          return [
            TabButton(
              icon: IconProvider.data(FontAwesomeIcons.ellipsisVertical),
              menuBuilder: (context) {
                List<TabbedViewMenuItem> items = widget.tabs[_controller.selectedIndex!].menuItems.toList();

              
                if(widget.tabs[_controller.selectedIndex!].closable && EngineSubWindow.aliveWindows.length != 1){
                  items.add(TabbedViewMenuItem(text: "Close Tab",onSelection: () {
                    
                    if(widget.tabs.length == 1){
                      setState(() {
                        widget.emptyNotifier.value = true;
                      });
                      return;
                    }
                    setState(() {
                      widget.tabs.removeAt(_controller.selectedIndex!);
                    });
                  }));
                }

                return items;
              },
            )
          ];
        },
        draggableTabBuilder: (tabIndex, tab, tabWidget) {
          return Draggable(
            data: "TabsDraggableData",
            feedback: SizedBox(
              width: 200,
              height: 100,
              child: Blur(
                blur: 0.5,
                colorOpacity: 0.1,
                child: EngineSubWindow(tabs: [
                  EngineSubWindowData(
                    title: tab.text,
                    child: Container()
                  )
                ],),
              ),
            ),
            child: tabWidget
          );
        },
      );


      TabbedViewThemeData theme = TabbedViewThemeData.dark()
        ..menu.ellipsisOverflowText = true 
        ..tabsArea.middleGap = 2
        ..tab.textStyle = widget.titleStyle ?? TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.normal,
          decoration: TextDecoration.none,
          fontSize: 13
        )
        ..tabsArea.color = EngineSubWindow.backgroundColor
        ..tab.selectedStatus.decoration = BoxDecoration(
          color: EngineSubWindow.tabColor
        )
        ..tab.decoration = BoxDecoration(
          color: EngineSubWindow.backgroundColor
        )
        ..tabsArea.buttonsAreaPadding = EdgeInsets.zero

        ..contentArea.decoration = BoxDecoration(
          color: EngineSubWindow.tabColor
        )
        ..menu.blur = true
        ..contentArea.padding = EdgeInsets.zero;

      

      mainChildWidget = TabbedViewTheme(
        data: theme,
        child: mainChildWidget
      );

      



    }
    else {
      mainChildWidget = widget.mainSubWindow!;

    }


    if(widget.splitSubWindow == null) {
      return mainChildWidget;
    }

    mainChildWidget = SizedBox(
        width: widget.division == SubWindowDivision.left || widget.division == SubWindowDivision.right ? ((MediaQuery.of(context).size.width * (widget.mainChildProportion))): null,
        height: widget.division == SubWindowDivision.top || widget.division == SubWindowDivision.bottom? ((MediaQuery.of(context).size.height * (widget.mainChildProportion))): null,
        child: mainChildWidget
    );


    Widget secondChildWidget = widget.splitSubWindow!;

    secondChildWidget = SizedBox(
        width: widget.division == SubWindowDivision.left || widget.division == SubWindowDivision.right ? ((MediaQuery.of(context).size.width * (1 - widget.mainChildProportion))) : null,
        height: widget.division == SubWindowDivision.top || widget.division == SubWindowDivision.bottom? ((MediaQuery.of(context).size.height * (1 - widget.mainChildProportion))): null,
        child: secondChildWidget
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
              color: Colors.black,
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
          flex:((1-(widget.mainChildProportion))* 100).toInt(),
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
              color: Colors.black,
              height: EngineSubWindow.subWindowBorderWidth,
            ),
          ),
        ),
        Expanded(
          flex: ((widget.mainChildProportion)* 100).toInt(),
          child: mainChildWidget
        ),
      ]
    ) 
    :
    Row(
      children: widget.division == SubWindowDivision.left?
      [
        Expanded(
          flex: ((widget.mainChildProportion)* 100).toInt(),
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
              color: Colors.black,
              width: EngineSubWindow.subWindowBorderWidth,
            ),
          ),
        ),
        Expanded(
          flex:((1-(widget.mainChildProportion))* 100).toInt(),
          child: secondChildWidget
        ),
      ] 
      :
      [
        Expanded(
          flex:((1-(widget.mainChildProportion))* 100).toInt(),
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
              color: Colors.black,
              width: EngineSubWindow.subWindowBorderWidth,
            ),
          ),
        ),
        Expanded(
          flex: ((widget.mainChildProportion)* 100).toInt(),
          child: mainChildWidget
        ),
      ]
    );
  }
}