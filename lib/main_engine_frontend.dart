





import 'package:flutter/material.dart';
import 'package:typhon/engine.dart';
import 'package:typhon/scene_viewer_panel.dart';

import 'console_panel.dart';
import 'engine_sub_window.dart';
import 'file_viewer_panel.dart';
import 'hierarchy_panel.dart';
import 'inspector_panel.dart';

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
                  EngineSubWindowData(
                    title: "File Viewer",
                    child: FileViewerPanel()
                  ),
                  EngineSubWindowData(
                    title: "Console",
                    child: ConsolePanel(),
                  )
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
      ) ,
    );
  }
}
