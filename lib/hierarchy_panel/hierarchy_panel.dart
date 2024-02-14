import 'dart:convert';
import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart' hide MenuBar hide MenuStyle;
import 'package:ffi/ffi.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:typhon/engine_sub_window.dart';
import 'package:typhon/widgets/custom_expansion_tile.dart';
import 'package:typhon/widgets/general_text_field.dart';
import 'package:typhon/widgets/hierarchy_widget.dart';
import 'package:typhon/inspector_panel/inspector_panel.dart';
import 'package:typhon/inspector_panel/inspector_panel_builder.dart';
import 'package:typhon/main_engine_frontend.dart';
import 'package:typhon/native_context_menu/native_context_menu.dart';
import 'package:typhon/native_context_menu/native_context_menu_area.dart';
import 'package:typhon/native_context_menu/native_context_menu_button.dart';
import 'package:typhon/tree_viewer.dart';
import 'package:typhon/typhon_bindings.dart';
import 'package:typhon/typhon_bindings_generated.dart';
import 'package:window_manager/window_manager.dart';

import '../engine.dart';
import '../widgets/general_widgets.dart';
import '../main.dart';

class ObjectFromCPP extends HierarchyWidgetData<ObjectFromCPP> {
  ObjectFromCPP({required int objectID, this.name = "", super.isOpen = true})
      : _objectID = objectID {
    id = objectID.toString();
  }

  int _objectID;

  int get objectID => _objectID;

  set objectID(int value) {
    id = value.toString();
    _objectID = value;
  }

  String name;

  @override
  String getDraggingJSON() {
    return '{"type":"cpp_object","id":$id}';
  }
}

class HierarchyPanelWindow extends EngineSubWindowData {
  HierarchyPanelWindow()
      : super(
            child: HierarchyPanelContents(),
            title: "Hierarchy",
            topPanelWidgets: HierarchyPanelTop());
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
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GeneralButton(
          onPressed: () {
            showNativeContextMenu(
                context,
                MainEngineApp.globalMousePosition.dx,
                MainEngineApp.globalMousePosition.dy,
                TyphonCPPInterface.getPrefabsContextMenuOptions());
          },
          child: Row(
            children: [
              Icon(MdiIcons.plus, color: Colors.white),
              Icon(MdiIcons.menuDown, color: Colors.white)
            ],
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: SizedBox(
            height: 20,
            child: GeneralTextField(
              "",
              prefixIcon: Icon(
                Icons.search,
                size: 15,
                color: Colors.white,
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

class _HierarchyPanelContentsState extends State<HierarchyPanelContents>
    with WindowListener {
  HierarchyWidgetController<ObjectFromCPP> currentObjectsController =
      HierarchyWidgetController<ObjectFromCPP>([]);

  void buildChildrenMapAndAddToObject(
      ObjectFromCPP obj, Map<String, dynamic> map) {
    obj.name = TyphonCPPInterface.getCppFunctions()
        .getObjectNameByID(obj.objectID)
        .cast<Utf8>()
        .toDartString();

    if (!map.containsKey(obj.objectID.toString())) {
      return;
    }

    if (map[obj.objectID.toString()]!.isEmpty) {
      return;
    }

    obj.children = (map[obj.objectID.toString()]! as List<dynamic>)
        .map((e) => ObjectFromCPP(objectID: e))
        .toList();

    for (var childObj in obj.children) {
      buildChildrenMapAndAddToObject(childObj as ObjectFromCPP, map);
    }
  }

  void callbackToEngineChanges() async {
    if (mounted) {
      setState(() {
        currentObjectsController.objects =
            Engine.instance.currentChildren.value.map((e) {
          ObjectFromCPP obj = ObjectFromCPP(objectID: e);
          obj.name = TyphonCPPInterface.getCppFunctions()
              .getObjectNameByID(obj.objectID)
              .cast<Utf8>()
              .toDartString();

          var childrenMap = json.decode(TyphonCPPInterface.getCppFunctions()
              .getObjectChildTree(e)
              .cast<Utf8>()
              .toDartString());
          if (childrenMap is Map<String, dynamic>) {
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
    windowManager.addListener(this);
    Engine.instance.currentChildren.addListener(callbackToEngineChanges);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    windowManager.removeListener(this);
    Engine.instance.currentChildren.removeListener(callbackToEngineChanges);
  }

  int idChosen = -1;
  int idHovered = -1;

  @override
  void onWindowResize() {
    // TODO: implement onWindowResize
    super.onWindowResize();

    callbackToEngineChanges();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => NativeContextMenuArea(
        menuItems: [...TyphonCPPInterface.getPrefabsContextMenuOptions()],
        secondaryTap: true,
        child: Container(
          width: constraints.maxWidth,
          child: HierarchyWidget<ObjectFromCPP>(
            controller: currentObjectsController,
            onClick: (obj) {
              setState(() {
                idChosen = obj.objectID;
              });

              if (!TyphonCPPInterface.checkIfLibraryLoaded()) {
                print("Tried pressing while library not loaded!");
                return;
              }

              Pointer<Char> val = TyphonCPPInterface.getCppFunctions()
                  .getObjectInspectorUIByID(idChosen);
              if (val != nullptr) {
                var jsonData = jsonDecode(val.cast<Utf8>().toDartString());
                buildInspectorPanelFromComponent(obj, jsonData);
              }
            },
            onWillAcceptDrag: (data, obj) {
              return data is String
                  ? (json.decode(data)["type"] == "cpp_object"
                      ? (json.decode(data)["id"] == obj.objectID ? false : true)
                      : false)
                  : false;
            },
            onAccept: (data, obj) {
              if (TyphonCPPInterface.checkIfLibraryLoaded()) {
                TyphonCPPInterface.getCppFunctions().setObjectParent(
                    json.decode(data as String)["id"], obj.objectID);
              } else {
                print("Library not loaded while ended drag!");
              }
            },
            childBasedOnID: (obj) {
              return GestureDetector(
                onSecondaryTap: () {
                  showNativeContextMenu(
                      context,
                      MainEngineFrontend.mousePosition.dx,
                      MainEngineFrontend.mousePosition.dy, [
                    ContextMenuOption(
                        title: "Remove Object",
                        callback: () {
                          if (TyphonCPPInterface.checkIfLibraryLoaded()) {
                            TyphonCPPInterface.getCppFunctions()
                                .removeObjectByID(obj.objectID);
                          }
                        })
                  ]);
                },
                child: GeneralText("${obj.name} ${obj.objectID}"),
              );
            },
            feedbackBasedOnID: (obj) {
              return Container(
                decoration: BoxDecoration(
                    border:
                        Border.fromBorderSide(BorderSide(color: Colors.black))),
                child: GeneralText(obj.name),
              );
            },
          ),
        ),
      ),
    );
  }
}

class Pair<T1, T2> {
  T1 first;
  T2 second;

  Pair(this.first, this.second);
}
