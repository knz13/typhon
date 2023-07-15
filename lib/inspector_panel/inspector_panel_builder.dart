






import 'package:flutter/material.dart';
import 'package:typhon/config/colors.dart';
import 'package:typhon/general_widgets.dart';
import 'package:typhon/inspector_panel/component_widget.dart';
import 'package:typhon/inspector_panel/inspector_panel.dart';




Widget blackSpacer() {
  return Container(
    color: Colors.black,
    height: 2,
    width: double.infinity,
  );
}

void buildInspectorPanelFromComponent(Map<String,dynamic> map) {
  List<Widget> newWidgets = [];
  
  //name
  newWidgets.add(
    Container(
      color: Config.midGray,
      child: GeneralText(map["name"]),
    )
  );

  newWidgets.add(blackSpacer());
  
  for(var component in map["components"]) {
    newWidgets.add(ComponentWidget(componentData: component));
    newWidgets.add(blackSpacer());
  }

  InspectorPanelWindow.dataToShow.value = newWidgets;
}