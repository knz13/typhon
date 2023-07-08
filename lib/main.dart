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
import 'package:window_manager/window_manager.dart';
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
  await windowManager.ensureInitialized();



  WindowOptions windowOptions = WindowOptions(
    size: Size(1280, 600),
    center: true,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  String libsDir = await TyphonCPPInterface.extractLib();
  

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static Offset globalMousePosition = Offset.zero;
  static GlobalKey<NavigatorState> globalContext = GlobalKey();
  static bool isInteractingWithWindow = false;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {

    super.initState();
    initializeContextMenu();


    (() async {
      while(true){
        if(MyApp.isInteractingWithWindow){
          MyApp.isInteractingWithWindow = false;
        }

        await Future.delayed(Duration(seconds: 3));
      }
    })();
    

  }

  Widget buildMainApp() {
    Widget mainAppWidget =  MouseRegion(
        onHover: (ev) {
          MyApp.globalMousePosition = ev.position;
          if(!MyApp.isInteractingWithWindow){
            if(Engine.instance.shouldRecompile()){
              Engine.instance.reloadProject();
            }
            MyApp.isInteractingWithWindow = true;
          }
        },
        child: MaterialApp(
          navigatorKey: MyApp.globalContext,
          theme: ThemeData(
  primaryColor: Colors.transparent,
  primaryColorLight: Colors.transparent,
  primaryColorDark: Colors.transparent,
  canvasColor: Colors.transparent,
  scaffoldBackgroundColor: Colors.transparent,
  bottomAppBarColor: Colors.transparent,
  cardColor: Colors.transparent,
  dividerColor: Colors.transparent,
  focusColor: Colors.transparent,
  highlightColor: Colors.transparent,
  hoverColor: Colors.transparent,
  splashColor: Colors.transparent,
  selectedRowColor: Colors.transparent,
  unselectedWidgetColor: Colors.transparent,
  disabledColor: Colors.transparent,
  buttonTheme: ButtonThemeData(
    buttonColor: Colors.transparent,
    disabledColor: Colors.transparent,
    colorScheme: ColorScheme.light(
      primary: Colors.transparent,
      secondary: Colors.transparent,
      surface: Colors.transparent,
      background: Colors.transparent,
      error: Colors.transparent,
      onPrimary: Colors.transparent,
      onSecondary: Colors.transparent,
      onSurface: Colors.transparent,
      onBackground: Colors.transparent,
      onError: Colors.transparent,
      brightness: Brightness.dark,
    ),
  ),
),
          title: 'Typhon',
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: Colors.transparent,
            body: ProjectsPage()
          )
        ),
      );

    return Platform.isMacOS ? PlatformMenuBar(
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
                          Engine.instance.unload();
                          Navigator.of(MyApp.globalContext.currentContext!).popUntil((route) => route.isFirst);
                          Navigator.of(MyApp.globalContext.currentContext!).pop();
                          Navigator.of(MyApp.globalContext.currentContext!).push(MaterialPageRoute(builder:(context) {
                            print("loading projects page!");
                            return ProjectsPage();
                          },));
                        }
                      ),
                    ])
                  ]
                )
              ],
              child: mainAppWidget
            ) : mainAppWidget;
  }

  int page = 1;
  @override
  Widget build(BuildContext context) {
    return buildMainApp();
  }
}