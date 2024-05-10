




import 'dart:io';

import 'package:flutter/material.dart';
import 'package:menu_bar/menu_bar.dart';

import '../../config/theme.dart';
import '../../engine.dart';
import '../../main.dart';
import '../../widgets/general_widgets.dart';
import '../project_initialization/presentation/existing_project_selection_panel.dart';

class PlatformSpecificMenuBar {
  static Widget buildMenuBar({required Widget child}) {
    if(Platform.isMacOS) {
    return PlatformMenuBar(menus: [
            const PlatformMenu(label: "Typhon", menus: [
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
                          return const ExistingProjectSelectionPanel();
                        },
                      ));
                    }),
              ])
            ])
          ], child: child);
    } else if(Platform.isWindows){
      return  MenuBarWidget(
                  barStyle: MenuStyle(
                    backgroundColor: MaterialStateColor.resolveWith((states) {
                      return ConfigColors.primaryBlack;
                    }),
                  ),
                  barButtonStyle: const ButtonStyle(),
                  menuButtonStyle: const ButtonStyle(),
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
                                  return const ExistingProjectSelectionPanel();
                                },
                              ));
                            }),
                      ]),
                    )
                  ],
                  child: child);
    }
    return child;
  }
}