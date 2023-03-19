
import 'package:flutter/material.dart' hide MenuBar hide MenuStyle;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
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
    return Row(
        children: [
          NativeContextMenuButton(
            child: Row(
              children: [
                Icon(MdiIcons.plus,color:Colors.white),
                Icon(MdiIcons.menuDown,color:Colors.white)
              ],
            ),
            menuItems: [
              ContextMenuOption(title: "Create Empty"),
              ContextMenuOption(
                title: "Objects",
                subOptions: [
                  ContextMenuOption(title: "Square"),
                  ContextMenuOption(title: "Circle"),
                  ContextMenuOption(title: "Triangle"),
                ],
              )

            ],
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: SizedBox(
              width: MediaQuery.of(context).size.width*0.8,
              height: 20,
              child: TextField(

                style: TextStyle(
                  fontSize: 13,
                  color: platinumGray
                ),
                decoration: InputDecoration(
                  
                  fillColor: jetBlack,
                  filled: true,
                  prefixIcon: Icon(Icons.search,size: 15,color: Colors.white,),
                  prefixIconConstraints: BoxConstraints(minWidth: 30),
                  contentPadding: EdgeInsets.symmetric(horizontal: 5),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(5))
                ),
              ),
            ),
          ),
          SizedBox(
            width: 10,
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