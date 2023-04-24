





import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide MenuBar hide MenuStyle;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:typhon/engine_sub_window.dart';
import 'package:typhon/general_widgets.dart';

import 'engine.dart';


class SceneViewerWindow extends EngineSubWindowData {
  static bool exists = false;

  SceneViewerWindow() : super(title: "Scene",closable: false,topPanelWidgets: SceneViewerTop(),child: SceneViewerContents());


}



class SceneViewerTop extends StatefulWidget {
  @override
  State<SceneViewerTop> createState() => _SceneViewerTopState();
}

class _SceneViewerTopState extends State<SceneViewerTop> {

  void callback() {
    setState(() {
      
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    Engine.instance.lastCompilationResult.addListener(callback);
    super.initState();

  }

  @override
  void dispose() {
    // TODO: implement dispose
    Engine.instance.lastCompilationResult.removeListener(callback);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Container(),
        ),
        Expanded(
          flex: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: (){},
                child: Icon(Icons.play_arrow_rounded,color: platinumGray,),
              ),
              InkWell(
                child: Icon(Icons.pause,color: platinumGray),
              ),
              InkWell(
                child: Icon(Icons.stop,color: platinumGray),
              ),
            ]
          )
        ),
        Expanded(
          flex: 2,
          child: Engine.instance.lastCompilationResult.value ? 
          Tooltip(
            message: "Compilation Succeeded",
            child: Icon(MdiIcons.check,color: platinumGray,)
          ) 
          : 
          Tooltip(
            message: "Recompile Project",
            child: GeneralButton(
              onPressed: () {
                Engine.instance.enqueueRecompilation();
              },
              child: Icon(Icons.close,color: Colors.red,),
            ),
          )
          ,
        ),
      ],
    );
  }
}


class SceneViewerContents extends StatefulWidget {

  
  SceneViewerContents();

  @override
  State<SceneViewerContents> createState() => _SceneViewerContentsState();
}

class _SceneViewerContentsState extends State<SceneViewerContents> {
  late GameWidget gameWidget;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SceneViewerWindow.exists = true;

    gameWidget = GameWidget(game: Engine.instance);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    SceneViewerWindow.exists = false;
  }

  Widget build(BuildContext context) {
    return gameWidget;
  }
}