



import 'dart:ui';

import 'package:blur/blur.dart';
import 'package:flutter/material.dart' hide MenuBar hide MenuStyle;
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tabbed_view/tabbed_view.dart';
import 'package:typhon/console_panel.dart';
import 'package:typhon/engine.dart';
import 'package:typhon/file_viewer_panel.dart';
import 'package:typhon/general_widgets.dart';
import 'package:typhon/hierarchy_panel.dart';
import 'package:typhon/inspector_panel.dart';
import 'package:typhon/main.dart';
import 'package:typhon/scene_viewer_panel.dart';



enum SubWindowDivision {
  left,
  right,
  top,
  bottom
}

class EngineSubWindowData {
  Widget child;
  Widget? topPanelWidgets;
  String title;
  Widget? Function(BuildContext,TabStatus)? tabLeading;
  bool closable;
  List<ContextMenuOption> menuItems;
  void Function()? onTabSelected;

  EngineSubWindowData({required this.child,required this.title,this.onTabSelected,this.closable = true,this.menuItems = const [],this.topPanelWidgets,this.tabLeading});

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
  static double subWindowBorderWidth = 3;
  static Color tabAreaColor = Colors.black;
  static Color tabColor = midGray;
  static Color backgroundColor = const Color.fromARGB(255, 100, 100, 100);
  ValueNotifier emptyNotifier = ValueNotifier(0);


  EngineSubWindow(
    {
      super.key,
      this.mainSubWindow,
      this.splitSubWindow,
      this.titleStyle,
      this.tabs = const [],
      this.division = SubWindowDivision.top,
      this.mainChildProportion = 0.5,
      this.proportionAllowedRange = 0.6
    }
  );


 
  

  @override
  State<EngineSubWindow> createState() => _EngineSubWindowState();
}







class _EngineSubWindowState extends State<EngineSubWindow>  {
  late TabbedViewController _controller;

  double initialMainSize = 0;

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
              widget.emptyNotifier.value++;
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
 
  Offset mousePosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    
    Widget mainChildWidget = Container();

    initialMainSize = widget.division == SubWindowDivision.left || widget.division == SubWindowDivision.right ? MediaQuery.of(context).size.width : MediaQuery.of(context).size.height;
    initialMainSize = initialMainSize * widget.mainChildProportion;

    if(widget.tabs.length != 0){

      
      List<TabData> tabData = [];
      for(EngineSubWindowData data in widget.tabs){
        tabData.add(
          TabData(
            closable: false,
            text: data.title,
            leading:data.tabLeading,
            content: Column(
              children: [
                data.topPanelWidgets ?? Container(),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 1,
                  decoration: BoxDecoration(
                    boxShadow: [BoxShadow(
                      blurRadius: 1,

                    )]
                  ),
                ),
                Expanded(child: data.child),
              ],
            ),
          )
        );
      }

      //print("called! len = ${_controller.tabs}");

      _controller = TabbedViewController(tabData);


      
      mainChildWidget = MouseRegion(
        onHover: (event) {
          mousePosition = event.position;
        },
        child: TabbedView(
          onTabSelection: (newTabIndex) {
            if(newTabIndex != null){
              widget.tabs.elementAt(newTabIndex).onTabSelected?.call();
            }
          },
          controller: _controller,
          tabsAreaButtonsBuilder:(context, tabsCount) {
            return [
              TabButton(
                onPressed: () {
                  showNativeContextMenu(context, mousePosition.dx, mousePosition.dy, [
                    if((widget.tabs[_controller.selectedIndex!].closable && EngineSubWindow.aliveWindows.length != 1) || widget.tabs.length != 1)
                    ContextMenuOption(title: "Close Tab",callback: () {
                      if(widget.tabs.length == 1){
                        setState(() {
                          widget.emptyNotifier.value++;
                        });
                        return;
                      }
                      setState(() {
                        widget.tabs.removeAt(_controller.selectedIndex!);
                      });
                    }),
                    SeparatorMenuOption(), 
                    ...widget.tabs[_controller.selectedIndex!].menuItems,
                    SeparatorMenuOption(),
                    ContextMenuOption(title: "Add Tab",subOptions: [
                      
                      ContextMenuOption(title: "Hierarchy",callback: () {
                        setState(() {
                          widget.tabs.add(HierarchyPanelWindow());
                        });
                      },),
                      ContextMenuOption(title: "File Viewer",callback: () {
                        setState(() {
                          widget.tabs.add(FileViewerPanelWindow());
                        });
                      },),
                      ContextMenuOption(title: "Inspector",callback: () {
                        setState(() {
                          widget.tabs.add(InspectorPanelWindow());
                        });
                      },),
                      ContextMenuOption(title: "Console",callback: () {
                        setState(() {
                          widget.tabs.add(ConsolePanelSubWindow());
                        });
                      },),
                    ])
                  ]);
                },
                icon: IconProvider.data(FontAwesomeIcons.ellipsisVertical),
        
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
        ),
      );


      TabbedViewThemeData theme = TabbedViewThemeData.dark()
        ..menu.ellipsisOverflowText = true 
        ..tabsArea.middleGap = 2
        ..tab.textStyle = widget.titleStyle ?? TextStyle(
          color: platinumGray,
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
    Container(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: widget.division == SubWindowDivision.top? 
            [
              Expanded(
                flex: ((widget.mainChildProportion)* 100).toInt(),
                child: mainChildWidget
              ),
              Draggable(
                onDragUpdate: (details) {
                  double delta = details.localPosition.dy/constraints.maxHeight;
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
                    decoration: BoxDecoration(
                      color:Colors.black,
                      boxShadow: [
                        BoxShadow(
                          blurRadius:1,
                          color: Colors.black
                        )
                      ]
                    ),
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
                  double delta = details.localPosition.dy/constraints.maxHeight;
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
                    decoration: BoxDecoration(
                      color:Colors.black,
                      boxShadow: [
                        BoxShadow(
                          blurRadius:1,
                          color: Colors.black
                        )
                      ]
                    ),
                    height: EngineSubWindow.subWindowBorderWidth,
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
      ),
    ) 
    :
    Container(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: widget.division == SubWindowDivision.left?
            [
              Expanded(
                flex: ((widget.mainChildProportion)* 100).toInt(),
                child: mainChildWidget
              ),
              Draggable(
                feedback: Container(),
                onDragUpdate: (details) {
                  double delta = details.localPosition.dx/constraints.maxWidth;
                  if(delta > (1 - widget.proportionAllowedRange)/2 && delta < widget.proportionAllowedRange + (1 - widget.proportionAllowedRange)/2){
                    setState(() {
                      widget.mainChildProportion = delta;
                    });
                  }
                },
                child: MouseRegion(
                  cursor:SystemMouseCursors.resizeLeftRight,
                  child: Container(
                    decoration: BoxDecoration(
                      color:Colors.black,
                      boxShadow: [
                        BoxShadow(
                          blurRadius:1,
                          color: Colors.black
                        )
                      ]
                    ),
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
                  double delta = details.localPosition.dx/constraints.maxWidth;
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
                    decoration: BoxDecoration(
                      color:Colors.black,
                      boxShadow: [
                        BoxShadow(
                          blurRadius:1,
                          color: Colors.black
                        )
                      ]
                    ),
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
      ),
    );
  }
}