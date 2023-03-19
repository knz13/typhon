
import 'package:flutter/material.dart' hide MenuBar hide MenuStyle;
import 'package:typhon/engine_sub_window.dart';

import 'general_widgets.dart';


class HierarchyPanel extends WidgetPanel {

  @override
  EngineSubWindowData subWindowData() {
    // TODO: implement subWindowData
    return EngineSubWindowData(
      title: "Hierarchy",
      topPanelWidgets: HierarchyPanelTop(),
      child: HierarchyPanelContents()
    );
  }
}

class HierarchyPanelTop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Row(
            children: [
              NativeContextMenuButton(
                child: Icon(Icons.add),
                menuItems: [
                  ContextMenuOption(title: "hi"),
                  ContextMenuOption(title: "hallo!",callback: () {
                    print("Callback called!");
                  },)
                ],
              )
            ],
          );
  }

}


class HierarchyPanelContents extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container();
  }
}