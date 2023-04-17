





// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart' hide MenuBar hide MenuStyle;
import 'package:menu_bar/menu_bar.dart';
import 'package:typhon/engine.dart';
import 'package:typhon/project_choice_window.dart';
import 'package:typhon/scene_viewer_panel.dart';

import 'console_panel.dart';
import 'engine_sub_window.dart';
import 'file_viewer_panel.dart';
import 'general_widgets.dart';
import 'hierarchy_panel.dart';
import 'inspector_panel.dart';
import 'main.dart';

class MainEngineFrontend extends StatefulWidget {


  static bool isEditing = true; 
  static Offset mousePosition = Offset.zero;

  @override
  State<MainEngineFrontend> createState() => _MainEngineFrontendState();
}

class _MainEngineFrontendState extends State<MainEngineFrontend> {



  


  @override
  void initState() {
    // TODO: implement initState
    
    super.initState();
    if(Engine.instance.hasInitializedProject()){
      Engine.instance.reloadProject();
    }

  }

 

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    Engine.instance.unload();

  }

  

  @override
  Widget build(BuildContext context) {
  
    return SafeArea(
      child: MouseRegion(
        onHover: (ev) {
          MainEngineFrontend.mousePosition = ev.position;
        },
        child: MenuBar(
              barStyle: BarStyle(
                backgroundColor: primaryBlack,
                openMenuOnHover: true
              ),
              barButtonStyle: BarButtonStyle(

              ),
              menuButtonStyle: MenuButtonStyle(
                
              ),
              menuStyle: MenuStyle(
                
              ),
              barButtons: [
                BarButton(text: GeneralText("Typhon"), submenu: SubMenu(
                  menuItems: [
                    MenuButton(
                      text: GeneralText("About",color: primaryBlack,),
                      onTap: null
                    ),
                    MenuButton(
                      text: GeneralText("Preferences",color: primaryBlack,),
                      onTap: null
                    ),
                    MenuButton(
                      text: GeneralText("Shortcuts",color: primaryBlack,),
                      onTap: null
                    ),

                  ],
                )),
                BarButton(text: GeneralText("Project"),submenu: SubMenu(
                  menuItems:[
                    MenuButton(
                      text: GeneralText("Project Selection",color: primaryBlack,),
                      onTap: () {
                        Navigator.of(MyApp.globalContext.currentContext!).popUntil((route) => route.isFirst);
                        Navigator.of(MyApp.globalContext.currentContext!).push(MaterialPageRoute(builder:(context) {
                          Engine.instance.unloadProject();
                          return ProjectsPage();
                        },));
                      }
                    ),
                  ]
                ),)
              ],
              child: Scaffold(
                body: MainEngineFrontend.isEditing ? EngineSubWindow(
                  division: SubWindowDivision.left,
                  mainChildProportion: 0.75,
                  mainSubWindow: EngineSubWindow(
                    mainChildProportion: 0.7,
                    division: SubWindowDivision.top,
                    mainSubWindow: EngineSubWindow(
                      division: SubWindowDivision.right,
                      mainChildProportion: 0.75,
                      mainSubWindow: EngineSubWindow(
                        tabs: [
                          SceneViewerPanel().subWindowData()
                        ]
                      ),
                      splitSubWindow: EngineSubWindow(
                        tabs: [
                          HierarchyPanel().subWindowData()
                        ],
                      ),
                    ),
                    splitSubWindow: EngineSubWindow(
                      tabs: [
                        FileViewerPanelWindow(),
                        ConsolePanelSubWindow()
                      ],
                    ),
                  ),
                  splitSubWindow: EngineSubWindow(
                    tabs: [
                      EngineSubWindowData(
                        title: "Inspector",
                        child: InspectorPanel()
                      )
                    ],
                  ),
                ) : SceneViewerPanel().subWindowData().child
              ), 
            )
      ) ,
    );
  }
}
