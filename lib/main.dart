// ignore_for_file: prefer_const_constructors

import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide MenuBar hide MenuStyle;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:menu_bar/menu_bar.dart';
import 'package:typhon/console_panel.dart';
import 'package:typhon/engine_sub_window.dart';
import 'package:typhon/general_widgets.dart';
import 'package:typhon/hierarchy_panel.dart';
import 'package:typhon/inspector_panel.dart';
import 'package:typhon/project_choice_window.dart';
import 'package:typhon/scene_viewer_panel.dart';
import 'package:typhon/typhon_bindings.dart';
import 'engine.dart';
import 'file_viewer_panel.dart';
import 'main_engine_frontend.dart';
import 'package:window_size/window_size.dart';
import 'dart:io';

Color activeColor = const Color.fromRGBO(62,62,62,1);
Color blueColor = const Color.fromRGBO(63,117,195,1);
Color primaryBlack = const Color.fromRGBO(20,20,20,1);
Color secondaryBlack = const Color.fromRGBO(36,36,36,1);

class Tile {
  int idx = 0;
  String title = "Projects";
  Widget leading = const Icon(Icons.menu,color: Colors.white70);
}

double contextWidth(var context){
  return MediaQuery.of(context).size.width;
}
double contextHeight(var context){
  return MediaQuery.of(context).size.height;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Typhon');
    setWindowMinSize(const Size(1280, 600));
    setWindowMaxSize(Size.infinite);
  }
  String libsDir = await TyphonCPPInterface.extractLib();
  

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static Offset globalMousePosition = Offset.zero;
  static GlobalKey<NavigatorState> globalContext = GlobalKey();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {

    super.initState();
    initializeContextMenu();

    

  }

  Widget buildMainApp() {
    return MouseRegion(
        onHover: (ev) {
          MyApp.globalMousePosition = ev.position;
        },
        child: MaterialApp(
          navigatorKey: MyApp.globalContext,
          title: 'Typhon',
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: Platform.isMacOS ? PlatformMenuBar(
              menus: [
                PlatformMenu(
                  label: "Typhon",
                  menus: [
                    PlatformMenuItemGroup(
                      members: [
                        PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.about),
                        PlatformMenuItem(
                          label: "Preferences",
                        ),
                        PlatformMenuItem(
                          label: "Shortcuts",
                        ),
                      ]
                    ),
                    
                  ]
                ),
                PlatformMenu(
                  label: "Project" ,
                  menus: [
                    PlatformMenuItemGroup(members: [
                      PlatformMenuItem(
                        label: "Project Selection",
                        onSelected: () {
                          Navigator.of(MyApp.globalContext.currentContext!).popUntil((route) => route.isFirst);
                          Navigator.of(MyApp.globalContext.currentContext!).push(MaterialPageRoute(builder:(context) {
                            Engine.instance.unload();
                            return ProjectsPage();
                          },));
                        }
                      ),
                    ])
                  ]
                )
              ],
              child: ProjectsPage()
            ) : ProjectsPage()
          )
        ),
      );
  }

  int page = 1;
  @override
  Widget build(BuildContext context) {
    return buildMainApp();
  }
}