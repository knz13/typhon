// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart' hide MenuBar hide MenuStyle;
import 'package:typhon/config/size_config.dart';
import 'package:typhon/environment.dart';
import 'package:typhon/features/project_initialization/presentation/existing_project_selection_panel.dart';
import 'package:typhon/native_context_menu/native_context_menu.dart';
import 'package:typhon/typhon_bindings.dart';
import 'package:window_manager/window_manager.dart';
import 'engine.dart';
import 'package:window_size/window_size.dart';
import 'dart:io';

class Tile {
  int idx = 0;
  String title = "Projects";
  Widget leading = const Icon(Icons.menu, color: Colors.white70);
}

double contextWidth(var context) {
  return MediaQuery.of(context).size.width;
}

double contextHeight(var context) {
  return MediaQuery.of(context).size.height;
}

void main() async {
  Environment.setEnvironment(Environment.devBackend);

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
  await TyphonCPPInterface.extractLib();

  runApp(const MainEngineApp());
}

class MainEngineApp extends StatefulWidget {
  const MainEngineApp({super.key});

  static Offset globalMousePosition = Offset.zero;
  static GlobalKey<NavigatorState> globalContext = GlobalKey();
  static bool isInteractingWithWindow = false;

  @override
  State<MainEngineApp> createState() => _MainEngineAppState();
}

class _MainEngineAppState extends State<MainEngineApp> {
  @override
  void initState() {
    super.initState();
    initializeContextMenu();

    (() async {
      while (true) {
        if (MainEngineApp.isInteractingWithWindow) {
          MainEngineApp.isInteractingWithWindow = false;
        }

        await Future.delayed(Duration(seconds: 3));
      }
    })();
  }

  Widget buildMainEngine() {
    Widget mainAppWidget = MouseRegion(
      onHover: (ev) {
        MainEngineApp.globalMousePosition = ev.position;
        if (!MainEngineApp.isInteractingWithWindow) {
          if (Engine.instance.shouldRecompile()) {
            Engine.instance.reloadProject();
          }
          MainEngineApp.isInteractingWithWindow = true;
        }
      },
      child: MaterialApp(
          navigatorKey: MainEngineApp.globalContext,
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
              body: ExistingProjectSelectionPanel())),
    );

    return Platform.isMacOS
        ? PlatformMenuBar(menus: [
            PlatformMenu(label: "Typhon", menus: [
              PlatformMenuItemGroup(members: [
                PlatformProvidedMenuItem(
                    type: PlatformProvidedMenuItemType.about),
                PlatformMenuItem(
                  label: "Preferences",
                ),
                PlatformMenuItem(
                  label: "Shortcuts",
                ),
              ]),
            ]),
            PlatformMenu(label: "Project", menus: [
              PlatformMenuItemGroup(members: [
                PlatformMenuItem(
                    label: "Project Selection",
                    onSelected: () {
                      Engine.instance.unload();
                      Navigator.of(MainEngineApp.globalContext.currentContext!)
                          .popUntil((route) => route.isFirst);
                      Navigator.of(MainEngineApp.globalContext.currentContext!)
                          .pop();
                      Navigator.of(MainEngineApp.globalContext.currentContext!)
                          .push(MaterialPageRoute(
                        builder: (context) {
                          print("loading projects page!");
                          return ExistingProjectSelectionPanel();
                        },
                      ));
                    }),
              ])
            ])
          ], child: mainAppWidget)
        : mainAppWidget;
  }

  int page = 1;
  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    if (Environment.getEnvironment() == Environment.devBackend ||
        Environment.getEnvironment() == Environment.prodBackend) {
      return buildMainEngine();
    } else {
      return Container();
    }
  }
}
