import 'dart:convert';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:typhon/widgets/general_widgets.dart';
import 'package:typhon/widgets/custom_expansion_tile.dart';
import 'package:typhon/widgets/spacings.dart';
import 'package:typhon/typhon_bindings.dart';

import '../hierarchy_panel/hierarchy_panel.dart';
import 'inspector_panel.dart';
import 'inspector_panel_builder.dart';
import 'vec3_field_builder.dart';

class ComponentWidget extends StatefulWidget {
  ComponentWidget(
      {super.key, required this.componentData, required this.currentObject});

  Map<String, dynamic> componentData;
  ObjectFromCPP currentObject;

  @override
  State<ComponentWidget> createState() => _ComponentWidgetState();
}

class _ComponentWidgetState extends State<ComponentWidget> {
  Widget buildFields() {
    return Column(
      children: [
        for (var e in widget.componentData["fields"])
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
            child: Row(
              children: [
                Expanded(child: GeneralText(e.keys.first), flex: 1),
                HorizontalSpacing(10),
                buildFieldOfType(
                    e[e.keys.first]["type"],
                    e[e.keys.first]["current_value"],
                    e[e.keys.first]["address"])
              ],
            ),
          )
      ],
    );
  }

  void refreshData() {
    if (InspectorPanelWindow.data.value.objectID != null) {
      Pointer<Char> val = TyphonCPPInterface.getCppFunctions()
          .getObjectInspectorUIByID(InspectorPanelWindow.data.value.objectID!);
      if (val != nullptr) {
        var jsonData = jsonDecode(val.cast<Utf8>().toDartString());
        buildInspectorPanelFromComponent(widget.currentObject, jsonData);
      }
    }
  }

  Expanded buildFieldOfType(
      String type, dynamic currentValue, String addresses) {
    switch (type) {
      case "vec3":
        List<double> values = (currentValue as String)
            .split(" ")
            .map((e) => double.parse(e))
            .toList();
        print(values);
        return Expanded(
            flex: 3,
            child: Vec3FieldBuilder(
              key: Key(addresses),
              values: values,
              onDragChange: (p0, p1, p2) {
                Pointer<Float> p0Address =
                    Pointer.fromAddress(int.parse(addresses.split(" ")[0]));
                p0Address.value += p0;
                Pointer<Float> p1Address =
                    Pointer.fromAddress(int.parse(addresses.split(" ")[1]));
                p1Address.value += p1;
                Pointer<Float> p2Address =
                    Pointer.fromAddress(int.parse(addresses.split(" ")[2]));
                p2Address.value += p2;
                refreshData();
              },
              onChange: (p0, p1, p2) {
                Pointer<Float> p0Address =
                    Pointer.fromAddress(int.parse(addresses.split(" ")[0]));
                p0Address.value = p0;
                Pointer<Float> p1Address =
                    Pointer.fromAddress(int.parse(addresses.split(" ")[1]));
                p1Address.value = p1;
                Pointer<Float> p2Address =
                    Pointer.fromAddress(int.parse(addresses.split(" ")[2]));
                p2Address.value = p2;
              },
            ));
      default:
        return Expanded(
          child: Container(),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return CustomExpansionTile(
        title: GeneralText(widget.componentData["component_name"]),
        children: [buildFields()]);
  }
}
