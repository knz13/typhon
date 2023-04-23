
import 'dart:ffi';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide MenuBar hide MenuStyle;
import 'package:ffi/ffi.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:typhon/engine_sub_window.dart';
import 'package:typhon/tree_viewer.dart';
import 'package:typhon/typhon_bindings.dart';
import 'package:typhon/typhon_bindings_generated.dart';

import 'engine.dart';
import 'general_widgets.dart';
import 'main.dart';


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

class HierarchyPanelTop extends StatefulWidget {



  @override
  State<HierarchyPanelTop> createState() => _HierarchyPanelTopState();
}

class _HierarchyPanelTopState extends State<HierarchyPanelTop> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();


    Engine.instance.onRecompileNotifier.addListener(() {
      if(mounted){
        setState(() {
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
        children: [
          GeneralButton(
            onPressed: () {
              showNativeContextMenu(context, MyApp.globalMousePosition.dx, MyApp.globalMousePosition.dy,TyphonCPPInterface.checkIfLibraryLoaded() ? (() {
              ClassesArray arr = TyphonCPPInterface.getCppFunctions().getInstantiableClasses();
              List<ContextMenuOption> options = [];
              for(int index in List.generate(arr.size, (index) => index)){
                var val = arr.array.elementAt(index).value;
                final Pointer<Utf8> str = arr.stringArray.elementAt(index).value.cast<Utf8>();
                
                options.add(
                  ContextMenuOption(
                    title: str.toDartString(),
                    callback: () {TyphonCPPInterface.getCppFunctions().createObjectFromClassID(val);}
                  )
                );
              }
              
              return options;
            })()
            :
            []);
            },
            child: Row(
              children: [
                Icon(MdiIcons.plus,color:Colors.white),
                Icon(MdiIcons.menuDown,color:Colors.white)
              ], 
            ),
            
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

  List<Pair<String,int>> currentObjects = [];


  void callbackToEngineChanges() async {

    if(mounted) {
      setState(() {
        currentObjects = Engine.instance.currentChildren.value.map((e) => Pair(TyphonCPPInterface.getCppFunctions().getObjectNameByID(e).cast<Utf8>().toDartString(),e)).toList();
      });
    }
  }

  

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Engine.instance.currentChildren.addListener(callbackToEngineChanges);

  } 



  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    Engine.instance.currentChildren.removeListener(callbackToEngineChanges);
  }

  int idChosen = -1;
  
  @override
  Widget build(BuildContext context) {

    setState(() {
    });

    // TODO: implement build
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: NeverScrollableScrollPhysics(),
      child: Column(
        children: currentObjects.map((e) =>
          Row(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: GeneralButton(
                onPressed: () {
                  setState(() {
                    idChosen = e.second;
                  });

                  if(!TyphonCPPInterface.checkIfLibraryLoaded()){
                    print("Tried pressing while library not loaded!");
                    return;
                  }
                  
                  Pointer<Char> val = TyphonCPPInterface.getCppFunctions().getObjectSerializationByID(idChosen);
                  if(val != nullptr){
                    print(val.cast<Utf8>().toDartString());
                  }

                },
                color:idChosen == e.second? Colors.red : null,
                child: GeneralText(e.first)
              ),
            ),
            InkWell(
              onTap: () {
                if(TyphonCPPInterface.checkIfLibraryLoaded()){
                  TyphonCPPInterface.getCppFunctions().removeObjectByID(e.second);
                }
              },
              child: Icon(Icons.delete),
            )

          ],)
        ).toList(),
      ),
    );
  }
}


class Pair<T1,T2> {
  T1 first;
  T2 second;

  Pair(this.first,this.second);

}