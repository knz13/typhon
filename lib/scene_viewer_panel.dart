





import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide MenuBar hide MenuStyle;
import 'package:typhon/engine_sub_window.dart';
import 'package:typhon/general_widgets.dart';

import 'engine.dart';


class SceneViewerWindow extends EngineSubWindowData {
  static bool exists = false;

  SceneViewerWindow() : super(title: "Scene",topPanelWidgets: SceneViewerTop(),child: SceneViewerContents());


}



class SceneViewerTop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: (){},
          child: Icon(Icons.play_arrow_rounded),
        ),
        InkWell(
          child: Icon(Icons.pause),
        ),
        InkWell(
          child: Icon(Icons.stop),
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