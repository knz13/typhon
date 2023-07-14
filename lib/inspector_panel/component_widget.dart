




import 'package:flutter/material.dart';
import 'package:typhon/inspector_panel/inspector_panel_builder.dart';

class ComponentWidget extends StatelessWidget {
  ComponentWidget({super.key,required this.componentData});

  Map<String,dynamic> componentData;

  @override
  Widget build(BuildContext context) {
    print(componentData);
    // TODO: implement build
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          Container(
            child: Text(componentData["component_name"]),
          ),
          blackSpacer(),
          Container(
            child: Text(componentData["fields"].toString()),
          )
        ],
      ),
    );
  }
}