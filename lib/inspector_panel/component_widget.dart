




import 'package:flutter/material.dart';
import 'package:typhon/general_widgets.dart';
import 'package:typhon/general_widgets/custom_expansion_tile.dart';
import 'package:typhon/general_widgets/general_text_field.dart';
import 'package:typhon/general_widgets/rotating_arrow_button.dart';
import 'package:typhon/general_widgets/spacings.dart';
import 'package:typhon/inspector_panel/inspector_panel_builder.dart';

class ComponentWidget extends StatefulWidget {
  ComponentWidget({super.key,required this.componentData});

  Map<String,dynamic> componentData;

  @override
  State<ComponentWidget> createState() => _ComponentWidgetState();
}

class _ComponentWidgetState extends State<ComponentWidget> {
  bool _value = true;


  Widget buildFields() {
    return Column(
      children: [
      for(var e in widget.componentData["fields"])
      Row(
        children: [
          Expanded(
            child: GeneralText(e.keys.first),
            flex: 1
          ),
          HorizontalSpacing(10),
          Expanded(
            child: GeneralTextField(e[e.keys.first]["current_value"]),
            flex:3
          )
        ],
      )
    
      ],
    );
    
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return CustomExpansionTile(
      title: GeneralText(widget.componentData["component_name"]), 
      children: [
        buildFields()
      ]
    );
  }
}