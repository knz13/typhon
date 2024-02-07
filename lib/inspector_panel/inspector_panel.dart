import 'dart:convert';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart' hide MenuBar hide MenuStyle;
import 'package:typhon/config/theme.dart';
import 'package:typhon/engine.dart';
import 'package:typhon/general_widgets/general_widgets.dart';
import 'package:typhon/general_widgets/spacings.dart';
import 'package:typhon/hierarchy_panel/hierarchy_panel.dart';
import 'package:typhon/inspector_panel/inspector_panel_builder.dart';
import 'package:typhon/main_engine_frontend.dart';
import 'package:typhon/native_context_menu/native_context_menu.dart';
import 'package:typhon/typhon_bindings.dart';

import '../engine_sub_window.dart';

class InspectorPanelData {
  InspectorPanelData(
      {this.dataToShow = const [], this.objectID, this.topPanelData});

  List<Widget> dataToShow;
  Widget? topPanelData;
  int? objectID;
}

class InspectorPanelWindow extends EngineSubWindowData {
  static ValueNotifier<InspectorPanelData> data =
      ValueNotifier(InspectorPanelData());
  static ValueNotifier<bool> shouldRefreshData = ValueNotifier(false);

  InspectorPanelWindow()
      : super(
            child: InspectorPanel(),
            topPanelWidgets: InspectorPanelTopWidget(),
            title: "Inspector",
            onTabSelected: () {});
}

class InspectorPanelTopWidget extends StatefulWidget {
  @override
  State<InspectorPanelTopWidget> createState() =>
      _InspectorPanelTopWidgetState();
}

class _InspectorPanelTopWidgetState extends State<InspectorPanelTopWidget> {
  void callbackToDataChanged() {
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    InspectorPanelWindow.data.addListener(callbackToDataChanged);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    InspectorPanelWindow.data.removeListener(callbackToDataChanged);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return InspectorPanelWindow.data.value.topPanelData ?? Container();
  }
}

class InspectorPanel extends StatefulWidget {
  @override
  State<InspectorPanel> createState() => _InspectorPanelState();
}

class _InspectorPanelState extends State<InspectorPanel> {
  void onSelectedChanged() {
    setState(() {});
  }

  void onChildrenChangedCallback() {
    if (mounted &&
        !Engine.instance.currentChildren.value
            .contains(InspectorPanelWindow.data.value.objectID)) {
      InspectorPanelWindow.data.value = InspectorPanelData();
      return;
    }
    if (mounted && InspectorPanelWindow.data.value.objectID != null) {
      Pointer<Char> val = TyphonCPPInterface.getCppFunctions()
          .getObjectInspectorUIByID(InspectorPanelWindow.data.value.objectID!);
      if (val != nullptr) {
        var jsonData = jsonDecode(val.cast<Utf8>().toDartString());
        buildInspectorPanelFromComponent(
            ObjectFromCPP(objectID: InspectorPanelWindow.data.value.objectID!),
            jsonData);
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    Engine.instance.currentChildren.addListener(onChildrenChangedCallback);
    InspectorPanelWindow.data.addListener(onSelectedChanged);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    Engine.instance.currentChildren.removeListener(onChildrenChangedCallback);
    InspectorPanelWindow.data.removeListener(onSelectedChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: InspectorPanelWindow.data.value.dataToShow,
            ),
          ),
          if (InspectorPanelWindow.data.value.objectID != null)
            Column(
              children: [
                blackSpacer(),
                VerticalSpacing(MediaQuery.of(context).size.height * 0.025),
                GeneralButton(
                  color: ConfigColors.jetBlack,
                  onPressed: () {
                    if (TyphonCPPInterface.checkIfLibraryLoaded()) {
                      showNativeContextMenu(
                          context,
                          MainEngineFrontend.mousePosition.dx,
                          MainEngineFrontend.mousePosition.dy,
                          TyphonCPPInterface.getComponentsContextMenuOptions());
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GeneralText("Add Component"),
                  ),
                ),
                VerticalSpacing(MediaQuery.of(context).size.height * 0.1)
              ],
            )
        ],
      ),
    );
  }
}
