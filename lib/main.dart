import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide MenuBar hide MenuStyle;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:typhon/console_panel.dart';
import 'package:typhon/engine_sub_window.dart';
import 'package:typhon/general_widgets.dart';
import 'package:typhon/hierarchy_panel.dart';
import 'package:typhon/inspector_panel.dart';
import 'package:typhon/project_choice_window.dart';
import 'package:typhon/scene_viewer_panel.dart';
import 'engine.dart';
import 'file_viewer_panel.dart';
import 'main_engine_frontend.dart';
import 'package:window_size/window_size.dart';
import 'dart:io';
double contextWidth(var context){
  return MediaQuery.of(context).size.width;
}
double contextHeight(var context){
  return MediaQuery.of(context).size.height;
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Typhon');
    setWindowMinSize(const Size(1280, 600));
    setWindowMaxSize(Size.infinite);
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {

    super.initState();
    initializeContextMenu();

  }
  int page = 0;
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: 'Typhon',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            if(page == 0)
              MainEngineFrontend(),
            if(page == 1)
              const ProjectChoiceWindow(),

            Positioned(
              top: 0,
              right: 0,
              child: Container(
                height: 50,
                width: 50,
                color: Colors.black,
                child: RawMaterialButton(
                  onPressed: (){
                    setState(() {
                      page = page == 0? 1:0;
                    });
                  },
                  child: Icon(MdiIcons.reload,color: Colors.white,),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
