// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:flutter/material.dart' hide MenuBar hide MenuStyle;
import 'package:flutter/material.dart';
import 'package:menu_bar/menu_bar.dart';
import 'package:typhon/config/theme.dart';
import 'package:typhon/engine.dart';
import 'package:typhon/features/project_initialization/presentation/existing_project_selection_panel.dart';
import 'package:typhon/scene_viewer_panel.dart';

import 'console_panel.dart';
import 'engine_sub_window.dart';
import 'file_viewer_panel/file_viewer_panel.dart';
import 'widgets/general_widgets.dart';
import 'hierarchy_panel/hierarchy_panel.dart';
import 'inspector_panel/inspector_panel.dart';
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
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    InspectorPanelWindow.data.value = InspectorPanelData();
    Engine.instance.unload();
  }

  Widget buildMainFrontend() {
    return MouseRegion(
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: EngineSubWindow(
            division: SubWindowDivision.left,
            mainChildProportion: 0.75,
            mainSubWindow: EngineSubWindow(
              mainChildProportion: 0.7,
              division: SubWindowDivision.top,
              mainSubWindow: EngineSubWindow(
                division: SubWindowDivision.right,
                mainChildProportion: 0.75,
                mainSubWindow: EngineSubWindow(tabs: [SceneViewerWindow()]),
                splitSubWindow: EngineSubWindow(
                  tabs: [HierarchyPanelWindow()],
                ),
              ),
              splitSubWindow: EngineSubWindow(
                tabs: [FileViewerPanelWindow(), ConsolePanelSubWindow()],
              ),
            ),
            splitSubWindow: EngineSubWindow(
              tabs: [InspectorPanelWindow()],
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MouseRegion(
          onHover: (ev) {
            MainEngineFrontend.mousePosition = ev.position;
          },
          child: Platform.isWindows
              ? MenuBarWidget(
                  barStyle: MenuStyle(
                    backgroundColor: MaterialStateColor.resolveWith((states) {
                      return ConfigColors.primaryBlack;
                    }),
                  ),
                  barButtonStyle: ButtonStyle(),
                  menuButtonStyle: ButtonStyle(),
                  barButtons: [
                    BarButton(
                        text: GeneralText("Typhon"),
                        submenu: SubMenu(
                          menuItems: [
                            MenuButton(
                                text: GeneralText(
                                  "About",
                                  color: ConfigColors.primaryBlack,
                                ),
                                onTap: null),
                            MenuButton(
                                text: GeneralText(
                                  "Preferences",
                                  color: ConfigColors.primaryBlack,
                                ),
                                onTap: null),
                            MenuButton(
                                text: GeneralText(
                                  "Shortcuts",
                                  color: ConfigColors.primaryBlack,
                                ),
                                onTap: null),
                          ],
                        )),
                    BarButton(
                      text: GeneralText("Project"),
                      submenu: SubMenu(menuItems: [
                        MenuButton(
                            text: GeneralText(
                              "Project Selection",
                              color: ConfigColors.primaryBlack,
                            ),
                            onTap: () {
                              Navigator.of(MainEngineApp
                                      .globalContext.currentContext!)
                                  .popUntil((route) => route.isFirst);
                              Navigator.of(MainEngineApp
                                      .globalContext.currentContext!)
                                  .push(MaterialPageRoute(
                                builder: (context) {
                                  Engine.instance.unloadProject();
                                  return ExistingProjectSelectionPanel();
                                },
                              ));
                            }),
                      ]),
                    )
                  ],
                  child: buildMainFrontend())
              : buildMainFrontend()),
    );
  }
}
