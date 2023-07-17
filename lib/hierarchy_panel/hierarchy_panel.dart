
import 'dart:convert';
import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart' hide MenuBar hide MenuStyle;
import 'package:ffi/ffi.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:typhon/engine_sub_window.dart';
import 'package:typhon/general_widgets/custom_expansion_tile.dart';
import 'package:typhon/hierarchy_panel/hierarchy_widget.dart';
import 'package:typhon/inspector_panel/inspector_panel.dart';
import 'package:typhon/inspector_panel/inspector_panel_builder.dart';
import 'package:typhon/tree_viewer.dart';
import 'package:typhon/typhon_bindings.dart';
import 'package:typhon/typhon_bindings_generated.dart';

import '../engine.dart';
import '../general_widgets.dart';
import '../main.dart';




class HierarchyPanelWindow extends EngineSubWindowData {


  HierarchyPanelWindow() : super(child: HierarchyPanelContents(),title: "Hierarchy",topPanelWidgets: HierarchyPanelTop());

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

  List<ContextMenuOption> buildMenuOptionsFromJson(Map<String,dynamic> map){
    List<ContextMenuOption> options = [];

    map.forEach((key, value) {
      ContextMenuOption option = ContextMenuOption(
        title: key,
        enabled: true,
        subOptions: value is Map<String,dynamic> ? buildMenuOptionsFromJson(value) : null,
        callback: value is Map<String,dynamic> ? null : () {
          if(TyphonCPPInterface.checkIfLibraryLoaded()){
            TyphonCPPInterface.getCppFunctions().createObjectFromClassID(value);
          }
        },
      );
      options.add(option);
    });

    return options;
    
  }

  @override
  Widget build(BuildContext context) {
    return Row(
        children: [
          GeneralButton(
            onPressed: () {
              showNativeContextMenu(context, MyApp.globalMousePosition.dx, MyApp.globalMousePosition.dy,TyphonCPPInterface.checkIfLibraryLoaded() ? (() {
              Pointer<Char> ptr = TyphonCPPInterface.getCppFunctions().getInstantiableClasses();
              String jsonClasses = ptr.cast<Utf8>().toDartString();
              Map<String,dynamic> map = jsonDecode(jsonClasses);


              return buildMenuOptionsFromJson(map);
              
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
  


  List<ObjectFromCPP> currentObjects = [];

  void buildChildrenMapAndAddToObject(ObjectFromCPP obj, Map<String,dynamic> map){
    print(map);
    if(!map.containsKey(obj.id.toString())){
      return;
    }

    obj.name = TyphonCPPInterface.getCppFunctions().getObjectNameByID(obj.id).cast<Utf8>().toDartString();

    if(map[obj.id.toString()]!.isEmpty){
      return;
    }

    obj.children = (map[obj.id.toString()]! as List<dynamic>).map((e) => ObjectFromCPP(id:e)).toList();

    for(var childObj in obj.children){
      buildChildrenMapAndAddToObject(childObj, map);
    }


  }

  void callbackToEngineChanges() async {

    if(mounted) {
      setState(() {
        currentObjects = Engine.instance.currentChildren.value.map((e) {
          ObjectFromCPP obj = ObjectFromCPP(id: e);
          obj.name = TyphonCPPInterface.getCppFunctions().getObjectNameByID(obj.id).cast<Utf8>().toDartString();

          var childrenMap = json.decode(TyphonCPPInterface.getCppFunctions().getObjectChildTree(e).cast<Utf8>().toDartString());
          if(childrenMap is Map<String,dynamic>){
            buildChildrenMapAndAddToObject(obj, childrenMap);
          }

          return obj;
        }).toList();
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
  int idHovered = -1;
  

  
  
  @override
  Widget build(BuildContext context) {
    
    
    return LayoutBuilder(
      builder:(context, constraints) => Container(
        width: constraints.maxWidth,
        child: HierarchyWidget(
            rootObjects: currentObjects, 
            onClick: (obj) {
            setState(() {
              idChosen = obj.id;
            });
          
            if(!TyphonCPPInterface.checkIfLibraryLoaded()){
              print("Tried pressing while library not loaded!");
              return;
            }
            
            Pointer<Char> val = TyphonCPPInterface.getCppFunctions().getObjectInspectorUIByID(idChosen);
            if(val != nullptr){
              var jsonData = jsonDecode(val.cast<Utf8>().toDartString());
              buildInspectorPanelFromComponent(jsonData);
            } 
          }, onWillAcceptDrag: (data,obj) {
    
            return data is String? (json.decode(data)["type"] == "cpp_object"? (json.decode(data)["id"] == obj.id? false : true) : false ): false;
          },
          onAccept: (data, obj) {
            if(TyphonCPPInterface.checkIfLibraryLoaded()) {
              TyphonCPPInterface.getCppFunctions().setObjectParent(json.decode(data as String)["id"], obj.id);
            }
            else {
              print("Library not loaded while ended drag!");
            }
          },
          childBasedOnID: (obj) {
            return MouseRegion(
              onEnter: (event) {
                setState(() {
                  idHovered = obj.id;
                });
              },
              onExit: (event) {
                setState(() {
                  idHovered = -1;
                });
                
              },
              child: Container(
                decoration: BoxDecoration(
                  color: idChosen == obj.id ? Colors.blue : idHovered == obj.id ? Colors.blue.withAlpha(100) : null,
                ),
                child: GeneralText(obj.name),
              )
            );
          },
          feedbackBasedOnID: (obj) {
            return Container(
              decoration: BoxDecoration(
                border: Border.fromBorderSide(BorderSide(color: Colors.black))
              ),
              child: GeneralText(obj.name),
            );
          },
          ),
        ),
      );
  }
}


class Pair<T1,T2> {
  T1 first;
  T2 second;

  Pair(this.first,this.second);

}