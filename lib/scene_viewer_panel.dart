





import 'dart:ui' as ui;

import 'package:flutter/material.dart' hide MenuBar hide MenuStyle;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:typhon/engine_sub_window.dart';
import 'package:typhon/widgets/general_widgets.dart';
import 'package:typhon/native_view_interface.dart';

import 'engine.dart';


class SceneViewerWindow extends EngineSubWindowData {
  static bool exists = false;
  static GlobalKey key = GlobalKey();

  SceneViewerWindow() : super(
    title: "Scene",
    backgroundOpaque: false,
    closable: false,
    topPanelWidgets: const SceneViewerTop(),
    child: const SceneViewerContents(),
    onLeavingTab: () {
      Engine.instance.detachPlatformSpecificView();
    },
    onTabSelected: () {
      Engine.instance.attachPlatformSpecificView();
    }
  );


}



class SceneViewerTop extends StatefulWidget {
  const SceneViewerTop({super.key});

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
    Engine.instance.lastCompilationResult.addListener(callback);
    super.initState();

  }

  @override
  void dispose() {
    Engine.instance.lastCompilationResult.removeListener(callback);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            child: InkWell(
              onTap: () {
                Engine.instance.enqueueRecompilation();
              },
              child: const Icon(Icons.close,color: Colors.red,),
            ),
          )
          ,
        ),
      ],
    );
  }
}


class SceneViewerContents extends StatefulWidget {

  
  const SceneViewerContents({super.key});

  @override
  State<SceneViewerContents> createState() => _SceneViewerContentsState();
}

class _SceneViewerContentsState extends State<SceneViewerContents> {
  bool shouldStopUpdatingSubWindow = false;

  Rect lastRect = const Rect.fromLTRB(1, 1, 1, 1);
  @override
  void initState() {
    super.initState();

    SceneViewerWindow.exists = true;
    
  }

  @override
  void dispose() {
    super.dispose();
    shouldStopUpdatingSubWindow = true;
    

    SceneViewerWindow.exists = false;
  }

  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: (SizeChangedLayoutNotification notification) {
        WidgetsBinding.instance.addPostFrameCallback((_) { 
          var box = SceneViewerWindow.key.currentContext!.findRenderObject() as RenderBox;
          var position = box.localToGlobal(Offset.zero);
          var windowSize = (ui.window.physicalSize / ui.window.devicePixelRatio);
          position = Offset(position.dx,position.dy);
          var physSize = box.size;
          var rectToSend = Rect.fromLTWH(position.dx,windowSize.height - position.dy - physSize.height,physSize.width,physSize.height);
          if(rectToSend != lastRect) {
            NativeViewInterface.updateSubViewRect(rectToSend);
            lastRect = rectToSend;
          }
        });
        return true;
      },
      child: SizeChangedLayoutNotifier(
        key: SceneViewerWindow.key,
        child: Container(
          color: Colors.transparent,
        ),
      ),
    );
  }


}