
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide MenuBar hide MenuStyle;

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:typhon/engine_sub_window.dart';
import 'package:typhon/tree_viewer.dart';

import 'engine.dart';
import 'game_object.dart';
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
              ContextMenuOption(
                title: "NPC Derived",
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


class HierarchyPanelContents extends StatefulWidget {

  

  @override
  State<HierarchyPanelContents> createState() => _HierarchyPanelContentsState();
}

class _HierarchyPanelContentsState extends State<HierarchyPanelContents> {
  
/*   List<TreeNode> buildTreeFromComponents(List<GameObject> components) {
        final children = <TreeNode>[];
        for (final component in components) {
        bool isExpanded = false;
        final componentChildren = component.children.toList().whereType<GameObject>().toList();
        children.add(TreeNode(
          content: Row(
            children: [
              if(componentChildren.isNotEmpty)
              InkWell(
                onTap: () {},
                child: Icon(MdiIcons.menuDown)
              ),
              Icon(MdiIcons.cubeOutline),
              GeneralText(
                component.name
              ),

            ],
          ),
          children: buildTreeFromComponents(componentChildren)
        ));
        
      }
      return children;
  } */

  List<GameObject> currentObjects = [];

  void tryAddListenerToEngine() async {
    while(true) {
      ValueNotifier? notifier = Engine.getChildrenChangedNotifier();
      if(notifier != null){
        notifier.addListener(() {
          setState(() {
            currentObjects = Engine.getChildren();
          });
        });
        break;
      }
      await Future.delayed(Duration(milliseconds: 300));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tryAddListenerToEngine();
  }
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: NeverScrollableScrollPhysics(),
      child: Container(),
    );
  }
}