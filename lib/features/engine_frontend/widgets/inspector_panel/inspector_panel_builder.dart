import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:typhon/config/theme.dart';
import 'package:typhon/widgets/general_widgets.dart';
import 'package:typhon/widgets/general_checkbox.dart';
import 'package:typhon/widgets/general_text_field.dart';
import 'package:typhon/widgets/spacings.dart';
import 'package:typhon/widgets/hierarchy_widget.dart';
import 'package:typhon/typhon_bindings.dart';

import '../hierarchy_panel/hierarchy_panel.dart';
import 'component_widget.dart';
import 'inspector_panel.dart';

Widget blackSpacer() {
  return Container(
    color: Colors.black,
    height: 2,
    width: double.infinity,
  );
}

void buildInspectorPanelFromComponent(
    ObjectFromCPP obj, Map<String, dynamic> map) {
  List<Widget> newWidgets = [];

  for (var component in map["components"]) {
    newWidgets.add(ComponentWidget(
      key: Key("CPP object ${obj.id}"),
      componentData: component,
      currentObject: obj,
    ));
    newWidgets.add(blackSpacer());
  }

  

  InspectorPanelWindow.data.value = InspectorPanelData(
      dataToShow: newWidgets,
      objectID: obj.objectID,
      topPanelData: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GeneralCheckbox(
              value: false,
              onChanged: (val) {},
            ),
            HorizontalSpacing(10),
            Expanded(
              child: GeneralTextField(
                map["name"],
                onChanged: (text) {
                  if (TyphonCPPInterface.checkIfLibraryLoaded()) {
                    using(
                      (arena) {
                        Pointer<Char> ptr =
                            text.toNativeUtf8(allocator: arena).cast();
                        TyphonCPPInterface.getCppFunctions()
                            .setObjectName(obj.objectID, ptr, text.length);
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ));
}
