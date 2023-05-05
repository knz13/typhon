





import 'dart:ffi';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide MenuBar hide MenuStyle;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:typhon/engine_sub_window.dart';
import 'package:typhon/general_widgets.dart';
import 'package:typhon/native_view_interface.dart';
import 'package:typhon/typhon_bindings.dart';

import 'engine.dart';


class SceneViewerWindow extends EngineSubWindowData {
  static bool exists = false;
  static GlobalKey key = GlobalKey();

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
  bool shouldStopUpdatingSubWindow = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    (() async {
      while(true){
        if (SceneViewerWindow.key.currentContext != null) {
          break;
        }
        await Future.delayed(Duration(milliseconds: 100));
      }
      
      while(!shouldStopUpdatingSubWindow){
        var box = SceneViewerWindow.key.currentContext!.findRenderObject() as RenderBox;
        var position = box.localToGlobal(Offset.zero);
        var windowSize = (ui.window.physicalSize / ui.window.devicePixelRatio);
        position = Offset(position.dx,position.dy);
        var physSize = box.size;
        var rectToSend = Rect.fromLTWH(position.dx,windowSize.height - position.dy - physSize.height,physSize.width,physSize.height);
        
        NativeViewInterface.updateSubViewRect(rectToSend);
        

        await Future.delayed(Duration(milliseconds: 20));
      }

      
    })();

    SceneViewerWindow.exists = true;
    
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    shouldStopUpdatingSubWindow = true;
    

    SceneViewerWindow.exists = false;
  }

  Widget build(BuildContext context) {
    return Container(
      key: SceneViewerWindow.key,
    );
  }


}