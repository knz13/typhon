



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

  EngineSubWindowData({required this.child,required this.title,this.closable = true});

}


class EngineSubWindow extends StatefulWidget {

  List<EngineSubWindowData> tabs;
  EngineSubWindow? splitSubWindow;
  SubWindowDivision division;
  double mainChildProportion;
  double proportionAllowedRange;
  static double titleHeight = 20;
  static double subWindowBorderWidth = 5;
  ValueNotifier emptyNotifier = ValueNotifier(false);


  EngineSubWindow(
    {
      super.key,
      required this.tabs,
      this.splitSubWindow,
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
      widget.splitSubWindow = other.splitSubWindow;
      widget.division = other.division;
      widget.mainChildProportion = other.mainChildProportion;
      widget.proportionAllowedRange = other.proportionAllowedRange;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    List<TabData> data = [];

    _controller = TabbedViewController(data);

    if(widget.splitSubWindow != null){
      widget.splitSubWindow!.emptyNotifier.addListener(() {
        setState(() {
          widget.splitSubWindow = null;
        });
      });
    }
  }

  Widget build(BuildContext context) {
    List<TabData> tabData = [];
    int index = 0;
    for(EngineSubWindowData data in widget.tabs){
      tabData.add(
        TabData(
          closable: false,
          text: data.title,
          content: data.child,
          buttons: [
          ]
        )
      );
    }

    //print("called! len = ${_controller.tabs}");

    _controller = TabbedViewController(tabData);
    _controller.addListener(() {
      if(_controller.tabs.isEmpty){
        if(widget.splitSubWindow != null){
          clone(widget.splitSubWindow!);
        }
      }
    });
    
    Widget mainChildWidget = TabbedView(
      
      controller: _controller,
      tabsAreaButtonsBuilder:(context, tabsCount) {
        return [
          TabButton(
            icon: IconProvider.data(FontAwesomeIcons.ellipsisVertical),
            
            menuBuilder: (context) {
              List<TabbedViewMenuItem> items = [];

              if(widget.tabs[_controller.selectedIndex!].closable){
                items.add(TabbedViewMenuItem(text: "Close Tab",onSelection: () {
                  if(widget.tabs.length == 1){
                    setState(() {
                      widget.emptyNotifier.value = true;
                    });
                    return;
                  }
                  _controller.removeTab(_controller.selectedIndex!);
                }));
              }

              return items;
            },
          )
        ];
      },
    );

    BorderRadiusGeometry radius = const BorderRadius.vertical(top: Radius.circular(2));

    TabbedViewThemeData theme = TabbedViewThemeData.dark()
      ..menu.ellipsisOverflowText = true 
      ..tabsArea.color = Colors.black87
      ..tabsArea.middleGap = 5
      ..menu.blur = true
      ..menu;
    mainChildWidget = TabbedViewTheme(child: mainChildWidget, data: theme);

    if(widget.splitSubWindow == null) {
      return mainChildWidget;
    }

    mainChildWidget = SizedBox(
      width: widget.division == SubWindowDivision.left || widget.division == SubWindowDivision.right ? MediaQuery.of(context).size.width * (widget.mainChildProportion) : null,
      height: widget.division == SubWindowDivision.top || widget.division == SubWindowDivision.bottom? MediaQuery.of(context).size.height * (widget.mainChildProportion) : null,
      child: mainChildWidget 
    );

    Widget secondChildWidget = widget.splitSubWindow!;
    
    
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
              color: Colors.black,
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
              color: Colors.black,
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
              color: Colors.black,
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